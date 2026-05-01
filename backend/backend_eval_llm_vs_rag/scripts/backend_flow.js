const fs = require("fs");
const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../../.env") });

const { calculateBMR, calculateTDEE, adjustCalories } = require("../../plan_generator");

const HF_CHAT_COMPLETIONS_URL = "https://router.huggingface.co/v1/chat/completions";
const DEEPSEEK_MODEL = "deepseek-ai/DeepSeek-V3";
const MAX_TOKENS = 16000;

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, JSON.stringify(value, null, 2));
}

function writeText(filePath, value) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, value);
}

function redactHeaders(headers) {
  return {
    ...headers,
    Authorization: headers.Authorization ? "Bearer [REDACTED]" : undefined
  };
}

function stripJsonFences(content) {
  if (!content) return "";
  if (content.includes("```json")) {
    return content.split("```json")[1].split("```")[0].trim();
  }
  if (content.includes("```")) {
    return content.split("```")[1].split("```")[0].trim();
  }
  return content.trim();
}

function tryParseJson(content) {
  try {
    return { ok: true, value: JSON.parse(stripJsonFences(content)) };
  } catch (error) {
    return { ok: false, error: error.message, value: null };
  }
}

function normalizeJoined(...parts) {
  return parts.filter(Boolean).join(", ");
}

function computeDerivedValues(body) {
  const allHealthConditions = normalizeJoined(body.health_conditions, body.other_medical);
  const allAllergies = normalizeJoined(body.allergies, body.other_allergy);
  const allInjuries = normalizeJoined(body.injuries, body.other_injury);
  const allGoals = normalizeJoined(body.goal, body.other_fitness_goal);
  const experienceInfo = [body.experience_level, body.other_experience].filter(Boolean).join(" - ");
  const bmr = calculateBMR(body.weight_kg, body.height_cm, body.age, body.gender || "male");
  const tdee = calculateTDEE(bmr, body.activity_level || "moderate");
  const targetCalories = adjustCalories(tdee, allGoals);

  return {
    allHealthConditions,
    allAllergies,
    allInjuries,
    allGoals,
    experienceInfo,
    bmr,
    tdee,
    targetCalories
  };
}

function buildDietRagInput(body) {
  const d = computeDerivedValues(body);
  const searchQuery = `${d.allHealthConditions}, ${d.allAllergies},${d.allInjuries}`;
  const contextPrefix = `
User Profile: ${body.fullName}, ${body.age} years old, ${body.gender}. 
Metrics: Current Weight: ${body.weight_kg}kg, Target Weight: ${body.target_weight_kg || "Not specified"}kg, Height: ${body.height_cm}cm. 
Activity Level: ${body.activity_level || "moderate"}.
Experience Level: ${body.experience_level || "Not specified"}.
Goals: ${d.allGoals || "General fitness"}.  
Reported Health Conditions: ${d.allHealthConditions || "None"}. 
Allergies: ${d.allAllergies || "None"}. 
Injuries: ${d.allInjuries || "None"}.
Calculated BMR: ${Math.round(d.bmr)}. 
Calculated TDEE: ${Math.round(d.tdee)}.
Target Daily Calories (adjusted for goal): ${d.targetCalories}.
Medical Report Findings: ${body.medical_report_text || "None provided"}.
InBody Report Findings: ${body.inbody_report_text || "None provided"}.
Vector Database Constraints: {{VECTOR_CONTEXT}}
`;

  const task = `Create a 7-day diet plan (Day 1 to Day 7). 
You MUST provide EXACTLY 7 DAYS in the "days" array. DO NOT stop before Day 7.

USER GOAL: ${d.allGoals}
TARGET CALORIES: ${d.targetCalories} PER DAY.

CRITICAL RULES:
1. YOU MUST GENERATE ALL 7 DAYS (day 1, 2, 3, 4, 5, 6, 7).
2. For EVERY day, the "totalCalories" field MUST be EXACTLY ${d.targetCalories}.
3. The sum of all individual "calories" for items in "meals" MUST EXACTLY mathematically equal ${d.targetCalories} for every day. 
4. meal variety: Each day SHOULD have a varied number of meals (between 5 and above to achive the target calories).
5. Ensure the diet plan is safe for the provided injuries/conditions and doesnt violate any of the vector database constraints.
6. CREATIVE TITLES: Use different meal names instead of just "Breakfast/Lunch/Dinner". Be creative and varied!
7. Portions (grams/ml) must be realistic and specific.

THINKING STEP:
Before writing each day, decide on the number of meals (3-6) and creative formal titles. Then mentally calculate the calories for each so the total matches exactly ${d.targetCalories}.

EXAMPLE OF CORRECT MATH (Varying counts/titles):
- Pre-Gym Snack: 300
- Main Lunch: 900
- Afternoon Refresh: 300
- Hearty Supper: 1000
TOTAL: 300 + 900 + 300 + 1000 = 2500 (Matches target)

Return ONLY JSON in this EXACT format:
{
  "days": [
    {
      "day": 1,
      "totalCalories": ${d.targetCalories},
      "protein": "150g",
      "carbs": "200g",
      "fats": "60g",
      "meals": [
        {
          "title": "Pre-Gym Snack",
          "items": [{"name": "Banana + Almonds", "calories": 300}]
        },
        {
          "title": "Lunch",
          "items": [{"name": "Chicken Breast (150g)", "calories": 450}, {"name": "Brown Rice (200g)", "calories": 450}]
        }
        // ... add more meals per day
      ]
    }
    // MUST CONTINUE FOR DAYS 2, 3, 4, 5, 6, 7
  ]
}`;

  return { route: "/ai/generate-diet", searchQuery, contextPrefix, task, derived: d };
}

function buildWorkoutRagInput(body) {
  const d = computeDerivedValues(body);
  const searchQuery = `Health conditions: ${d.allHealthConditions}. Allergies: ${d.allAllergies}. Injuries: ${d.allInjuries}. Experience: ${d.experienceInfo || ""}`;
  const contextPrefix = `
User Profile: ${body.fullName}, ${body.age} years old, ${body.gender}. 
Metrics: Current Weight: ${body.weight_kg}kg, Target Weight: ${body.target_weight_kg || "Not specified"}kg, Height: ${body.height_cm}cm.
BMR: ${d.bmr.toFixed(2)}, TDEE: ${d.tdee.toFixed(2)}. Target Calories: ${d.targetCalories} kcal.
Activity Level: ${body.activity_level || "moderate"}.
Experience Level: ${d.experienceInfo || "Not specified"}.
Goals: ${d.allGoals || "General fitness"}. 
Health Conditions: ${d.allHealthConditions || "None"}.
Allergies: ${d.allAllergies || "None"}.
Injuries: ${d.allInjuries || "None"}.
Medical Report Findings: ${body.medical_report_text || "None provided"}.
InBody Report Findings: ${body.inbody_report_text || "None provided"}.
Vector Database Constraints: {{VECTOR_CONTEXT}}
`;

  const task = `Create a 7-day exercise plan.
For EACH day, provide TWO complete plans: one for "home" and one for "gym".
Include warm-up, main exercises, and cool-down.
Each day should have a VARIED number of exercises (between 6 and 10), also the calories and sets and reps should be varied and NOT always the same count and they should be realistic. 
Adjust difficulty based on the user's experience level and if he gave you a specific split name like "push-pull-legs" or "full body" or "upper-lower" make it in the exact format of the Json in example.
Ensure exercises are safe for the provided injuries/conditions and doesnt violate any of the vector database constraints. 
Return ONLY JSON in this format:
{
  "gym": {
    "title": "Gym Workout Plan",
    "days": [{"day": 1, "exercises": [{"id": 1, "name": "...", "difficulty": "Medium", "equipment": "...", "sets": "3", "reps": "12", "calories": 40}, {"id": 2, "name": "...", "difficulty": "Easy", "equipment": "...", "sets": "3", "reps": "15", "calories": 49}]}]
  },
  "home": {
    "title": "Home Workout Plan",
    "days": [{"day": 1, "exercises": [{"id": 1, "name": "...", "difficulty": "Medium", "equipment": "None", "sets": "3", "reps": "12", "calories": 100}, {"id": 2, "name": "...", "difficulty": "Easy", "equipment": "None", "sets": "3", "reps": "15", "calories": 80}]}]
  }
}`;

  return { route: "/ai/generate-workout", searchQuery, contextPrefix, task, derived: d };
}

function buildBackendRagInput(example) {
  if (example.route === "/ai/generate-diet") return buildDietRagInput(example.requestBody);
  if (example.route === "/ai/generate-workout") return buildWorkoutRagInput(example.requestBody);
  throw new Error(`Unsupported route: ${example.route}`);
}

function buildBackendMessages(context, question) {
  return [
    {
      role: "system",
      content: "You are a certified sports nutritionist and personal trainer. You MUST return ONLY valid, complete JSON. Keep responses compact but complete. Accuracy is critical for user safety."
    },
    {
      role: "user",
      content: `Context:\n${context}\n\nTask:\n${question}`
    }
  ];
}

function buildRequestPayload(messages, extra = {}) {
  return {
    model: DEEPSEEK_MODEL,
    messages,
    max_tokens: MAX_TOKENS,
    ...extra
  };
}

async function sendDeepSeekRequest(messages, { stream = false } = {}) {
  const headers = {
    Authorization: `Bearer ${process.env.HF_API_KEY}`,
    "Content-Type": "application/json"
  };
  const payload = buildRequestPayload(messages, stream ? { stream: true } : {});
  const tStart = Date.now();
  const response = await fetch(HF_CHAT_COMPLETIONS_URL, {
    method: "POST",
    headers,
    body: JSON.stringify(payload)
  });
  const rawText = await response.text();
  const tEnd = Date.now();
  let rawJson = null;
  try {
    rawJson = JSON.parse(rawText);
  } catch (_) {
    rawJson = { nonJsonResponse: rawText };
  }

  if (!response.ok) {
    const error = new Error(`HF API Error: ${response.status} - ${rawText}`);
    error.status = response.status;
    error.capture = {
      endpoint: HF_CHAT_COMPLETIONS_URL,
      request: { method: "POST", headers: redactHeaders(headers), body: payload },
      response: { status: response.status, body: rawJson },
      latencyMs: tEnd - tStart
    };
    throw error;
  }

  const content = stripJsonFences(rawJson.choices?.[0]?.message?.content || "");
  return {
    endpoint: HF_CHAT_COMPLETIONS_URL,
    request: { method: "POST", headers: redactHeaders(headers), body: payload },
    response: { status: response.status, body: rawJson },
    rawContent: rawJson.choices?.[0]?.message?.content || "",
    cleanedContent: content,
    parsed: tryParseJson(content),
    usage: rawJson.usage || null,
    finishReason: rawJson.choices?.[0]?.finish_reason || null,
    latencyMs: tEnd - tStart
  };
}

module.exports = {
  HF_CHAT_COMPLETIONS_URL,
  DEEPSEEK_MODEL,
  MAX_TOKENS,
  ensureDir,
  readJson,
  writeJson,
  writeText,
  stripJsonFences,
  tryParseJson,
  computeDerivedValues,
  buildBackendRagInput,
  buildBackendMessages,
  buildRequestPayload,
  sendDeepSeekRequest
};
