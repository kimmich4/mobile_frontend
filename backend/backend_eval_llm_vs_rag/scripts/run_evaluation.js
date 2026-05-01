const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../../.env") });

const { runLlmOnly } = require("./run_llm_only");
const { runBackendRag } = require("./run_backend_rag");
const { computeMetrics } = require("./compute_metrics");
const { writeJson, writeText, readJson } = require("./backend_flow");

const ROOT = path.resolve(__dirname, "..");

function reportMarkdown(summary) {
  const agg = summary.aggregate;
  const winner = (agg.rag?.overall_score || 0) >= (agg.llm_only?.overall_score || 0) ? "LLM + RAG" : "LLM-only";
  const flow = readJson(path.join(ROOT, "reports", "backend_flow_reconstruction.json"));
  const lines = [];
  lines.push("# DeepSeek LLM-only vs LLM + RAG Evaluation");
  lines.push("");
  lines.push(`Generated at: ${summary.generatedAt}`);
  lines.push("");
  lines.push("## Reconstructed Backend Flow");
  for (const step of flow.steps) lines.push(`- ${step}`);
  lines.push("");
  lines.push("## Request Setup");
  lines.push("- Provider endpoint: Hugging Face router `/v1/chat/completions`.");
  lines.push("- Model: `deepseek-ai/DeepSeek-V3`.");
  lines.push("- Max tokens: `16000`.");
  lines.push("- Temperature: not set by backend, so provider default is used.");
  lines.push("- RAG path uses the backend-style system message, context body, task header, embedding retrieval, and vector-context injection.");
  lines.push("- LLM-only path uses one natural user prompt with the same user profile, reports, and calculated values, but no retrieved chunks.");
  lines.push("");
  lines.push("## Metrics");
  lines.push("- Precision = TP / (TP + FP)");
  lines.push("- Recall = TP / (TP + FN)");
  lines.push("- F1 = 2 * (precision * recall) / (precision + recall)");
  lines.push("- Overall score prioritizes quality: 20% instruction adherence, 20% constraint compliance, 15% structure, 15% completeness, 10% personalization, 10% faithfulness, 5% F1, 5% efficiency.");
  lines.push("");
  lines.push("## Aggregate Results");
  lines.push("| Mode | Precision | Recall | F1 | Instruction | Constraints | Structure | Complete | Personalization | Faithfulness | Latency ms | Tokens | Overall |");
  lines.push("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|");
  for (const mode of ["llm_only", "rag"]) {
    const row = agg[mode] || {};
    lines.push(`| ${mode} | ${fmt(row.precision)} | ${fmt(row.recall)} | ${fmt(row.f1)} | ${fmt(row.instruction_adherence)} | ${fmt(row.constraint_compliance)} | ${fmt(row.structure_compliance)} | ${fmt(row.completeness)} | ${fmt(row.personalization)} | ${fmt(row.faithfulness)} | ${fmt(row.latency_ms, 0)} | ${fmt(row.token_usage, 0)} | ${fmt(row.overall_score)} |`);
  }
  lines.push("");
  lines.push("## Per-case Results");
  lines.push("| Case | Mode | Precision | Recall | F1 | Overall | Failures |");
  lines.push("|---|---|---:|---:|---:|---:|---|");
  for (const row of summary.perCase) {
    const failures = [];
    if (row.detectedFailures.malformedOutput) failures.push("malformed");
    if (row.detectedFailures.forbiddenHits.length) failures.push(`forbidden: ${row.detectedFailures.forbiddenHits.join(", ")}`);
    if (row.detectedFailures.missingPositiveTerms) failures.push("missing positive safety terms");
    if (row.detectedFailures.calculationErrors.length) failures.push("calorie math errors");
    lines.push(`| ${row.caseId} | ${row.mode} | ${fmt(row.precision)} | ${fmt(row.recall)} | ${fmt(row.f1)} | ${fmt(row.overall_score)} | ${failures.join("; ") || "none"} |`);
  }
  lines.push("");
  lines.push("## Charts");
  lines.push("Generated chart files are saved in `charts/` after running the Python scripts.");
  lines.push("");
  lines.push("## Recommendation");
  lines.push(`Current measured winner: **${winner}**.`);
  lines.push("Use the aggregate scores and per-case failures above to decide whether RAG's extra retrieval complexity is justified for DeepSeek on this backend task.");
  lines.push("");
  lines.push("## Confirmed vs Inferred");
  lines.push("- Confirmed from code: route input fields, BMR/TDEE/calorie formulas, RAG retrieval order, Qdrant collection and limit, vector-context formatting, DeepSeek endpoint/model/max_tokens, backend system message, user message structure, and JSON parsing behavior.");
  lines.push("- Inference in evaluator: deterministic keyword-based faithfulness and personalization scoring, because the backend does not contain a production gold-answer judge.");
  return lines.join("\n");
}

function fmt(value, digits = 3) {
  return typeof value === "number" && Number.isFinite(value) ? value.toFixed(digits) : "";
}

function writeBackendFlowDoc() {
  const flow = {
    confirmedFromCode: [
      "backend/index.js",
      "backend/rag_chain.js",
      "backend/rag_logic.js",
      "backend/qdrant_client.js",
      "backend/plan_generator.js"
    ],
    steps: [
      "Express receives `/ai/generate-diet` or `/ai/generate-workout` JSON body.",
      "Route merges base fields with `other_*` custom fields for conditions, allergies, injuries, goals, and experience.",
      "Route builds `searchQuery` from medical/allergy/injury/experience data.",
      "Route calculates BMR with the backend Harris-Benedict style formula.",
      "Route calculates TDEE using backend activity multipliers.",
      "Route adjusts calories by -500 for fat loss terms, +500 for gain/build/bulk/muscle terms, otherwise maintenance.",
      "Route builds `contextPrefix` containing user profile, measurements, report text, calculated values, and `{{VECTOR_CONTEXT}}` placeholder.",
      "Route builds backend-engineered `task` prompt with expected JSON shape.",
      "rag_chain validates and normalizes the search query; empty/none query skips vector search.",
      "rag_logic requests embeddings from Hugging Face `sentence-transformers/all-MiniLM-L6-v2`.",
      "rag_logic searches Qdrant collection `athlete_health_context` with limit 3, payloads enabled, score threshold 0.300.",
      "rag_chain formats retrieved payloads as issue plus contraindicated foods and exercises.",
      "rag_chain injects that formatted vector context into `contextPrefix`.",
      "plan_generator builds DeepSeek messages: one system message and one user message containing `Context:` plus `Task:`.",
      "plan_generator sends POST to `https://router.huggingface.co/v1/chat/completions` with model `deepseek-ai/DeepSeek-V3` and `max_tokens: 16000`.",
      "plan_generator strips JSON fences, parses JSON for validity, retries on failures, and route returns parsed JSON."
    ],
    generationSettings: {
      endpoint: "https://router.huggingface.co/v1/chat/completions",
      provider: "Hugging Face router",
      model: "deepseek-ai/DeepSeek-V3",
      max_tokens: 16000,
      temperature: "not set in backend"
    }
  };
  writeJson(path.join(ROOT, "reports", "backend_flow_reconstruction.json"), flow);
}

async function runEvaluation() {
  writeBackendFlowDoc();
  console.log("Running exactly 7 LLM-only cases.");
  await runLlmOnly();
  console.log("Running exactly 7 LLM + RAG cases.");
  await runBackendRag();
  const summary = computeMetrics();
  writeText(path.join(ROOT, "reports", "final_comparison_report.md"), reportMarkdown(summary));
  return summary;
}

if (require.main === module) {
  runEvaluation().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = { runEvaluation, writeBackendFlowDoc, reportMarkdown };
