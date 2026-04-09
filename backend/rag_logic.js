require("dotenv").config();
const { HfInference } = require("@huggingface/inference");
const { qdrant } = require("./qdrant_client");

const hf = new HfInference(process.env.HF_API_KEY);

// 🔹 Helper: Get Embeddings (Using HfInference)
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

// 🔹 Helper: Query Vector Database (Qdrant)
async function queryQdrant(vector) {
    return await qdrant.search("athlete_health_context", {
        vector: vector,
        limit: 3,
        with_payload: true,
        score_threshold: 0.300
    });
}

module.exports = { getEmbedding, queryQdrant };
