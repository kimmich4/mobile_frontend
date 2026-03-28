require("dotenv").config();
const express = require('express');
const cors = require('cors');
const ytSearch = require('yt-search');
const { defaultDietPlan, defaultWorkoutPlan } = require('./fallbacks');

const { ragChain } = require('./rag_chain');
const { generateAnswer, calculateBMR, calculateTDEE, adjustCalories } = require('./plan_generator');
const { chatAssistant } = require('./ai_assistant');
const { analyzeImage } = require('./ocr_logic');

const app = express();
app.use(express.json({ limit: '50mb' }));
app.use(cors());

// ─────────────────────────────────────────────────────────────────────────────
// Route: AI Chat
// ─────────────────────────────────────────────────────────────────────────────
app.post('/ai/chat', async (req, res) => {
    const { messages } = req.body;

    if (!messages || !Array.isArray(messages)) {
        return res.status(400).json({ error: "Missing or invalid messages array" });
    }

    try {
        const responseText = await chatAssistant(messages);
        res.json({ response: responseText });
    } catch (e) {
        res.status(500).json({ error: "Failed to get AI response", details: e.message });
    }
});

// ─────────────────────────────────────────────────────────────────────────────
// Route: Analyze Medical / InBody Report (OCR)
// ─────────────────────────────────────────────────────────────────────────────
app.post('/ai/analyze-report', async (req, res) => {
    const { base64Image, type } = req.body;

    if (!base64Image) {
        return res.status(400).json({ error: "Missing image data" });
    }

    try {
        const extractedText = await analyzeImage(base64Image, type || 'report');
        res.json({ extractedText });
    } catch (e) {
        res.status(500).json({ error: "Failed to analyze report", details: e.message });
    }
});

// ─────────────────────────────────────────────────────────────────────────────
// Route: Generate 7-Day Diet Plan
// ─────────────────────────────────────────────────────────────────────────────
app.post('/ai/generate-diet', async (req, res) => {
    const { userId, fullName, age, height_cm, weight_kg, target_weight_kg, gender, activity_level, goal, health_conditions, allergies, injuries, experience_level, other_medical, other_allergy, other_injury, other_fitness_goal, other_experience, medical_report_text, inbody_report_text } = req.body;
    console.log(`Diet requested for ${fullName || userId}`);

    try {
        // Merge "other" custom text into relevant fields
        const allHealthConditions = [health_conditions, other_medical].filter(Boolean).join(', ');
        const allAllergies = [allergies, other_allergy].filter(Boolean).join(', ');
        const allInjuries = [injuries, other_injury].filter(Boolean).join(', ');
        const allGoals = [goal, other_fitness_goal].filter(Boolean).join(', ');

        // 1. Define vector search string
        const searchQuery = `${allHealthConditions}, ${allAllergies},${allInjuries}`;

        // 2. Calculate calorie targets
        const bmr = calculateBMR(weight_kg, height_cm, age, gender || 'male');
        const tdee = calculateTDEE(bmr, activity_level || 'moderate');
        const targetCalories = adjustCalories(tdee, allGoals);

        // 3. Build generic context template (LangChain injects Vector details into {{VECTOR_CONTEXT}})
        const contextPrefix = `
User Profile: ${fullName}, ${age} years old, ${gender}. 
Metrics: Current Weight: ${weight_kg}kg, Target Weight: ${target_weight_kg || 'Not specified'}kg, Height: ${height_cm}cm. 
Activity Level: ${activity_level || 'moderate'}.
Experience Level: ${experience_level || 'Not specified'}.
Goals: ${allGoals || 'General fitness'}.  
Reported Health Conditions: ${allHealthConditions || 'None'}. 
Allergies: ${allAllergies || 'None'}. 
Injuries: ${allInjuries || 'None'}.
Calculated BMR: ${Math.round(bmr)}. 
Calculated TDEE: ${Math.round(tdee)}.
Target Daily Calories (adjusted for goal): ${targetCalories}.
Medical Report Findings: ${medical_report_text || 'None provided'}.
InBody Report Findings: ${inbody_report_text || 'None provided'}.
Vector Database Constraints: {{VECTOR_CONTEXT}}
`;

        // 4. Build prompt task
        const task = `Create a 7-day diet plan (Day 1 to Day 7). 
You MUST provide EXACTLY 7 DAYS in the "days" array. DO NOT stop before Day 7.

USER GOAL: ${allGoals}
TARGET CALORIES: ${targetCalories} PER DAY.

CRITICAL RULES:
1. YOU MUST GENERATE ALL 7 DAYS (day 1, 2, 3, 4, 5, 6, 7).
2. For EVERY day, the "totalCalories" field MUST be EXACTLY ${targetCalories}.
3. The sum of all individual "calories" for items in "meals" MUST EXACTLY mathematically equal ${targetCalories} for every day. 
4. meal variety: Each day SHOULD have a varied number of meals (between 3 and 6).
5. Ensure the diet plan is safe for the provided injuries/conditions and doesnt violate any of the vector database constraints.
6. CREATIVE TITLES: Use different meal names instead of just "Breakfast/Lunch/Dinner". Be creative and varied!
7. Portions (grams/ml) must be realistic and specific.

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

        // 5. Execute the full LangChain orchestration
        const aiResponse = await ragChain.invoke({ searchQuery, contextPrefix, task });
        res.json(JSON.parse(aiResponse));
    } catch (e) {
        console.error("AI Generation failed:", e.message);
        res.status(500).json({ error: "Failed to generate diet plan. Please retry.", details: e.message });
    }
});

// ─────────────────────────────────────────────────────────────────────────────
// Route: Generate 7-Day Workout Plan
// ─────────────────────────────────────────────────────────────────────────────
app.post('/ai/generate-workout', async (req, res) => {
    const { userId, fullName, age, height_cm, weight_kg, target_weight_kg, gender, activity_level, goal, health_conditions, allergies, injuries, experience_level, other_medical, other_allergy, other_injury, other_fitness_goal, other_experience, medical_report_text, inbody_report_text } = req.body;
    console.log(`Workout requested for ${fullName || userId}`);

    try {
        // Merge "other" custom text into relevant fields
        const allHealthConditions = [health_conditions, other_medical].filter(Boolean).join(', ');
        const allAllergies = [allergies, other_allergy].filter(Boolean).join(', ');
        const allInjuries = [injuries, other_injury].filter(Boolean).join(', ');
        const allGoals = [goal, other_fitness_goal].filter(Boolean).join(', ');
        const experienceInfo = [experience_level, other_experience].filter(Boolean).join(' - ');

        // 1. Define vector search string
        const searchQuery = `Health conditions: ${allHealthConditions}. Allergies: ${allAllergies}. Injuries: ${allInjuries}. Experience: ${experienceInfo || ''}`;

        // 2. Calculate calorie targets (for context)
        const bmr = calculateBMR(weight_kg, height_cm, age, gender || 'male');
        const tdee = calculateTDEE(bmr, activity_level || 'moderate');
        const targetCalories = adjustCalories(tdee, allGoals);

        // 3. Build generic context template (LangChain injects Vector details into {{VECTOR_CONTEXT}})
        const contextPrefix = `
User Profile: ${fullName}, ${age} years old, ${gender}. 
Metrics: Current Weight: ${weight_kg}kg, Target Weight: ${target_weight_kg || 'Not specified'}kg, Height: ${height_cm}cm.
BMR: ${bmr.toFixed(2)}, TDEE: ${tdee.toFixed(2)}. Target Calories: ${targetCalories} kcal.
Activity Level: ${activity_level || 'moderate'}.
Experience Level: ${experienceInfo || 'Not specified'}.
Goals: ${allGoals || 'General fitness'}. 
Health Conditions: ${allHealthConditions || 'None'}.
Allergies: ${allAllergies || 'None'}.
Injuries: ${allInjuries || 'None'}.
Medical Report Findings: ${medical_report_text || 'None provided'}.
InBody Report Findings: ${inbody_report_text || 'None provided'}.
Vector Database Constraints: {{VECTOR_CONTEXT}}
`;

        // 4. Build prompt task
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

        // 5. Execute the full LangChain orchestration
        const aiResponse = await ragChain.invoke({ searchQuery, contextPrefix, task });
        res.json(JSON.parse(aiResponse));
    } catch (e) {
        console.error("AI Generation failed:", e.message);
        res.status(500).json({ error: "Failed to generate workout plan. Please retry.", details: e.message });
    }
});

// ─────────────────────────────────────────────────────────────────────────────
// Route: YouTube Video Search
// ─────────────────────────────────────────────────────────────────────────────
app.post('/ai/search-video', async (req, res) => {
    const { query } = req.body;
    if (!query) {
        return res.status(400).json({ error: "Missing query" });
    }
    try {
        console.log(`🔍 Searching YouTube for: "${query}"`);
        const result = await ytSearch(query);
        const videos = result.videos.slice(0, 1);
        if (videos.length > 0) {
            res.json({ videoId: videos[0].videoId });
        } else {
            res.status(404).json({ error: "No video found" });
        }
    } catch (e) {
        console.error("YouTube Search Error:", e.message);
        res.status(500).json({ error: "Failed to search video", details: e.message });
    }
});

// ─────────────────────────────────────────────────────────────────────────────
// Route: Health Check
// ─────────────────────────────────────────────────────────────────────────────
app.get('/health', (req, res) => res.json({ status: 'ok', environment: 'BypassMode' }));

const PORT = 3000;
if (require.main === module) {
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`AI Backend started on port ${PORT}. Network bypass enabled.`);
    });
}

module.exports = { app };
