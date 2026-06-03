require("dotenv").config();
const { QdrantClient } = require("@qdrant/js-client-rest");

// shared singleton - import everywhere instead of creating a new client
const qdrant = new QdrantClient({
    url: process.env.QDRANT_URL,
    apiKey: process.env.QDRANT_API_KEY
});

module.exports = { qdrant };
