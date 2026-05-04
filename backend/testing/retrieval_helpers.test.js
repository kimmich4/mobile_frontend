const {
    buildDietSearchQuery,
    buildWorkoutSearchQuery,
    formatVectorContext,
    rankRetrievedResults
} = require('../retrieval_helpers');

describe('retrieval helpers', () => {
    test('buildDietSearchQuery focuses on diet-relevant constraints', () => {
        const query = buildDietSearchQuery({
            healthConditions: 'type 2 diabetes',
            allergies: 'shellfish',
            injuries: 'knee pain',
            goals: 'fat loss',
            medicalReport: 'HbA1c elevated. Lower sodium choices.',
            inbodyReport: 'High body fat.'
        });

        expect(query).toContain('Medical conditions: type 2 diabetes');
        expect(query).toContain('Food allergies or restrictions: shellfish');
        expect(query).not.toContain('fat loss');
        expect(query).not.toContain('knee pain');
    });

    test('buildWorkoutSearchQuery focuses on movement-relevant constraints', () => {
        const query = buildWorkoutSearchQuery({
            healthConditions: 'exercise-induced asthma',
            allergies: 'shellfish',
            injuries: 'knee pain, avoid jumping',
            goals: 'build strength',
            experience: 'beginner',
            medicalReport: 'Use low-impact progressions.',
            inbodyReport: 'Low fitness score.'
        });

        expect(query).toContain('Medical conditions: exercise-induced asthma');
        expect(query).toContain('Injuries or movement restrictions: knee pain, avoid jumping');
        expect(query).toContain('Experience: beginner');
        expect(query).not.toContain('build strength');
        expect(query).not.toContain('shellfish');
    });

    test('formatVectorContext deduplicates useful payload fields and omits personal metadata', () => {
        const context = formatVectorContext([
            {
                id: 'doc-1',
                score: 0.9,
                payload: {
                    athlete_id: 'ATH001',
                    name: 'Private Name',
                    age: 42,
                    issue: 'Patellar Tendinopathy',
                    dietary_restrictions: ['Weight-management focus'],
                    allergies: ['Latex'],
                    contraindicated_foods: [{ food: 'Highly processed snacks', reason: 'Extra load' }],
                    contraindicated_exercises: [{ exercise: 'High-volume jumping drills', reason: 'Irritation' }]
                }
            },
            {
                payload: {
                    issue: 'Patellar Tendinopathy',
                    contraindicated_foods: [{ food: 'Highly processed snacks' }],
                    contraindicated_exercises: [{ exercise: 'Deep knee flexion under heavy load' }]
                }
            }
        ]);

        expect(context).toContain('Relevant issues: Patellar Tendinopathy');
        expect(context).toContain('Allergies: Latex');
        expect(context).toContain('Diet restrictions: Weight-management focus');
        expect(context).toContain('Foods to avoid (Highly processed snacks)');
        expect(context).toContain('Exercises to avoid (High-volume jumping drills, Deep knee flexion under heavy load)');
        expect(context).not.toContain('ATH001');
        expect(context).not.toContain('Private Name');
        expect(context).not.toContain('Extra load');
    });

    test('formatVectorContext only sends the top three retrieved cases', () => {
        const context = formatVectorContext([
            { payload: { issue: 'Case one', contraindicated_foods: [{ food: 'Food one' }] } },
            { payload: { issue: 'Case two', contraindicated_foods: [{ food: 'Food two' }] } },
            { payload: { issue: 'Case three', contraindicated_foods: [{ food: 'Food three' }] } },
            { payload: { issue: 'Case four', contraindicated_foods: [{ food: 'Food four' }] } }
        ]);

        expect(context).toContain('Case one');
        expect(context).toContain('Case two');
        expect(context).toContain('Case three');
        expect(context).not.toContain('Case four');
        expect(context).not.toContain('Food four');
    });

    test('rankRetrievedResults prioritizes payloads that match query terms before vector score', () => {
        const results = rankRetrievedResults([
            { score: 0.95, payload: { issue: 'Shoulder pain', contraindicated_exercises: [{ exercise: 'Overhead press' }] } },
            { score: 0.70, payload: { issue: 'Patellar Tendinopathy', contraindicated_exercises: [{ exercise: 'Jumping drills' }] } }
        ], 'knee patellar pain avoid jumping');

        expect(results[0].payload.issue).toBe('Patellar Tendinopathy');
    });
});
