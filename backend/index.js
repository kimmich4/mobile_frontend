require("dotenv").config();
const express = require('express');
const cors = require('cors');
const { QdrantClient } = require("@qdrant/js-client-rest");
const { HfInference } = require("@huggingface/inference");

const app = express();
app.use(express.json());
app.use(cors());

// 1️⃣ Connect to Qdrant
const qdrant = new QdrantClient({
    url: process.env.QDRANT_URL,
    apiKey: process.env.QDRANT_API_KEY
});

// 2️⃣ Connect to HuggingFace
const hf = new HfInference(process.env.HF_API_KEY);

// 3️⃣ Embedding function
async function getEmbedding(text) {
    try {
        const embedding = await hf.featureExtraction({
            model: "sentence-transformers/all-MiniLM-L6-v2",
            inputs: text
        });
        if (!embedding) throw new Error("Embedding failed");

        let vector;
        if (Array.isArray(embedding) && typeof embedding[0] === "number") {
            vector = embedding;
        } else if (Array.isArray(embedding) && Array.isArray(embedding[0])) {
            vector = embedding[0];
        } else if (Array.isArray(embedding) && embedding[0]?.embedding) {
            vector = embedding[0].embedding;
        } else if (embedding.embeddings) {
            vector = embedding.embeddings[0];
        } else {
            throw new Error("Unknown embedding format");
        }
        return vector.map(x => parseFloat(x));
    } catch (e) {
        console.error("Embedding Error:", e);
        throw e;
    }
}

// 4️⃣ Search Qdrant
async function searchDocuments(userId, query) {
    try {
        const queryVector = await getEmbedding(query);
        // Note: Collection name might need to be verified (user_health_context vs athlete_health_context)
        // Using 'athlete_health_context' as per original script example
        const result = await qdrant.search("athlete_health_context", {
            vector: queryVector,
            limit: 3,
            // filter: { must: [{ key: "athlete_id", match: { value: userId } }] }, // Context aware filter
            with_payload: true
        });
        return result;
    } catch (e) {
        console.error("Qdrant Search Error:", e);
        return [];
    }
}

// 5️⃣ Generate Answer via LLM
async function generateAnswer(context, question, model = "deepseek-ai/DeepSeek-V3.2") {
    try {
        // Using direct fetch as per original script for custom model endpoint
        const response = await fetch("https://router.huggingface.co/v1/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${process.env.HF_API_KEY}`,
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                model: model,
                messages: [
                    { role: "system", content: "You are a helpful assistant." },
                    { role: "user", content: `Context:\n${context}\n\nQuestion:\n${question} \n\nIMPORTANT: Return ONLY valid JSON format.` }
                ],
                max_tokens: 4000
            })
        });

        const data = await response.json();
        return data.choices?.[0]?.message?.content || "{}";
    } catch (e) {
        console.error("LLM Error:", e);
        throw e;
    }
}

// Routes
app.post('/ai/generate-diet', async (req, res) => {
    try {
        const { userId, health_conditions, goal, age, height_cm, weight_kg } = req.body;

        console.log(`Generating diet for ${userId}...`);

        // Search context
        const query = `${health_conditions} ${goal}`;
        const searchResults = await searchDocuments(userId, query);

        let context = "";
        if (searchResults.length > 0) {
            context = searchResults.map(r => {
                const p = r.payload;
                return `Health issue: ${p.issue || 'none'}, Dietary restrictions: ${(p.dietary_restrictions || []).join(", ")}`;
            }).join("\n");
        }

        const prompt = `
            Create a detailed daily diet plan for a ${age} year old, ${height_cm}cm, ${weight_kg}kg person.
            Goal: ${goal}.
            Health Conditions: ${health_conditions}.
            Context from database: ${context}
            
            Return JSON with structure:
            {
                "date": "${new Date().toISOString()}",
                "totalCalories": 2000,
                "protein": "150g",
                "carbs": "200g",
                "fats": "60g",
                "meals": [
                    { "title": "Breakfast", "items": [{ "name": "Food", "calories": 500 }] },
                    { "title": "Lunch", "items": [{ "name": "Food", "calories": 700 }] },
                    { "title": "Dinner", "items": [{ "name": "Food", "calories": 800 }] }
                ]
            }
        `;

        const jsonString = await generateAnswer(context, prompt);

        // Basic cleanup of markdown code blocks if LLL returns them
        const cleanedJson = jsonString.replace(/```json/g, '').replace(/```/g, '').trim();
        const plan = JSON.parse(cleanedJson);

        console.log("Generated Plan:", JSON.stringify(plan, null, 2));

        // Ensure macros are strings
        if (typeof plan.protein === 'number') plan.protein = `${plan.protein}g`;
        if (typeof plan.carbs === 'number') plan.carbs = `${plan.carbs}g`;
        if (typeof plan.fats === 'number') plan.fats = `${plan.fats}g`;

        res.json(plan);
    } catch (e) {
        console.error("Error generating diet:", e);
        res.status(500).json({ error: e.message });
    }
});

app.post('/ai/generate-workout', async (req, res) => {
    try {
        const { userId, goal, age, preference } = req.body; // preference: 'home' or 'gym'

        console.log(`Generating workout for ${userId}...`);

        const prompt = `
            Create a ${preference || 'gym'} workout plan for a ${age} year old.
            Goal: ${goal}.
            
             Return JSON with structure:
            {
                "title": "Full Body",
                "durationMinutes": 60,
                "totalCalories": 400,
                "exerciseCount": 5,
                "exercises": [
                    { 
                        "id": 1, 
                        "name": "Pushups", 
                        "difficulty": "Medium", 
                        "equipment": "Bodyweight",
                        "sets": "3",
                        "reps": "12",
                        "calories": 50
                    }
                ]
            }
        `;

        const jsonString = await generateAnswer("", prompt);
        const cleanedJson = jsonString.replace(/```json/g, '').replace(/```/g, '').trim();
        const plan = JSON.parse(cleanedJson);

        res.json(plan);
    } catch (e) {
        console.error("Error generating workout:", e);
        res.status(500).json({ error: e.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});


