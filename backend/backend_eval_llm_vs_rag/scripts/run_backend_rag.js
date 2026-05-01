const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../../.env") });

const { getEmbedding, queryQdrant } = require("../../rag_logic");
const {
  readJson,
  writeJson,
  buildBackendRagInput,
  buildBackendMessages,
  sendDeepSeekRequest
} = require("./backend_flow");
const { saveRunArtifacts } = require("./save_requests");

const ROOT = path.resolve(__dirname, "..");

function formatVectorContext(skip, results) {
  if (skip || !results || results.length === 0) {
    return "No specific contraindications found in database.";
  }
  return results.map((r) => {
    const p = r.payload || {};
    return `Issue: ${p.issue || "N/A"}. Constraints: Foods to avoid (${(p.contraindicated_foods || []).map((f) => f.food).join(", ")}), Exercises to avoid (${(p.contraindicated_exercises || []).map((e) => e.exercise).join(", ")})`;
  }).join("\n");
}

async function retrieveLikeBackend(searchQuery) {
  const cleanProfile = searchQuery
    ? searchQuery.toLowerCase().replace(/none/g, "").replace(/[,.\s]/g, "")
    : "";

  if (!cleanProfile) {
    return { skip: true, vector: null, results: [], vectorContext: formatVectorContext(true, []) };
  }

  try {
    const vector = await getEmbedding(searchQuery);
    const results = await queryQdrant(vector);
    return {
      skip: false,
      vectorLength: Array.isArray(vector) ? vector.length : null,
      results,
      vectorContext: formatVectorContext(false, results)
    };
  } catch (error) {
    return {
      skip: true,
      retrievalError: error.message,
      results: [],
      vectorContext: formatVectorContext(true, [])
    };
  }
}

async function runRagCase(example) {
  const backendInput = buildBackendRagInput(example);
  const retrieval = await retrieveLikeBackend(backendInput.searchQuery);
  const finalContext = backendInput.contextPrefix.replace("{{VECTOR_CONTEXT}}", retrieval.vectorContext);
  const messages = buildBackendMessages(finalContext, backendInput.task);
  const promptText = `Context:\n${finalContext}\n\nTask:\n${backendInput.task}`;
  const mode = "rag";

  try {
    const capture = await sendDeepSeekRequest(messages);
    const normalized = {
      caseId: example.caseId,
      mode,
      route: example.route,
      parsedOk: capture.parsed.ok,
      parsedOutput: capture.parsed.value,
      parseError: capture.parsed.error || null,
      cleanedContent: capture.cleanedContent,
      derived: backendInput.derived,
      latencyMs: capture.latencyMs,
      usage: capture.usage,
      finishReason: capture.finishReason,
      retrieval
    };
    saveRunArtifacts({
      caseId: example.caseId,
      mode,
      requestCapture: capture,
      promptText,
      retrievedContext: retrieval,
      normalized
    });
    return normalized;
  } catch (error) {
    saveRunArtifacts({
      caseId: example.caseId,
      mode,
      promptText,
      retrievedContext: retrieval,
      error
    });
    return {
      caseId: example.caseId,
      mode,
      route: example.route,
      parsedOk: false,
      error: error.message,
      derived: backendInput.derived,
      retrieval
    };
  }
}

async function runBackendRag({ casesPath = path.join(ROOT, "config", "eval_cases.json") } = {}) {
  const cases = readJson(casesPath);
  if (cases.length !== 7) throw new Error(`Expected exactly 7 cases, found ${cases.length}`);

  const results = [];
  for (const example of cases) {
    console.log(`[RAG] Running ${example.caseId}`);
    results.push(await runRagCase(example));
  }

  writeJson(path.join(ROOT, "results", "raw_outputs_rag.json"), results);
  return results;
}

if (require.main === module) {
  runBackendRag().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = { runBackendRag, runRagCase, retrieveLikeBackend, formatVectorContext };
