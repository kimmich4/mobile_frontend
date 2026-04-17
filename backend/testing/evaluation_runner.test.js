jest.mock('../evaluation/rag_adapter', () => ({
    runBaselineGeneration: jest.fn(),
    resultToContext: jest.fn((result) => result.payload.text),
    runRetrieval: jest.fn(),
    runGeneration: jest.fn()
}));

const { runBaselineGeneration, runRetrieval, runGeneration } = require('../evaluation/rag_adapter');
const { evaluateExample, summarizeResults } = require('../evaluation/runner');

describe('evaluation runner', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    test('evaluateExample computes restriction-aware generation metrics', async () => {
        runRetrieval.mockResolvedValue({
            results: [
                {
                    id: 'doc-1',
                    score: 0.9,
                    payload: {
                        text: 'Avoid sugar for diabetes.',
                        contraindicated_foods: [{ food: 'Sugary soft drinks' }]
                    }
                },
                { id: 'doc-2', score: 0.7, payload: { text: 'General hydration advice.' } }
            ]
        });

        runGeneration.mockResolvedValue({
            answer: JSON.stringify({
                days: Array.from({ length: 7 }, (_, index) => ({
                    day: index + 1,
                    totalCalories: 2000,
                    meals: [{ title: 'Meal', items: [{ name: 'Avoid sugar for diabetes.', calories: 400 }] }]
                })),
                notes: ['Avoid sugar for diabetes.']
            })
        });
        runBaselineGeneration.mockResolvedValue({
            answer: JSON.stringify({
                days: Array.from({ length: 7 }, (_, index) => ({
                    day: index + 1,
                    totalCalories: 2000,
                    meals: [{ title: 'Meal', items: [{ name: 'Sugary soft drinks', calories: 400 }] }]
                }))
            })
        });

        const result = await evaluateExample({
            id: 'ex-1',
            question: 'What should a diabetic athlete avoid?',
            task: 'Answer the question.',
            searchQuery: 'Diabetes',
            contextPrefix: '{{VECTOR_CONTEXT}}',
            groundTruthAnswer: '{"requirements":["7 days","avoid sugar for diabetes"]}',
            relevantDocumentIds: ['doc-1'],
            metadata: { route: '/ai/generate-diet', condition: 'type 2 diabetes' }
        }, { mode: 'full', judge: 'none', topK: 2 });

        expect(result.retrievalMetrics.recallAtK).toBe(1);
        expect(result.retrievalMetrics.mrr).toBe(1);
        expect(result.answerMetrics.f1).toBeGreaterThan(0);
        expect(result.answerMetrics.faithfulness).toBeGreaterThanOrEqual(0);
        expect(result.answerMetrics.restrictionAdherence).toBe(1);
        expect(result.answerMetrics.planGrounding).toBeGreaterThan(0.5);
        expect(result.answerMetrics.overallScore).toBeGreaterThan(0.7);
        expect(result.answerMetrics.jsonValidity).toBe(1);
        expect(result.answerMetrics.structureScore).toBe(1);
        expect(result.answerMetrics.planGrounding).toBeGreaterThan(result.baseline.answerMetrics.planGrounding);
    });

    test('summarizeResults averages new safety-focused metrics', () => {
        const summary = summarizeResults([
            {
                retrievalMetrics: { recallAtK: 1, precisionAtK: 0.5, mrr: 1 },
                answerMetrics: {
                    exactMatch: 1,
                    f1: 0.8,
                    faithfulness: 0.9,
                    requirementCoverage: 0.8,
                    restrictionAdherence: 1,
                    planGrounding: 0.9,
                    overallScore: 0.92,
                    jsonValidity: 1,
                    structureScore: 0.9
                },
                baseline: {
                    answerMetrics: {
                        exactMatch: 0,
                        f1: 0.5,
                        faithfulness: 0.4,
                        requirementCoverage: 0.5,
                        restrictionAdherence: 0.5,
                        planGrounding: 0.45,
                        overallScore: 0.5,
                        jsonValidity: 1,
                        structureScore: 0.5
                    }
                }
            },
            {
                retrievalMetrics: { recallAtK: 0, precisionAtK: 0, mrr: 0 },
                answerMetrics: {
                    exactMatch: 0,
                    f1: 0.2,
                    faithfulness: 0.1,
                    requirementCoverage: 0.3,
                    restrictionAdherence: 0.8,
                    planGrounding: 0.4,
                    overallScore: 0.55,
                    jsonValidity: 0,
                    structureScore: 0.1
                },
                baseline: {
                    answerMetrics: {
                        exactMatch: 0,
                        f1: 0.1,
                        faithfulness: 0.05,
                        requirementCoverage: 0.2,
                        restrictionAdherence: 0.6,
                        planGrounding: 0.2,
                        overallScore: 0.3,
                        jsonValidity: 0,
                        structureScore: 0.0
                    }
                }
            }
        ]);

        expect(summary.retrieval.recallAtK).toBe(0.5);
        expect(summary.generation.f1).toBeCloseTo(0.5, 5);
        expect(summary.generation.restrictionAdherence).toBeCloseTo(0.9, 5);
        expect(summary.generation.planGrounding).toBeCloseTo(0.65, 5);
        expect(summary.generation.overallScore).toBeCloseTo(0.735, 5);
        expect(summary.baseline.restrictionAdherence).toBeCloseTo(0.55, 5);
        expect(summary.comparison.restrictionAdherenceDelta).toBeCloseTo(0.35, 5);
        expect(summary.comparison.overallScoreDelta).toBeCloseTo(0.335, 5);
    });
});
