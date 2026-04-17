"use strict";

const path = require("path");

const { loadDataset, writeJson } = require("./dataset");
const { judgeAnswerCorrectness, judgeFaithfulness } = require("./judge");
const {
    average,
    exactMatch,
    f1Score,
    faithfulnessScore,
    meanReciprocalRank,
    overallPlanScore,
    planGroundingScore,
    precisionAtK,
    recallAtK,
    requirementCoverageScore,
    restrictionAdherenceScore
} = require("./metrics");
const { resultToContext, runBaselineGeneration, runGeneration, runRetrieval } = require("./rag_adapter");

function safeJsonParse(text) {
    try {
        return {
            valid: true,
            value: JSON.parse(text)
        };
    } catch (error) {
        return {
            valid: false,
            error: error.message,
            value: null
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
    const routeType = inferRouteType(example);

    if (!parsed.valid) {
        return {
            jsonValidity: 0,
            structureScore: 0,
            structureIssues: [parsed.error]
        };
    }

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

function buildAnswerMetrics(example, answer, retrievalContexts, retrievalResults) {
    const deterministicFaithfulness = faithfulnessScore(answer, retrievalContexts, 0.2);
    const requirementCoverage = requirementCoverageScore(example.groundTruthAnswer, answer);
    const restrictionAdherence = restrictionAdherenceScore(example, answer, retrievalResults);
    const planGrounding = planGroundingScore(example, answer, retrievalResults, retrievalContexts);
    const structure = evaluateStructure(example, answer);

    const metrics = {
        exactMatch: exactMatch(example.groundTruthAnswer, answer),
        f1: f1Score(example.groundTruthAnswer, answer),
        faithfulness: deterministicFaithfulness.score,
        faithfulnessDetails: deterministicFaithfulness,
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

async function evaluateExample(example, options = {}) {
    const topK = Number.isFinite(options.topK) ? options.topK : 3;
    const useLlmJudge = options.judge === "llm";
    const includeBaseline = options.compareAgainstBaseline !== false;

    const retrieval = await runRetrieval(example.searchQuery);
    const retrievalContexts = retrieval.results.map(resultToContext);

    const retrievalMetrics = {
        recallAtK: recallAtK(retrieval.results, example.relevantDocumentIds, topK),
        precisionAtK: precisionAtK(retrieval.results, example.relevantDocumentIds, topK),
        mrr: meanReciprocalRank(retrieval.results, example.relevantDocumentIds)
    };

    let answer = null;
    let answerMetrics = null;
    let judge = null;
    let baseline = null;

    if (options.mode !== "retrieval") {
        const generated = await runGeneration({
            searchQuery: example.searchQuery,
            contextPrefix: example.contextPrefix,
            task: example.task,
            retrieval
        });

        answer = generated.answer;
        answerMetrics = buildAnswerMetrics(example, answer, retrievalContexts, retrieval.results);

        if (useLlmJudge) {
            judge = {
                correctness: await judgeAnswerCorrectness({
                    question: example.question,
                    groundTruthAnswer: example.groundTruthAnswer,
                    modelAnswer: answer
                }),
                faithfulness: await judgeFaithfulness({
                    question: example.question,
                    contexts: retrievalContexts,
                    modelAnswer: answer
                })
            };
        }

        if (includeBaseline) {
            const baselineGenerated = await runBaselineGeneration({
                contextPrefix: example.contextPrefix,
                task: example.task
            });

            baseline = {
                answer: baselineGenerated.answer,
                answerMetrics: buildAnswerMetrics(example, baselineGenerated.answer, [], []),
                judge: null
            };

            if (useLlmJudge) {
                baseline.judge = {
                    correctness: await judgeAnswerCorrectness({
                        question: example.question,
                        groundTruthAnswer: example.groundTruthAnswer,
                        modelAnswer: baselineGenerated.answer
                    }),
                    faithfulness: await judgeFaithfulness({
                        question: example.question,
                        contexts: [],
                        modelAnswer: baselineGenerated.answer
                    })
                };
            }
        }
    }

    return {
        id: example.id,
        question: example.question,
        searchQuery: example.searchQuery,
        relevantDocumentIds: example.relevantDocumentIds,
        metadata: example.metadata || {},
        retrieved: retrieval.results.map((result) => ({
            id: result?.id ?? result?.payload?.id ?? result?.payload?.doc_id ?? null,
            score: result?.score ?? null,
            payload: result?.payload || {}
        })),
        retrievalMetrics,
        answer,
        answerMetrics,
        judge,
        baseline
    };
}

function summarizeResults(examples) {
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

function delta(current, baseline) {
    if (typeof current !== "number" || typeof baseline !== "number") {
        return null;
    }
    return current - baseline;
}

function addComparisonBlock(report) {
    if (!report.summary.baseline) {
        return report;
    }

    report.examples = report.examples.map((example) => {
        if (!example.baseline?.answerMetrics || !example.answerMetrics) {
            return example;
        }

        return {
            ...example,
            comparison: {
                exactMatchDelta: delta(example.answerMetrics.exactMatch, example.baseline.answerMetrics.exactMatch),
                f1Delta: delta(example.answerMetrics.f1, example.baseline.answerMetrics.f1),
                faithfulnessDelta: delta(example.answerMetrics.faithfulness, example.baseline.answerMetrics.faithfulness),
                requirementCoverageDelta: delta(example.answerMetrics.requirementCoverage, example.baseline.answerMetrics.requirementCoverage),
                restrictionAdherenceDelta: delta(example.answerMetrics.restrictionAdherence, example.baseline.answerMetrics.restrictionAdherence),
                planGroundingDelta: delta(example.answerMetrics.planGrounding, example.baseline.answerMetrics.planGrounding),
                overallScoreDelta: delta(example.answerMetrics.overallScore, example.baseline.answerMetrics.overallScore),
                jsonValidityDelta: delta(example.answerMetrics.jsonValidity, example.baseline.answerMetrics.jsonValidity),
                structureScoreDelta: delta(example.answerMetrics.structureScore, example.baseline.answerMetrics.structureScore),
                llmJudgeCorrectnessDelta: delta(example.judge?.correctness?.score, example.baseline.judge?.correctness?.score),
                llmJudgeFaithfulnessDelta: delta(example.judge?.faithfulness?.score, example.baseline.judge?.faithfulness?.score)
            }
        };
    });

    return report;
}

async function runEvaluation(options) {
    const dataset = loadDataset(options.datasetPath);
    const examples = [];

    for (const item of dataset) {
        examples.push(await evaluateExample(item, options));
    }

    const report = {
        generatedAt: new Date().toISOString(),
        datasetPath: path.resolve(options.datasetPath),
        mode: options.mode,
        judge: options.judge,
        topK: options.topK,
        summary: summarizeResults(examples),
        examples
    };
    addComparisonBlock(report);

    if (options.outputPath) {
        writeJson(options.outputPath, report);
    }

    return report;
}

module.exports = {
    evaluateExample,
    runEvaluation,
    summarizeResults
};
