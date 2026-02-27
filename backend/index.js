require("dotenv").config();
const express = require('express');
const cors = require('cors');
const https = require('https');
const { QdrantClient } = require("@qdrant/js-client-rest");
const { HfInference } = require("@huggingface/inference");
const { defaultDietPlan, defaultWorkoutPlan } = require('./fallbacks');

// 🔹 Initialize Clients
const qdrant = new QdrantClient({
    url: process.env.QDRANT_URL,
    apiKey: process.env.QDRANT_API_KEY
});
const hf = new HfInference(process.env.HF_API_KEY);
const app = express();
app.use(express.json());
app.use(cors());

// 🔹 Helper: Get Embeddings (Using HfInference)
async function getEmbedding(text) {
    const vector = await hf.featureExtraction({
        model: "sentence-transformers/all-MiniLM-L6-v2",
        inputs: text
    });

    if (!vector || !Array.isArray(vector)) {
        throw new Error("Embedding failed: No valid vector in response");
    }

    return vector.map(x => parseFloat(x));
}

// 🔹 Helper: Search Health Context (finds similar cases by health profile)
async function searchHealthContext(healthProfile) {
    // 🔍 Skip if input is effectively empty or "none"
    const cleanProfile = healthProfile ? healthProfile.toLowerCase().replace(/none/g, "").replace(/[,.\s]/g, "") : "";
    if (!cleanProfile) {
        console.log(`ℹ️ Skipping Qdrant search for "${healthProfile}": No substantive health profile provided.`);
        return "";
    }

    try {
        const queryVector = await getEmbedding(healthProfile);
        console.log(`🔍 Qdrant Search Query: "${healthProfile}"`);
        const result = await qdrant.search("athlete_health_context", {
            vector: queryVector,
            limit: 3,
            with_payload: true,
            score_threshold: 0.015
        });

        if (result && result.length > 0) {
            console.log(`✅ Qdrant search found ${result.length} matches.`);
            console.log("   Results:", JSON.stringify(result.map(r => ({ score: r.score, payload: r.payload })), null, 2));
        } else {
            console.log(`ℹ️ Qdrant search found 0 matches.`);
        }

        return result.map(r => {
            const p = r.payload;
            return `Issue: ${p.issue || 'N/A'}. Constraints: Foods to avoid (${(p.contraindicated_foods || []).map(f => f.food).join(", ")}), Exercises to avoid (${(p.contraindicated_exercises || []).map(e => e.exercise).join(", ")})`;
        }).join("\n");
    } catch (e) {
        console.error("Qdrant Search Error:", e.message);
        return "";
    }
}

// 🔹 Helper: BMR/TDEE Calculation
function calculateBMR(weight, height, age, gender) {
    if (gender.toLowerCase() === 'male') {
        return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
        return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
}

function calculateTDEE(bmr, activityLevel) {
    const activityMultipliers = {
        'sedentary': 1.2,
        'light': 1.375,
        'moderate': 1.55,
        'active': 1.725,
        'very active': 1.9
    };
    return bmr * (activityMultipliers[activityLevel.toLowerCase()] || 1.375);
}

// 1️⃣ Robust AI Forwarder (Using Router & DeepSeek)
async function generateAnswer(context, question) {
    const maxRetries = 3;
    let lastError;

    for (let i = 0; i < maxRetries; i++) {
        try {
            console.log(`AI Request attempt ${i + 1}/${maxRetries}...`);
            const response = await fetch("https://router.huggingface.co/v1/chat/completions", {
                method: "POST",
                headers: {
                    "Authorization": `Bearer ${process.env.HF_API_KEY}`,
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    model: "deepseek-ai/DeepSeek-V3",
                    messages: [
                        {
                            role: "system",
                            content: "You are a certified sports nutritionist and personal trainer. You MUST return ONLY valid, complete JSON. Keep responses compact but complete. Accuracy is critical for user safety."
                        },
                        {
                            role: "user",
                            content: `Context:\n${context}\n\nTask:\n${question}`
                        }
                    ],
                    max_tokens: 16000
                })
            });

            if (!response.ok) {
                const errText = await response.text();
                // 504 Gateway Timeout or 503 Service Unavailable - Retryable
                if (response.status === 504 || response.status === 503) {
                    console.warn(`Attempt ${i + 1} failed with ${response.status}. Retrying in 2s...`);
                    lastError = new Error(`HF API Error: ${response.status} - ${errText}`);
                    await new Promise(resolve => setTimeout(resolve, 2000));
                    continue; // Retry
                }
                throw new Error(`HF API Error: ${response.status} - ${errText}`);
            }

            const data = await response.json();
            let content = data.choices?.[0]?.message?.content || "";
            const finishReason = data.choices?.[0]?.finish_reason;

            // Warn if response was truncated
            if (finishReason === 'length') {
                console.warn("⚠️ AI response was TRUNCATED (hit max_tokens limit). JSON may be incomplete.");
            }

            // Clean JSON from markdown if present
            if (content.includes("```json")) {
                content = content.split("```json")[1].split("```")[0].trim();
            } else if (content.includes("```")) {
                content = content.split("```")[1].split("```")[0].trim();
            }

            return content;
        } catch (e) {
            lastError = e;
            if (i === maxRetries - 1) throw e;
            console.error(`Attempt ${i + 1} catched error: ${e.message}. Retrying...`);
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
    }
    throw lastError;
}

app.post('/ai/generate-diet', async (req, res) => {
    const { userId, fullName, age, height_cm, weight_kg, gender, activity_level, goal, health_conditions, allergies, injuries, experience_level, other_medical, other_allergy, other_injury, other_fitness_goal, other_experience } = req.body;
    console.log(`Diet requested for ${fullName || userId}`);

    try {
        // Merge "other" custom text into relevant fields
        const allHealthConditions = [health_conditions, other_medical].filter(Boolean).join(', ');
        const allAllergies = [allergies, other_allergy].filter(Boolean).join(', ');
        const allInjuries = [injuries, other_injury].filter(Boolean).join(', ');
        const allGoals = [goal, other_fitness_goal].filter(Boolean).join(', ');

        // 1. Search Vector Context using full health profile
        const searchQuery = `${allHealthConditions}, ${allAllergies},${allInjuries}`;
        const vectorContext = await searchHealthContext(searchQuery);

        // 2. Calculations
        const bmr = calculateBMR(weight_kg, height_cm, age, gender || 'male');
        const tdee = calculateTDEE(bmr, activity_level || 'moderate');

        // 2b. Adjust TDEE based on goals
        let targetCalories = tdee;
        const lowerGoals = allGoals.toLowerCase();
        if (lowerGoals.includes('lose') || lowerGoals.includes('cut') || lowerGoals.includes('fat') || lowerGoals.includes('loss')) {
            targetCalories -= 500; // Deficit for weight loss
        } else if (lowerGoals.includes('build') || lowerGoals.includes('gain') || lowerGoals.includes('bulk') || lowerGoals.includes('muscle')) {
            targetCalories += 500; // Surplus for building muscle
        }
        targetCalories = Math.round(targetCalories);

        // 3. Build Rich Context
        const context = `
User Profile: ${fullName}, ${age} years old, ${gender}. 
Metrics: ${weight_kg}kg, ${height_cm}cm. 
Activity Level: ${activity_level || 'moderate'}.
Experience Level: ${experience_level || 'Not specified'}.
Goals: ${allGoals || 'General fitness'}. 
Reported Health Conditions: ${allHealthConditions || 'None'}. 
Allergies: ${allAllergies || 'None'}. 
Injuries: ${allInjuries || 'None'}.
Calculated BMR: ${Math.round(bmr)}. 
Calculated TDEE: ${Math.round(tdee)}.
Target Daily Calories (adjusted for goal): ${targetCalories}.
Vector database search results for these conditions: ${vectorContext || 'No specific contraindications found in database.'}
`;

        const task = `Create a 7-day diet plan (Day 1 to Day 7). 
You MUST provide EXACTLY 7 DAYS in the "days" array. DO NOT stop before Day 7.

USER GOAL: ${allGoals}
TARGET CALORIES: ${targetCalories} PER DAY.

CRITICAL RULES:
1. YOU MUST GENERATE ALL 7 DAYS (day 1, 2, 3, 4, 5, 6, 7).
2. For EVERY day, the "totalCalories" field MUST be EXACTLY ${targetCalories}.
3. The sum of all individual "calories" for items in "meals" MUST EXACTLY mathematically equal ${targetCalories} for every day. 
4. meal variety: Each day SHOULD have a varied number of meals (between 3 and 6). 
5. CREATIVE TITLES: Use different meal names (e.g., "Dawn Fuel", "Mid-Day Boost", "Evening Feast", "Night-time Nosh") instead of just "Breakfast/Lunch/Dinner". Be creative and varied!
6. Portions (grams/ml) must be realistic and specific.

THINKING STEP:
Before writing each day, decide on the number of meals (3-6) and creative formal titles. Then mentally calculate the calories for each so the total matches exactly ${targetCalories}.

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
      "totalCalories": ${targetCalories},
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

        const aiResponse = await generateAnswer(context, task);
        res.json(JSON.parse(aiResponse));
    } catch (e) {
        console.error("AI Generation failed:", e.message);
        res.status(500).json({ error: "Failed to generate diet plan. Please retry.", details: e.message });
    }
});

app.post('/ai/generate-workout', async (req, res) => {
    const { userId, fullName, age, height_cm, weight_kg, gender, activity_level, goal, health_conditions, allergies, injuries, experience_level, other_medical, other_allergy, other_injury, other_fitness_goal, other_experience } = req.body;
    console.log(`Workout requested for ${fullName || userId}`);

    try {
        // Merge "other" custom text into relevant fields
        const allHealthConditions = [health_conditions, other_medical].filter(Boolean).join(', ');
        const allAllergies = [allergies, other_allergy].filter(Boolean).join(', ');
        const allInjuries = [injuries, other_injury].filter(Boolean).join(', ');
        const allGoals = [goal, other_fitness_goal].filter(Boolean).join(', ');
        const experienceInfo = [experience_level, other_experience].filter(Boolean).join(' - ');

        const searchQuery = `Health conditions: ${allHealthConditions}. Allergies: ${allAllergies}. Injuries: ${allInjuries}. Experience: ${experienceInfo || ''}`;
        const vectorContext = await searchHealthContext(searchQuery);

        const context = `
User Profile: ${fullName}, ${age} years old, ${gender}. 
Metrics: ${weight_kg}kg, ${height_cm}cm.
Activity Level: ${activity_level || 'moderate'}.
Experience Level: ${experienceInfo || 'Not specified'}.
Goals: ${allGoals || 'General fitness'}. 
Health Conditions: ${allHealthConditions || 'None'}.
Allergies: ${allAllergies || 'None'}.
Injuries: ${allInjuries || 'None'}.
Vector Database Constraints: ${vectorContext || 'None'}.
`;

        const task = `Create a 7-day exercise plan.
For EACH day, provide TWO complete plans: one for "home" and one for "gym".
Include warm-up, main exercises, and cool-down.
Each day should have a VARIED number of exercises (between 6 and 10), also the calories and sets and reps should be varied and NOT always the same count and they should be realistic. 
Adjust difficulty based on the user's experience level and if he gave you a specific split name like "push-pull-legs" or "full body" or "upper-lower" make it in the exact format of the Json in example.
Ensure exercises are safe for the provided injuries/conditions. 
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

        const aiResponse = await generateAnswer(context, task);
        res.json(JSON.parse(aiResponse));
    } catch (e) {
        console.error("AI Generation failed:", e.message);
        res.status(500).json({ error: "Failed to generate workout plan. Please retry.", details: e.message });
    }
});

app.get('/health', (req, res) => res.json({ status: 'ok', environment: 'BypassMode' }));

const PORT = 3000;
if (require.main === module) {
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`AI Backend started on port ${PORT}. Network bypass enabled.`);
    });
}

module.exports = { calculateBMR, calculateTDEE, searchHealthContext, getEmbedding };
