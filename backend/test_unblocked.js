require("dotenv").config();

async function testFetch() {
    console.log("Testing Unblocked Path via Native Fetch...");
    const model = "mistralai/Mistral-7B-Instruct-v0.3";
    const url = `https://huggingface.co/api/inference/models/${model}`;

    try {
        const res = await fetch(url, {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${process.env.HF_API_KEY}`,
                "Content-Type": "application/json",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
            },
            body: JSON.stringify({ inputs: "test" })
        });

        console.log("Status:", res.status);
        const data = await res.text();
        console.log("Data:", data.substring(0, 500));
    } catch (e) {
        console.error("Fetch Error:", e.message);
    }
}

testFetch();
