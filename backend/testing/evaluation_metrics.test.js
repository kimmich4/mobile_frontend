const {
    exactMatch,
    f1Score,
    faithfulnessScore,
    meanReciprocalRank,
    planGroundingScore,
    precisionAtK,
    recallAtK,
    restrictionAdherenceScore
} = require('../evaluation/metrics');

describe('evaluation metrics', () => {
    test('exactMatch normalizes case and punctuation', () => {
        expect(exactMatch('High Sugar.', 'high sugar')).toBe(1);
    });

    test('f1Score returns partial overlap', () => {
        const score = f1Score('avoid sugar and soda', 'avoid sugar');
        expect(score).toBeGreaterThan(0.6);
        expect(score).toBeLessThan(1);
    });

    test('retrieval metrics use relevant ids', () => {
        const results = [{ id: 'a' }, { id: 'b' }, { id: 'c' }];
        expect(recallAtK(results, ['b', 'z'], 2)).toBe(0.5);
        expect(precisionAtK(results, ['b', 'z'], 2)).toBe(0.5);
        expect(meanReciprocalRank(results, ['b', 'z'])).toBe(0.5);
    });

    test('faithfulnessScore evaluates structured claims instead of the whole JSON blob', () => {
        const faithfulness = faithfulnessScore(
            JSON.stringify({
                days: [
                    {
                        day: 1,
                        meals: [
                            { title: 'Breakfast', items: [{ name: 'Avoid sugar for diabetes.', calories: 400 }] }
                        ]
                    }
                ]
            }),
            ['Issue: Diabetes. Constraints: Foods to avoid (Sugar), Exercises to avoid ()'],
            0.2
        );

        expect(faithfulness.score).toBeGreaterThan(0);
        expect(faithfulness.totalClaims).toBeGreaterThan(0);
    });

    test('restrictionAdherenceScore penalizes explicit contraindication violations', () => {
        const score = restrictionAdherenceScore(
            {
                metadata: { route: '/ai/generate-diet', allergy: 'shellfish' },
                groundTruthAnswer: '{"requirements":["7 days","no shellfish"]}'
            },
            JSON.stringify({
                days: [
                    { day: 1, meals: [{ items: [{ name: 'Grilled shrimp bowl' }] }] }
                ]
            }),
            []
        );

        expect(score.score).toBeLessThan(1);
        expect(score.violations.length).toBeGreaterThan(0);
    });

    test('planGroundingScore rewards safety-compliant structured plans', () => {
        const score = planGroundingScore(
            {
                metadata: { route: '/ai/generate-diet', condition: 'type 2 diabetes' },
                groundTruthAnswer: '{"requirements":["7 days","avoid sugar","blood-sugar-aware meal choices"]}'
            },
            JSON.stringify({
                days: [
                    {
                        day: 1,
                        meals: [
                            { title: 'Breakfast', items: [{ name: 'Eggs with spinach and oats' }] },
                            { title: 'Snack', items: [{ name: 'Greek yogurt unsweetened' }] }
                        ]
                    }
                ],
                notes: ['Avoid sugar and prioritize steady-energy meals']
            }),
            [
                {
                    payload: {
                        contraindicated_foods: [{ food: 'Sugary soft drinks' }],
                        dietary_restrictions: ['Low added sugar focus']
                    }
                }
            ],
            ['Issue: Type 2 Diabetes. Constraints: Foods to avoid (Sugary soft drinks), Exercises to avoid ()']
        );

        expect(score.score).toBeGreaterThan(0.6);
        expect(score.restrictionAdherence.score).toBe(1);
    });
});
