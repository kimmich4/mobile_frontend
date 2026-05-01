const fs = require("fs");
const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../../.env") });

const {
  readJson,
  writeJson,
  computeDerivedValues,
  sendDeepSeekRequest
} = require("./backend_flow");
const { saveRunArtifacts } = require("./save_requests");

const ROOT = path.resolve(__dirname, "..");

function buildPlainPrompt(example) {
  const body = example.requestBody;
  const d = computeDerivedValues(body);
  const intro = fs.readFileSync(path.join(ROOT, "prompts", "llm_only_plain_prompt.txt"), "utf8").trim();
  const requestType = example.route.includes("diet") ? "diet" : "workout";

  return `${intro}

Request type: ${requestType}

Person:
- Name: ${body.fullName}
- Age: ${body.age}
- Sex: ${body.gender}
- Height: ${body.height_cm} cm
- Current weight: ${body.weight_kg} kg
- Target weight: ${body.target_weight_kg || "not specified"} kg
- Activity level: ${body.activity_level || "moderate"}
- Experience: ${[body.experience_level, body.other_experience].filter(Boolean).join(" - ") || "not specified"}
- Goal: ${[body.goal, body.other_fitness_goal].filter(Boolean).join(", ") || "general fitness"}
- Health conditions: ${[body.health_conditions, body.other_medical].filter(Boolean).join(", ") || "none"}
- Allergies or food restrictions: ${[body.allergies, body.other_allergy].filter(Boolean).join(", ") || "none"}
- Injuries or movement restrictions: ${[body.injuries, body.other_injury].filter(Boolean).join(", ") || "none"}
- Medical report notes: ${body.medical_report_text || "none provided"}
- InBody notes: ${body.inbody_report_text || "none provided"}
- Calculated BMR: ${Math.round(d.bmr)}
- Calculated TDEE: ${Math.round(d.tdee)}
- Target daily calories: ${d.targetCalories}

If this is a diet request, use this JSON shape:
{"days":[{"day":1,"totalCalories":${d.targetCalories},"protein":"...g","carbs":"...g","fats":"...g","meals":[{"title":"...","items":[{"name":"...","calories":123}]}]}]}

If this is a workout request, use this JSON shape:
{"gym":{"title":"Gym Workout Plan","days":[{"day":1,"exercises":[{"id":1,"name":"...","difficulty":"...","equipment":"...","sets":"...","reps":"...","calories":123}]}]},"home":{"title":"Home Workout Plan","days":[{"day":1,"exercises":[{"id":1,"name":"...","difficulty":"...","equipment":"...","sets":"...","reps":"...","calories":123}]}]}}
`;
}

async function runLlmOnlyCase(example) {
  const prompt = buildPlainPrompt(example);
  const messages = [{ role: "user", content: prompt }];
  const mode = "llm_only";
  const derived = computeDerivedValues(example.requestBody);

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
      derived,
      latencyMs: capture.latencyMs,
      usage: capture.usage,
      finishReason: capture.finishReason
    };
    saveRunArtifacts({
      caseId: example.caseId,
      mode,
      requestCapture: capture,
      promptText: prompt,
      normalized
    });
    return normalized;
  } catch (error) {
    saveRunArtifacts({
      caseId: example.caseId,
      mode,
      promptText: prompt,
      error
    });
    return {
      caseId: example.caseId,
      mode,
      route: example.route,
      parsedOk: false,
      error: error.message,
      derived
    };
  }
}

async function runLlmOnly({ casesPath = path.join(ROOT, "config", "eval_cases.json") } = {}) {
  const cases = readJson(casesPath);
  if (cases.length !== 7) throw new Error(`Expected exactly 7 cases, found ${cases.length}`);

  const results = [];
  for (const example of cases) {
    console.log(`[LLM-only] Running ${example.caseId}`);
    results.push(await runLlmOnlyCase(example));
  }

  writeJson(path.join(ROOT, "results", "raw_outputs_llm_only.json"), results);
  return results;
}

if (require.main === module) {
  runLlmOnly().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = { runLlmOnly, runLlmOnlyCase, buildPlainPrompt };
