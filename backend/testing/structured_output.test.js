const {
    extractContraindications,
    normalizeDietPlan,
    normalizeWorkoutPlan,
    enforceStructuredPlan
} = require('../structured_output');

describe('structured output normalization', () => {
    test('normalizes alternative diet root shape into days array', () => {
        const input = {
            "7_day_diet_plan": {
                Day_1: {
                    Breakfast: "Eggs",
                    Lunch: "Chicken Salad"
                },
                Day_2: {
                    Breakfast: "Oats"
                }
            }
        };

        const normalized = normalizeDietPlan(input, 'Target Daily Calories (adjusted for goal): 2000.');
        expect(Array.isArray(normalized.days)).toBe(true);
        expect(normalized.days[0].day).toBe(1);
        expect(normalized.days[0].totalCalories).toBe(2000);
        expect(normalized.days[0].meals[0].title).toBe('Breakfast');
    });

    test('normalizes alternative workout root shape into gym/home days arrays', () => {
        const input = {
            "7_day_exercise_plan": [
                {
                    gym_workout: [{ exercise: 'Bench Press', sets: '3', reps: '10' }],
                    home_workout: ['Push-ups (3x12)']
                }
            ]
        };

        const normalized = normalizeWorkoutPlan(input);
        expect(normalized.gym.title).toBe('Gym Workout Plan');
        expect(normalized.gym.days[0].exercises[0].name).toBe('Bench Press');
        expect(normalized.home.days[0].exercises[0].name).toBe('Push-ups');
    });

    test('extracts contraindications from resolved context', () => {
        const result = extractContraindications('Issue: X. Constraints: Foods to avoid (Sugar, Shellfish), Exercises to avoid (Deep bar dips, Upright rows)');
        expect(result.foods).toContain('sugar');
        expect(result.exercises).toContain('deep bar dips');
    });

    test('enforceStructuredPlan replaces direct contraindicated names', () => {
        const answer = JSON.stringify({
            "7_day_exercise_plan": [
                {
                    gym_workout: [{ exercise: 'Deep bar dips', sets: '3', reps: '8' }],
                    home_workout: []
                }
            ]
        });

        const normalized = JSON.parse(enforceStructuredPlan(
            answer,
            'Issue: Shoulder. Constraints: Foods to avoid (), Exercises to avoid (Deep bar dips)',
            'Create a 7-day exercise plan.'
        ));

        expect(normalized.gym.days[0].exercises[0].name).toContain('Safe substitute');
    });
});
