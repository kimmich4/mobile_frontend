"use strict";

const fs = require("fs");
const path = require("path");

function loadDataset(datasetPath) {
    const absolutePath = path.resolve(datasetPath);
    const raw = fs.readFileSync(absolutePath, "utf8");
    const parsed = JSON.parse(raw);

    if (!Array.isArray(parsed)) {
        throw new Error("Dataset file must contain a JSON array");
    }

    return parsed.map((item, index) => validateExample(item, index));
}

function validateExample(item, index) {
    if (!item || typeof item !== "object") {
        throw new Error(`Dataset item at index ${index} must be an object`);
    }

    const id = item.id || `example-${index + 1}`;
    const question = item.question || item.task;
    const task = item.task || item.question;

    if (!question) {
        throw new Error(`Dataset item "${id}" is missing "question" or "task"`);
    }

    if (!task) {
        throw new Error(`Dataset item "${id}" is missing "task"`);
    }

    return {
        id,
        question,
        task,
        searchQuery: item.searchQuery || "",
        contextPrefix: item.contextPrefix || "{{VECTOR_CONTEXT}}",
        groundTruthAnswer: item.groundTruthAnswer || "",
        relevantDocumentIds: Array.isArray(item.relevantDocumentIds) ? item.relevantDocumentIds : [],
        metadata: item.metadata || {}
    };
}

function ensureDirectoryForFile(filePath) {
    const directory = path.dirname(path.resolve(filePath));
    fs.mkdirSync(directory, { recursive: true });
}

function writeJson(filePath, data) {
    ensureDirectoryForFile(filePath);
    fs.writeFileSync(path.resolve(filePath), `${JSON.stringify(data, null, 2)}\n`, "utf8");
}

module.exports = {
    loadDataset,
    writeJson
};
