require("dotenv").config();

// ─────────────────────────────────────────────────────────────────────────────
// 🔹 BMR / TDEE Calculations
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// 🔹 Adjust target calories based on fitness goal
//    (was duplicated in both generate-diet and generate-workout routes)
// ─────────────────────────────────────────────────────────────────────────────
function adjustCalories(tdee, goals) {
    const lowerGoals = goals.toLowerCase();
    let targetCalories = tdee;
    if (lowerGoals.includes('lose') || lowerGoals.includes('cut') || lowerGoals.includes('fat') || lowerGoals.includes('loss')) {
        targetCalories -= 500; // Deficit for weight loss
    } else if (lowerGoals.includes('build') || lowerGoals.includes('gain') || lowerGoals.includes('bulk') || lowerGoals.includes('muscle')) {
        targetCalories += 500; // Surplus for building muscle
    }
    return Math.round(targetCalories);
}

// ─────────────────────────────────────────────────────────────────────────────
// 🔹 AI Plan Generator — DeepSeek via HuggingFace Router, with retry logic
// ─────────────────────────────────────────────────────────────────────────────
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
                // 504 Gateway Timeout or 503 Service Unavailable — retryable
                if (response.status === 504 || response.status === 503) {
                    console.warn(`Attempt ${i + 1} failed with ${response.status}. Retrying in 2s...`);
                    lastError = new Error(`HF API Error: ${response.status} - ${errText}`);
                    await new Promise(resolve => setTimeout(resolve, 2000));
                    continue;
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

            // Strip markdown fences if the model wrapped JSON in them
            if (content.includes("```json")) {
                content = content.split("```json")[1].split("```")[0].trim();
            } else if (content.includes("```")) {
                content = content.split("```")[1].split("```")[0].trim();
            }

            // Test if the JSON is complete. If parsing fails, it throws immediately and triggers the retry loop!
            JSON.parse(content);

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

module.exports = { calculateBMR, calculateTDEE, adjustCalories, generateAnswer };
