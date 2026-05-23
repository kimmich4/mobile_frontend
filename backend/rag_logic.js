require("dotenv").config();
const { HfInference } = require("@huggingface/inference");
const { qdrant } = require("./qdrant_client");

const hf = new HfInference(process.env.HF_API_KEY);

// helper: get embeddings (using hfinference)
async function getEmbedding(text) {
    const vector = await hf.featureExtraction({
        model: "sentence-transformers/all-MiniLM-L6-v2",
        inputs: text
    });

    if (!vector || !Array.isArray(vector)) {
        throw new Error("Embedding failed: No valid vector in response");
    }

    return vector.map(x => parseFloat(x));
}

// helper: query vector database (qdrant)
async function queryQdrant(vector, options = {}) {
    const limit = options.limit || 5;
    const scoreThreshold = options.scoreThreshold || 0.35;

    return await qdrant.search("athlete_health_context", {
        vector: vector,
        limit,
        with_payload: true,
        score_threshold: scoreThreshold
    });
}

module.exports = { getEmbedding, queryQdrant };
