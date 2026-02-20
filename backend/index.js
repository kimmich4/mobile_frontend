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
const app = express();
app.use(express.json());
app.use(cors());

// 🔹 Helper: Get Embeddings (Using Router)
async function getEmbedding(text) {
    const response = await fetch("https://router.huggingface.co/v1/embeddings", {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${process.env.HF_API_KEY}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            model: "sentence-transformers/all-MiniLM-L6-v2",
            input: text
        })
    });

    if (!response.ok) {
        const err = await response.text();
        throw new Error(`Embedding API Error: ${response.status} - ${err}`);
    }

    const data = await response.json();
    const vector = data.data?.[0]?.embedding;

    if (!vector) throw new Error("Embedding failed: No vector in response");

    return vector.map(x => parseFloat(x));
}

// 🔹 Helper: Search Health Context
async function searchHealthContext(userId, problem) {
    try {
        const queryVector = await getEmbedding(problem);
        const result = await qdrant.search("athlete_health_context", {
            vector: queryVector,
            limit: 2,
            with_payload: true
        });
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
    console.log(`AI Request starting...`);
    const response = await fetch("https://router.huggingface.co/v1/chat/completions", {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${process.env.HF_API_KEY}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            model: "deepseek-ai/DeepSeek-V3", // Using DeepSeek-V3 as requested
            messages: [
                {
                    role: "system",
                    content: "You are a certified sports nutritionist and personal trainer. You MUST return ONLY valid JSON. Accuracy is critical for user safety."
                },
                {
                    role: "user",
                    content: `Context:\n${context}\n\nTask:\n${question}`
                }
            ],
            max_tokens: 4000
        })
    });

    if (!response.ok) {
        const err = await response.text();
        throw new Error(`HF API Error: ${response.statusCode} - ${err}`);
    }

    const data = await response.json();
    let content = data.choices?.[0]?.message?.content || "";

    // Clean JSON from markdown if present
    if (content.includes("```json")) {
        content = content.split("```json")[1].split("```")[0].trim();
    } else if (content.includes("```")) {
        content = content.split("```")[1].split("```")[0].trim();
    }

    return content;
}

app.post('/ai/generate-diet', async (req, res) => {
    const { userId, fullName, age, height_cm, weight_kg, gender, activity_level, goal, health_conditions, allergies, injuries } = req.body;
    console.log(`Diet requested for ${fullName || userId}`);

    try {
        // 1. Search Vector Context for all health inputs
        const searchQuery = `${health_conditions} ${allergies} ${injuries}`;
        const vectorContext = await searchHealthContext(userId, searchQuery);

        // 2. Calculations
        const bmr = calculateBMR(weight_kg, height_cm, age, gender || 'male');
        const tdee = calculateTDEE(bmr, activity_level || 'moderate');

        // 3. Build Rich Context
        const context = `
User Profile: ${fullName}, ${age} years old, ${gender}. 
Metrics: ${weight_kg}kg, ${height_cm}cm. 
Goal: ${goal}. 
Reported Health: ${health_conditions}. 
Allergies: ${allergies}. 
Injuries: ${injuries}.
Calculated BMR: ${Math.round(bmr)}. 
Calculated TDEE: ${Math.round(tdee)}.
Vector database search results for these conditions: ${vectorContext || 'No specific contraindications found in database.'}
`;

        const task = `Create a 7-day highly detailed diet plan. 
Ensure the plan respects ALL health conditions, allergies, and injuries. 
Return ONLY JSON in this EXACT format: 
{
  "days": [
    {
      "day": 1,
      "totalCalories": ${Math.round(tdee)},
      "protein": "150g",
      "carbs": "200g",
      "fats": "60g",
      "meals": [
        {
          "title": "Breakfast",
          "items": [
              {"name": "...", "calories": 0}
          ]
        }
      ]
    }
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
    const { userId, fullName, age, height_cm, weight_kg, gender, activity_level, goal, health_conditions, allergies, injuries } = req.body;
    console.log(`Workout requested for ${fullName || userId}`);

    try {
        const searchQuery = `${health_conditions} ${injuries}`;
        const vectorContext = await searchHealthContext(userId, searchQuery);

        const context = `
User Profile: ${fullName}, ${age} years old, ${gender}. 
Goal: ${goal}. 
Health context: ${health_conditions}, ${injuries}.
Vector Database Constraints: ${vectorContext || 'None'}.
`;

        const task = `Create a 7-day exercise plan. 
For EACH day, provide TWO complete plans: one for "home" and one for "gym". 
Include warm-up, main exercises, and cool-down. 
Ensure exercises are safe for the provided injuries/conditions. 
Return ONLY JSON in this format:
{
  "gym": {
    "title": "Gym Workout Plan",
    "days": [{"day": 1, "exercises": [{"id": 1, "name": "...", "difficulty": "Medium", "equipment": "...", "sets": "3", "reps": "12", "calories": 0}]}]
  },
  "home": {
    "title": "Home Workout Plan",
    "days": [{"day": 1, "exercises": [{"id": 1, "name": "...", "difficulty": "Medium", "equipment": "None", "sets": "3", "reps": "12", "calories": 0}]}]
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
