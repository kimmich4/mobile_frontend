require("dotenv").config();
const http = require('http');
const https = require('https');

async function testNetwork() {
    console.log("1. Testing raw HTTPS fetch to google.com...");
    try {
        const res = await fetch("https://www.google.com", { signal: AbortSignal.timeout(5000) });
        console.log("Google Ok: " + res.status);
    } catch (e) {
        console.error("Google Failed: " + e.message);
    }

    console.log("\n2. Testing raw HTTPS fetch to HuggingFace API...");
    try {
        const res = await fetch("https://api-inference.huggingface.co/models/gpt2", {
            method: "POST",
            headers: { "Authorization": `Bearer ${process.env.HF_API_KEY}` },
            body: JSON.stringify({ inputs: "test" }),
            signal: AbortSignal.timeout(5000)
        });
        console.log("HF Ok: " + res.status);
        const data = await res.json();
        console.log("HF Data:", JSON.stringify(data).substring(0, 50));
    } catch (e) {
        console.error("HF Failed: " + e.message);
    }
}

testNetwork();
