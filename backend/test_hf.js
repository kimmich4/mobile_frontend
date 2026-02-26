require("dotenv").config();
const { HfInference } = require("@huggingface/inference");

async function test() {
    const text = 'Health conditions: None';

    // Test the direct API endpoint since router /v1/embeddings fails for feature extraction
    console.log("Testing direct API endpoint...");
    try {
        const res = await fetch('https://api-inference.huggingface.co/pipeline/feature-extraction/sentence-transformers/all-MiniLM-L6-v2', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${process.env.HF_API_KEY}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ inputs: text })
        });

        console.log("Status:", res.status);
        const data = await res.json();
        console.log("Data shape:", Array.isArray(data) ? `Array[${data.length}]` : typeof data);
    } catch (e) {
        console.error("Error:", e);
    }
}
test();
