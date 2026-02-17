const { HfInference } = require("@huggingface/inference");
require("dotenv").config();

const hf = new HfInference(process.env.HF_API_KEY);

async function test() {
    console.log("Testing HF connection...");
    try {
        const start = Date.now();
        const result = await hf.textGeneration({
            model: "gpt2",
            inputs: "Hello",
            parameters: { max_new_tokens: 5 }
        });
        console.log("Success in " + (Date.now() - start) + "ms");
        console.log("Result:", result.generated_text);
    } catch (e) {
        console.error("Test failed:", e.message);
        console.error(e.stack);
    }
}

test();
