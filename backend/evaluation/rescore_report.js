"use strict";

const fs = require("fs");
const path = require("path");

const {
    average,
    exactMatch,
    f1Score,
    faithfulnessScore,
    overallPlanScore,
    planGroundingScore,
    requirementCoverageScore,
    restrictionAdherenceScore
} = require("./metrics");

function safeJsonParse(text) {
    try {
        return {
            valid: true,
            value: JSON.parse(text)
        };
    } catch (error) {
        return {
            valid: false,
            value: null,
            error: error.message
        };
    }
}

function inferRouteType(example) {
    const route = example.metadata?.route || "";
    if (route.includes("generate-diet")) {
        return "diet";
    }
    if (route.includes("generate-workout")) {
        return "workout";
    }
    return "generic";
}

function evaluateDietStructure(parsed) {
    if (!parsed || !Array.isArray(parsed.days)) {
        return { score: 0, issues: ["Missing days array"] };
    }

    const issues = [];
    if (parsed.days.length !== 7) {
        issues.push(`Expected 7 days, got ${parsed.days.length}`);
    }
    for (const day of parsed.days) {
        if (!Array.isArray(day?.meals) || day.meals.length === 0) {
            issues.push(`Day ${day?.day ?? "unknown"} has no meals`);
        }
        if (typeof day?.totalCalories !== "number") {
            issues.push(`Day ${day?.day ?? "unknown"} is missing numeric totalCalories`);
        }
    }

    return {
        score: issues.length === 0 ? 1 : Math.max(0, 1 - (issues.length / Math.max(parsed.days.length, 7))),
        issues
    };
}

function evaluateWorkoutStructure(parsed) {
    const issues = [];
    for (const key of ["gym", "home"]) {
        if (!parsed?.[key] || !Array.isArray(parsed[key].days)) {
            issues.push(`Missing ${key}.days array`);
            continue;
        }

        if (parsed[key].days.length !== 7) {
            issues.push(`${key}.days expected 7 items, got ${parsed[key].days.length}`);
        }

        for (const day of parsed[key].days) {
            if (!Array.isArray(day?.exercises) || day.exercises.length === 0) {
                issues.push(`${key} day ${day?.day ?? "unknown"} has no exercises`);
            }
        }
    }

    return {
        score: issues.length === 0 ? 1 : Math.max(0, 1 - (issues.length / 14)),
        issues
    };
}

function evaluateStructure(example, answer) {
    const parsed = safeJsonParse(answer);
    if (!parsed.valid) {
        return {
            jsonValidity: 0,
            structureScore: 0,
            structureIssues: [parsed.error]
        };
    }

    const routeType = inferRouteType(example);
    let structure = { score: 1, issues: [] };
    if (routeType === "diet") {
        structure = evaluateDietStructure(parsed.value);
    } else if (routeType === "workout") {
        structure = evaluateWorkoutStructure(parsed.value);
    }

    return {
        jsonValidity: 1,
        structureScore: structure.score,
        structureIssues: structure.issues
    };
}

function resultToContext(result) {
    const payload = result?.payload || {};
    if (typeof payload.text === "string" && payload.text.trim()) {
        return payload.text.trim();
    }

    const foods = Array.isArray(payload.contraindicated_foods)
        ? payload.contraindicated_foods.map((item) => item.food).filter(Boolean)
        : [];
    const exercises = Array.isArray(payload.contraindicated_exercises)
        ? payload.contraindicated_exercises.map((item) => item.exercise).filter(Boolean)
        : [];
    return `Issue: ${payload.issue || "N/A"}. Constraints: Foods to avoid (${foods.join(", ")}), Exercises to avoid (${exercises.join(", ")})`;
}

function scoreAnswer(example, answer, retrievalContexts, retrievalResults) {
    const faithfulness = faithfulnessScore(answer, retrievalContexts, 0.2);
    const requirementCoverage = requirementCoverageScore(example.groundTruthAnswer, answer);
    const restrictionAdherence = restrictionAdherenceScore(example, answer, retrievalResults);
    const planGrounding = planGroundingScore(example, answer, retrievalResults, retrievalContexts);
    const structure = evaluateStructure(example, answer);

    const metrics = {
        exactMatch: exactMatch(example.groundTruthAnswer, answer),
        f1: f1Score(example.groundTruthAnswer, answer),
        faithfulness: faithfulness.score,
        faithfulnessDetails: faithfulness,
        requirementCoverage: requirementCoverage?.score ?? null,
        requirementCoverageDetails: requirementCoverage,
        restrictionAdherence: restrictionAdherence.score,
        restrictionAdherenceDetails: restrictionAdherence,
        planGrounding: planGrounding.score,
        planGroundingDetails: planGrounding,
        jsonValidity: structure.jsonValidity,
        structureScore: structure.structureScore,
        structureIssues: structure.structureIssues
    };
    metrics.overallScore = overallPlanScore(metrics);
    return metrics;
}

function delta(current, baseline) {
    if (typeof current !== "number" || typeof baseline !== "number") {
        return null;
    }
    return current - baseline;
}

function summarize(examples) {
    const summary = {
        totalExamples: examples.length,
        retrieval: {
            recallAtK: average(examples.map((item) => item.retrievalMetrics?.recallAtK)),
            precisionAtK: average(examples.map((item) => item.retrievalMetrics?.precisionAtK)),
            mrr: average(examples.map((item) => item.retrievalMetrics?.mrr))
        },
        generation: {
            exactMatch: average(examples.map((item) => item.answerMetrics?.exactMatch)),
            f1: average(examples.map((item) => item.answerMetrics?.f1)),
            faithfulness: average(examples.map((item) => item.answerMetrics?.faithfulness)),
            requirementCoverage: average(examples.map((item) => item.answerMetrics?.requirementCoverage)),
            restrictionAdherence: average(examples.map((item) => item.answerMetrics?.restrictionAdherence)),
            planGrounding: average(examples.map((item) => item.answerMetrics?.planGrounding)),
            overallScore: average(examples.map((item) => item.answerMetrics?.overallScore)),
            jsonValidity: average(examples.map((item) => item.answerMetrics?.jsonValidity)),
            structureScore: average(examples.map((item) => item.answerMetrics?.structureScore)),
            llmJudgeCorrectness: average(examples.map((item) => item.judge?.correctness?.score)),
            llmJudgeFaithfulness: average(examples.map((item) => item.judge?.faithfulness?.score))
        }
    };

    const baselineExamples = examples.filter((item) => item.baseline?.answerMetrics);
    if (baselineExamples.length > 0) {
        summary.baseline = {
            exactMatch: average(baselineExamples.map((item) => item.baseline?.answerMetrics?.exactMatch)),
            f1: average(baselineExamples.map((item) => item.baseline?.answerMetrics?.f1)),
            faithfulness: average(baselineExamples.map((item) => item.baseline?.answerMetrics?.faithfulness)),
            requirementCoverage: average(baselineExamples.map((item) => item.baseline?.answerMetrics?.requirementCoverage)),
            restrictionAdherence: average(baselineExamples.map((item) => item.baseline?.answerMetrics?.restrictionAdherence)),
            planGrounding: average(baselineExamples.map((item) => item.baseline?.answerMetrics?.planGrounding)),
            overallScore: average(baselineExamples.map((item) => item.baseline?.answerMetrics?.overallScore)),
            jsonValidity: average(baselineExamples.map((item) => item.baseline?.answerMetrics?.jsonValidity)),
            structureScore: average(baselineExamples.map((item) => item.baseline?.answerMetrics?.structureScore)),
            llmJudgeCorrectness: average(baselineExamples.map((item) => item.baseline?.judge?.correctness?.score)),
            llmJudgeFaithfulness: average(baselineExamples.map((item) => item.baseline?.judge?.faithfulness?.score))
        };

        summary.comparison = {
            exactMatchDelta: delta(summary.generation.exactMatch, summary.baseline.exactMatch),
            f1Delta: delta(summary.generation.f1, summary.baseline.f1),
            faithfulnessDelta: delta(summary.generation.faithfulness, summary.baseline.faithfulness),
            requirementCoverageDelta: delta(summary.generation.requirementCoverage, summary.baseline.requirementCoverage),
            restrictionAdherenceDelta: delta(summary.generation.restrictionAdherence, summary.baseline.restrictionAdherence),
            planGroundingDelta: delta(summary.generation.planGrounding, summary.baseline.planGrounding),
            overallScoreDelta: delta(summary.generation.overallScore, summary.baseline.overallScore),
            jsonValidityDelta: delta(summary.generation.jsonValidity, summary.baseline.jsonValidity),
            structureScoreDelta: delta(summary.generation.structureScore, summary.baseline.structureScore),
            llmJudgeCorrectnessDelta: delta(summary.generation.llmJudgeCorrectness, summary.baseline.llmJudgeCorrectness),
            llmJudgeFaithfulnessDelta: delta(summary.generation.llmJudgeFaithfulness, summary.baseline.llmJudgeFaithfulness)
        };
    }

    return summary;
}

function main() {
    const reportPath = path.resolve(process.argv[2]);
    const datasetPath = path.resolve(process.argv[3]);
    const outputPath = path.resolve(process.argv[4] || process.argv[2]);

    const report = JSON.parse(fs.readFileSync(reportPath, "utf8"));
    const dataset = JSON.parse(fs.readFileSync(datasetPath, "utf8"));
    const datasetById = new Map(dataset.map((item) => [item.id, item]));

    const rescoredExamples = report.examples.map((example) => {
        const datasetExample = datasetById.get(example.id) || {};
        const retrievalResults = example.retrieved || [];
        const retrievalContexts = retrievalResults.map(resultToContext);
        const answerMetrics = scoreAnswer(datasetExample, example.answer || "", retrievalContexts, retrievalResults);
        const baselineAnswerMetrics = example.baseline?.answer
            ? scoreAnswer(datasetExample, example.baseline.answer, [], [])
            : example.baseline?.answerMetrics;

        return {
            ...example,
            metadata: datasetExample.metadata || example.metadata || {},
            answerMetrics,
            baseline: example.baseline
                ? {
                    ...example.baseline,
                    answerMetrics: baselineAnswerMetrics
                }
                : example.baseline,
            comparison: example.baseline
                ? {
                    exactMatchDelta: delta(answerMetrics.exactMatch, baselineAnswerMetrics?.exactMatch),
                    f1Delta: delta(answerMetrics.f1, baselineAnswerMetrics?.f1),
                    faithfulnessDelta: delta(answerMetrics.faithfulness, baselineAnswerMetrics?.faithfulness),
                    requirementCoverageDelta: delta(answerMetrics.requirementCoverage, baselineAnswerMetrics?.requirementCoverage),
                    restrictionAdherenceDelta: delta(answerMetrics.restrictionAdherence, baselineAnswerMetrics?.restrictionAdherence),
                    planGroundingDelta: delta(answerMetrics.planGrounding, baselineAnswerMetrics?.planGrounding),
                    overallScoreDelta: delta(answerMetrics.overallScore, baselineAnswerMetrics?.overallScore),
                    jsonValidityDelta: delta(answerMetrics.jsonValidity, baselineAnswerMetrics?.jsonValidity),
                    structureScoreDelta: delta(answerMetrics.structureScore, baselineAnswerMetrics?.structureScore),
                    llmJudgeCorrectnessDelta: delta(example.judge?.correctness?.score, example.baseline?.judge?.correctness?.score),
                    llmJudgeFaithfulnessDelta: delta(example.judge?.faithfulness?.score, example.baseline?.judge?.faithfulness?.score)
                }
                : example.comparison
        };
    });

    const rescoredReport = {
        ...report,
        datasetPath,
        summary: summarize(rescoredExamples),
        examples: rescoredExamples,
        rescoredAt: new Date().toISOString()
    };

    fs.writeFileSync(outputPath, `${JSON.stringify(rescoredReport, null, 2)}\n`, "utf8");
    console.log(outputPath);
}

if (require.main === module) {
    try {
        main();
    } catch (error) {
        console.error(error.message);
        process.exit(1);
    }
}
