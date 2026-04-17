"use strict";

require("dotenv").config();

const HF_CHAT_COMPLETIONS_URL = "https://router.huggingface.co/v1/chat/completions";
const DEFAULT_JUDGE_MODEL = process.env.RAG_EVAL_JUDGE_MODEL || "deepseek-ai/DeepSeek-V3";

function extractJsonObject(text) {
    const content = String(text || "").trim();
    const fenceMatch = content.match(/```(?:json)?\s*([\s\S]*?)```/i);
    const raw = fenceMatch ? fenceMatch[1].trim() : content;
    const firstBrace = raw.indexOf("{");
    const lastBrace = raw.lastIndexOf("}");

    if (firstBrace === -1 || lastBrace === -1 || lastBrace <= firstBrace) {
        throw new Error("Judge did not return JSON");
    }

    return JSON.parse(raw.slice(firstBrace, lastBrace + 1));
}

async function callJudge(messages, model = DEFAULT_JUDGE_MODEL) {
    if (!process.env.HF_API_KEY) {
        throw new Error("HF_API_KEY is required for LLM judging");
    }

    const response = await fetch(HF_CHAT_COMPLETIONS_URL, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${process.env.HF_API_KEY}`,
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            model,
            messages,
            max_tokens: 1200,
            temperature: 0
        })
    });

    if (!response.ok) {
        const errorBody = await response.text();
        throw new Error(`Judge API failed with ${response.status}: ${errorBody}`);
    }

    const payload = await response.json();
    return extractJsonObject(payload?.choices?.[0]?.message?.content || "");
}

async function judgeAnswerCorrectness({ question, groundTruthAnswer, modelAnswer }) {
    return callJudge([
        {
            role: "system",
            content: "You evaluate answer correctness. Return only JSON with keys score, verdict, reasoning. score must be a number from 0 to 1."
        },
        {
            role: "user",
            content: [
                `Question:\n${question || ""}`,
                `Ground Truth:\n${groundTruthAnswer || ""}`,
                `Model Answer:\n${modelAnswer || ""}`,
                "Judge whether the model answer correctly answers the question. Penalize omissions and factual mistakes."
            ].join("\n\n")
        }
    ]);
}

async function judgeFaithfulness({ question, contexts, modelAnswer }) {
    return callJudge([
        {
            role: "system",
            content: "You evaluate grounding. Return only JSON with keys score, verdict, unsupported_claims, reasoning. score must be a number from 0 to 1."
        },
        {
            role: "user",
            content: [
                `Question:\n${question || ""}`,
                `Retrieved Contexts:\n${(contexts || []).join("\n\n---\n\n")}`,
                `Model Answer:\n${modelAnswer || ""}`,
                "Judge whether every claim in the model answer is supported by the retrieved contexts. unsupported_claims must be an array of strings."
            ].join("\n\n")
        }
    ]);
}

module.exports = {
    judgeAnswerCorrectness,
    judgeFaithfulness
};
