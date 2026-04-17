"use strict";

const { runEvaluation } = require("./runner");

function parseArgs(argv) {
    const args = {
        datasetPath: null,
        outputPath: null,
        mode: "full",
        judge: "none",
        topK: 3,
        compareAgainstBaseline: true
    };

    for (let index = 0; index < argv.length; index += 1) {
        const token = argv[index];
        const next = argv[index + 1];

        if (token === "--dataset" && next) {
            args.datasetPath = next;
            index += 1;
        } else if (token === "--output" && next) {
            args.outputPath = next;
            index += 1;
        } else if (token === "--mode" && next) {
            args.mode = next;
            index += 1;
        } else if (token === "--judge" && next) {
            args.judge = next;
            index += 1;
        } else if (token === "--top-k" && next) {
            args.topK = Number(next);
            index += 1;
        } else if (token === "--no-baseline") {
            args.compareAgainstBaseline = false;
        }
    }

    if (!args.datasetPath) {
        throw new Error("Missing required argument: --dataset <path>");
    }

    if (!["full", "retrieval"].includes(args.mode)) {
        throw new Error(`Unsupported mode "${args.mode}". Use "full" or "retrieval".`);
    }

    if (!["none", "llm"].includes(args.judge)) {
        throw new Error(`Unsupported judge "${args.judge}". Use "none" or "llm".`);
    }

    if (!Number.isFinite(args.topK) || args.topK <= 0) {
        throw new Error("--top-k must be a positive number");
    }

    return args;
}

function printSummary(report) {
    const summary = report.summary;
    console.log("\nRAG Evaluation Summary");
    console.log("======================");
    console.log(`Examples: ${summary.totalExamples}`);
    console.log(`Recall@${report.topK}: ${formatMetric(summary.retrieval.recallAtK)}`);
    console.log(`Precision@${report.topK}: ${formatMetric(summary.retrieval.precisionAtK)}`);
    console.log(`MRR: ${formatMetric(summary.retrieval.mrr)}`);

    if (report.mode !== "retrieval") {
        console.log(`RAG Exact Match: ${formatMetric(summary.generation.exactMatch)}`);
        console.log(`RAG F1: ${formatMetric(summary.generation.f1)}`);
        console.log(`RAG Faithfulness: ${formatMetric(summary.generation.faithfulness)}`);
        console.log(`RAG Requirement Coverage: ${formatMetric(summary.generation.requirementCoverage)}`);
        console.log(`RAG JSON Validity: ${formatMetric(summary.generation.jsonValidity)}`);
        console.log(`RAG Structure Score: ${formatMetric(summary.generation.structureScore)}`);

        if (summary.baseline) {
            console.log(`Baseline F1: ${formatMetric(summary.baseline.f1)}`);
            console.log(`Baseline Faithfulness: ${formatMetric(summary.baseline.faithfulness)}`);
            console.log(`Baseline Requirement Coverage: ${formatMetric(summary.baseline.requirementCoverage)}`);
            console.log(`F1 Delta (RAG - Baseline): ${formatMetric(summary.comparison.f1Delta)}`);
            console.log(`Faithfulness Delta (RAG - Baseline): ${formatMetric(summary.comparison.faithfulnessDelta)}`);
            console.log(`Requirement Coverage Delta (RAG - Baseline): ${formatMetric(summary.comparison.requirementCoverageDelta)}`);
        }

        if (report.judge === "llm") {
            console.log(`RAG Judge Correctness: ${formatMetric(summary.generation.llmJudgeCorrectness)}`);
            console.log(`RAG Judge Faithfulness: ${formatMetric(summary.generation.llmJudgeFaithfulness)}`);
            if (summary.baseline) {
                console.log(`Baseline Judge Correctness: ${formatMetric(summary.baseline.llmJudgeCorrectness)}`);
                console.log(`Baseline Judge Faithfulness: ${formatMetric(summary.baseline.llmJudgeFaithfulness)}`);
            }
        }
    }
}

function formatMetric(value) {
    return typeof value === "number" ? value.toFixed(4) : "n/a";
}

async function main() {
    const args = parseArgs(process.argv.slice(2));
    const report = await runEvaluation(args);
    printSummary(report);

    if (args.outputPath) {
        console.log(`Report written to ${args.outputPath}`);
    }
}

if (require.main === module) {
    main().catch((error) => {
        console.error(error.message);
        process.exit(1);
    });
}

module.exports = {
    parseArgs
};
