"use strict";

require("dotenv").config();

const fs = require("fs");
const path = require("path");

const { qdrant } = require("../qdrant_client");
const { runRetrieval } = require("./rag_adapter");

async function exportCollectionCatalog({ collectionName = "athlete_health_context", limit = 5000, outputPath }) {
    const allPoints = [];
    let offset = undefined;

    while (allPoints.length < limit) {
        const response = await qdrant.scroll(collectionName, {
            limit: Math.min(256, limit - allPoints.length),
            offset,
            with_payload: true,
            with_vector: false
        });

        const points = Array.isArray(response?.points) ? response.points : [];
        allPoints.push(...points.map((point) => ({
            id: String(point.id),
            issue: point.payload?.issue || null,
            allergies: point.payload?.allergies || [],
            dietary_restrictions: point.payload?.dietary_restrictions || [],
            contraindicated_foods: point.payload?.contraindicated_foods || [],
            contraindicated_exercises: point.payload?.contraindicated_exercises || []
        })));

        offset = response?.next_page_offset;
        if (!offset || points.length === 0) {
            break;
        }
    }

    if (outputPath) {
        fs.mkdirSync(path.dirname(path.resolve(outputPath)), { recursive: true });
        fs.writeFileSync(path.resolve(outputPath), `${JSON.stringify(allPoints, null, 2)}\n`, "utf8");
    }

    return allPoints;
}

async function buildLabelCandidates({ datasetPath, outputPath }) {
    const dataset = JSON.parse(fs.readFileSync(path.resolve(datasetPath), "utf8"));
    const candidates = [];

    for (const example of dataset) {
        const retrieval = await runRetrieval(example.searchQuery);
        candidates.push({
            id: example.id,
            question: example.question,
            searchQuery: example.searchQuery,
            topMatches: retrieval.results.map((result) => ({
                id: String(result.id),
                score: result.score,
                issue: result.payload?.issue || null,
                allergies: result.payload?.allergies || [],
                contraindicated_foods: result.payload?.contraindicated_foods || [],
                contraindicated_exercises: result.payload?.contraindicated_exercises || []
            }))
        });
    }

    if (outputPath) {
        fs.mkdirSync(path.dirname(path.resolve(outputPath)), { recursive: true });
        fs.writeFileSync(path.resolve(outputPath), `${JSON.stringify(candidates, null, 2)}\n`, "utf8");
    }

    return candidates;
}

module.exports = {
    buildLabelCandidates,
    exportCollectionCatalog
};
