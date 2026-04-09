require("dotenv").config();

const HF_CHAT_COMPLETIONS_URL = "https://router.huggingface.co/v1/chat/completions";
const MAX_TOKENS = 16000;

function calculateBMR(weight, height, age, gender) {
    if (gender.toLowerCase() === "male") {
        return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    }
    return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
}

function calculateTDEE(bmr, activityLevel) {
    const activityMultipliers = {
        sedentary: 1.2,
        light: 1.375,
        moderate: 1.55,
        active: 1.725,
        "very active": 1.9
    };
    return bmr * (activityMultipliers[activityLevel.toLowerCase()] || 1.375);
}

function adjustCalories(tdee, goals) {
    const lowerGoals = goals.toLowerCase();
    let targetCalories = tdee;

    if (lowerGoals.includes("lose") || lowerGoals.includes("cut") || lowerGoals.includes("fat") || lowerGoals.includes("loss")) {
        targetCalories -= 500;
    } else if (lowerGoals.includes("build") || lowerGoals.includes("gain") || lowerGoals.includes("bulk") || lowerGoals.includes("muscle")) {
        targetCalories += 500;
    }

    return Math.round(targetCalories);
}

function buildMessages(context, question) {
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

function stripJsonFences(content) {
    if (content.includes("```json")) {
        return content.split("```json")[1].split("```")[0].trim();
    }
    if (content.includes("```")) {
        return content.split("```")[1].split("```")[0].trim();
    }
    return content.trim();
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function isRetryableStatus(status) {
    return status === 503 || status === 504;
}

async function requestChatCompletion(messages) {
    const response = await fetch(HF_CHAT_COMPLETIONS_URL, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${process.env.HF_API_KEY}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            model: "deepseek-ai/DeepSeek-V3",
            messages,
            max_tokens: MAX_TOKENS
        })
    });

    if (!response.ok) {
        const errText = await response.text();
        const error = new Error(`HF API Error: ${response.status} - ${errText}`);
        error.status = response.status;
        throw error;
    }

    const data = await response.json();
    const finishReason = data.choices?.[0]?.finish_reason;
    const content = stripJsonFences(data.choices?.[0]?.message?.content || "");

    if (finishReason === "length") {
        console.warn("AI response was truncated at max_tokens. JSON may be incomplete.");
    }

    return content;
}

async function requestChatCompletionStream(messages) {
    const response = await fetch(HF_CHAT_COMPLETIONS_URL, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${process.env.HF_API_KEY}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            model: "deepseek-ai/DeepSeek-V3",
            messages,
            max_tokens: MAX_TOKENS,
            stream: true
        })
    });

    if (!response.ok) {
        const errText = await response.text();
        const error = new Error(`HF API Error: ${response.status} - ${errText}`);
        error.status = response.status;
        throw error;
    }

    if (!response.body) {
        throw new Error("HF API Error: streaming response body was empty");
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = "";
    let content = "";
    let finishReason = null;

    try {
        while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            buffer += decoder.decode(value, { stream: true });
            const lines = buffer.split(/\r?\n/);
            buffer = lines.pop() || "";

            for (const line of lines) {
                const trimmed = line.trim();
                if (!trimmed.startsWith("data:")) continue;

                const payload = trimmed.slice(5).trim();
                if (!payload || payload === "[DONE]") continue;

                const parsed = JSON.parse(payload);
                const choice = parsed.choices?.[0];

                if (choice?.delta?.content) {
                    content += choice.delta.content;
                }

                if (choice?.finish_reason) {
                    finishReason = choice.finish_reason;
                }
            }
        }
    } finally {
        reader.releaseLock();
    }

    if (finishReason === "length") {
        console.warn("AI streaming response was truncated at max_tokens. JSON may be incomplete.");
    }

    return stripJsonFences(content);
}

async function generateAnswer(context, question) {
    const maxRetries = 5;
    const messages = buildMessages(context, question);
    let lastError;

    for (let i = 0; i < maxRetries; i++) {
        try {
            console.log(`AI Request attempt ${i + 1}/${maxRetries}...`);
            const content = await requestChatCompletion(messages);
            JSON.parse(content);
            return content;
        } catch (e) {
            lastError = e;

            if (isRetryableStatus(e.status)) {
                console.warn(`Attempt ${i + 1} failed with ${e.status}. Trying streaming fallback...`);

                try {
                    const streamedContent = await requestChatCompletionStream(messages);
                    JSON.parse(streamedContent);
                    console.log(`Streaming fallback succeeded on attempt ${i + 1}.`);
                    return streamedContent;
                } catch (streamError) {
                    lastError = streamError;
                    if (i === maxRetries - 1) throw streamError;
                    console.error(`Streaming fallback failed on attempt ${i + 1}: ${streamError.message}`);
                    await sleep(2000 * (i + 1));
                    continue;
                }
            }

            if (i === maxRetries - 1) throw e;
            console.error(`Attempt ${i + 1} caught error: ${e.message}. Retrying...`);
            await sleep(1000 * (i + 1));
        }
    }

    throw lastError;
}

module.exports = { calculateBMR, calculateTDEE, adjustCalories, generateAnswer };
