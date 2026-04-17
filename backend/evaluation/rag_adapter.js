"use strict";

const { getEmbedding, queryQdrant } = require("../rag_logic");
const { generateAnswer } = require("../plan_generator");

function formatResultContext(result) {
    const payload = result?.payload || {};
    const foods = Array.isArray(payload.contraindicated_foods)
        ? payload.contraindicated_foods.map((item) => item.food).filter(Boolean)
        : [];
    const exercises = Array.isArray(payload.contraindicated_exercises)
        ? payload.contraindicated_exercises.map((item) => item.exercise).filter(Boolean)
        : [];

    return `Issue: ${payload.issue || "N/A"}. Constraints: Foods to avoid (${foods.join(", ")}), Exercises to avoid (${exercises.join(", ")})`;
}

function buildVectorContext(results) {
    if (!Array.isArray(results) || results.length === 0) {
        return "No specific contraindications found in database.";
    }

    return results.map(formatResultContext).join("\n");
}

async function runRetrieval(searchQuery) {
    const normalizedQuery = String(searchQuery || "").trim();
    if (!normalizedQuery || normalizedQuery.toLowerCase() === "none") {
        return {
            skipped: true,
            vector: null,
            results: [],
            vectorContext: "No specific contraindications found in database."
        };
    }

    const vector = await getEmbedding(normalizedQuery);
    const results = await queryQdrant(vector);
    return {
        skipped: false,
        vector,
        results: Array.isArray(results) ? results : [],
        vectorContext: buildVectorContext(results)
    };
}

async function runGeneration({ searchQuery, contextPrefix, task, retrieval }) {
    const resolvedRetrieval = retrieval || await runRetrieval(searchQuery);
    const finalContext = String(contextPrefix || "{{VECTOR_CONTEXT}}").replace("{{VECTOR_CONTEXT}}", resolvedRetrieval.vectorContext);
    const answer = await generateAnswer(finalContext, task);

    return {
        ...resolvedRetrieval,
        finalContext,
        answer
    };
}

async function runBaselineGeneration({ contextPrefix, task }) {
    const finalContext = String(contextPrefix || "{{VECTOR_CONTEXT}}").replace("{{VECTOR_CONTEXT}}", "No specific contraindications found in database.");
    const answer = await generateAnswer(finalContext, task);

    return {
        finalContext,
        answer
    };
}

function resultToContext(result) {
    const payload = result?.payload || {};
    if (typeof payload.text === "string" && payload.text.trim()) {
        return payload.text.trim();
    }

    return formatResultContext(result);
}

module.exports = {
    buildVectorContext,
    resultToContext,
    runBaselineGeneration,
    runGeneration,
    runRetrieval
};
