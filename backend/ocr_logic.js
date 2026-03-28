require("dotenv").config();

// 🔹 Helper: Analyze Image (OCR/Report Extraction)
async function analyzeImage(base64Image, type) {
    try {
        console.log(`🔍 Analyzing ${type} report using Llama 3.2 Vision (v4)...`);
        const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${process.env.OPENROUTER_API_KEY}`,
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                model: "meta-llama/Llama-3.2-11B-Vision-Instruct",
                max_tokens: 1000,
                messages: [
                    {
                        role: "system",
                        content: "You are a medical data extraction assistant. Extract clinical findings, biomarkers, and health constraints from the provided report image. Return a concise summary suitable for a nutritionist or trainer."
                    },
                    {
                        role: "user",
                        content: [
                            {
                                type: "text",
                                text: `Extract data from this ${type} report.`
                            },
                            {
                                type: "image_url",
                                image_url: {
                                    url: `data:image/jpeg;base64,${base64Image}`
                                }
                            }
                        ]
                    }
                ]
            })
        });

        if (!response.ok) {
            const err = await response.text();
            throw new Error(`Vision API Error: ${response.status} - ${err}`);
        }

        const data = await response.json();
        const extractedText = data.choices?.[0]?.message?.content || "No data extracted.";

        console.log(`✅ Extracted Text from ${type} report:`);
        console.log("-----------------------------------------");
        console.log(extractedText);
        console.log("-----------------------------------------");

        return extractedText;
    } catch (e) {
        console.error("Image Analysis failed:", e.message);
        return `Error extracting ${type} report: ${e.message}`;
    }
}

module.exports = { analyzeImage };
