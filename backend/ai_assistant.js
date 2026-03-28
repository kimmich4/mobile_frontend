require("dotenv").config();

// 🔹 Helper: Chat Assistant (Using OpenRouter with Fallbacks)
async function chatAssistant(messages) {
    const models = [
        "stepfun/step-3.5-flash:free",
        "arcee-ai/trinity-large-preview:free",
        "upstage/solar-pro-3:free",
        "liquid/lfm-2.5-1.2b-thinking:free",
        "nvidia/nemotron-3-nano-30b-a3b:free",
        "google/gemma-3n-e2b-it:free",
        "mistralai/mistral-small-3.1-24b-instruct:free"
    ];

    let lastError;

    for (const model of models) {
        try {
            console.log(`🤖 Attempting chat with ${model}...`);
            const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
                method: "POST",
                headers: {
                    "Authorization": `Bearer ${process.env.OPENROUTER_API_KEY}`,
                    "Content-Type": "application/json",
                    "HTTP-Referer": "https://github.com/stepfun-ai",
                    "X-Title": "Fitness AI Assistant",
                },
                body: JSON.stringify({
                    model: model,
                    messages: [
                        {
                            role: "system",
                            content: "You are a helpful and knowledgeable fitness assistant. You provide personalized advice on workouts, diet, and general health. Keep your responses concise and motivating."
                        },
                        ...messages
                    ],
                    max_tokens: 1000,
                })
            });

            if (!response.ok) {
                const errText = await response.text();
                // If rate limited (429), try next model
                if (response.status === 429) {
                    console.warn(`⚠️ Model ${model} is rate limited. Trying next...`);
                    lastError = new Error(`Rate limit reached for ${model}`);
                    continue;
                }
                throw new Error(`Chat API Error: ${response.status} - ${errText}`);
            }

            const data = await response.json();
            return data.choices?.[0]?.message?.content || "I'm sorry, I couldn't process that.";
        } catch (e) {
            console.error(`Chat attempt with ${model} failed:`, e.message);
            lastError = e;
            if (model === models[models.length - 1]) throw e;
        }
    }
    throw lastError;
}

module.exports = { chatAssistant };
