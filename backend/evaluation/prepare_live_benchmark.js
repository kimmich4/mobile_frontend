"use strict";

const fs = require("fs");
const path = require("path");

const { runRetrieval } = require("./rag_adapter");

async function main() {
    const inputPath = path.resolve(process.argv[2] || "./evaluation/benchmark.dataset.json");
    const outputPath = path.resolve(process.argv[3] || "./evaluation/benchmark.live.dataset.json");
    const dataset = JSON.parse(fs.readFileSync(inputPath, "utf8"));

    const enriched = [];
    for (const example of dataset) {
        const retrieval = await runRetrieval(example.searchQuery);
        enriched.push({
            ...example,
            relevantDocumentIds: retrieval.results.map((result) => String(result.id)),
            metadata: {
                ...example.metadata,
                liveIssueMatches: retrieval.results.map((result) => result.payload?.issue || null)
            }
        });
    }

    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, `${JSON.stringify(enriched, null, 2)}\n`, "utf8");
    console.log(outputPath);
}

if (require.main === module) {
    main().catch((error) => {
        console.error(error.message);
        process.exit(1);
    });
}
