const path = require("path");
const { ensureDir, writeJson } = require("./backend_flow");

const ROOT = path.resolve(__dirname, "..");

function artifactBase(caseId, mode) {
  return path.join(ROOT, "results", `${caseId}_${mode}`);
}

function saveRunArtifacts({ caseId, mode, requestCapture, promptText, retrievedContext, normalized, error }) {
  const base = artifactBase(caseId, mode);
  ensureDir(base);

  if (promptText !== undefined) {
    require("fs").writeFileSync(path.join(base, "prompt.txt"), promptText);
  }

  if (requestCapture?.request) {
    writeJson(path.join(base, "request_payload.json"), requestCapture.request);
  }

  if (requestCapture?.response) {
    writeJson(path.join(base, "raw_response.json"), requestCapture.response);
  }

  if (retrievedContext !== undefined) {
    writeJson(path.join(base, "retrieved_context.json"), retrievedContext);
  }

  if (normalized !== undefined) {
    writeJson(path.join(base, "normalized_output.json"), normalized);
  }

  if (error) {
    writeJson(path.join(ROOT, "logs", `${caseId}_${mode}_error.json`), {
      caseId,
      mode,
      message: error.message,
      status: error.status || null,
      capture: error.capture || null,
      stack: error.stack
    });
  }
}

module.exports = { saveRunArtifacts };
