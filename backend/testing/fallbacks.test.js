const { defaultDietPlan, defaultWorkoutPlan } = require('../fallbacks');

describe('Fallback Plans', () => {
    test('defaultDietPlan should have 7 days', () => {
        expect(defaultDietPlan.days.length).toBe(7);
        expect(defaultDietPlan.days[0].day).toBe(1);
        expect(defaultDietPlan.days[6].day).toBe(7);
    });

    test('defaultDietPlan days should have totalCalories and meals', () => {
        defaultDietPlan.days.forEach(day => {
            expect(day.totalCalories).toBe(2200);
            expect(day.meals.length).toBeGreaterThan(0);
        });
    });

    test('defaultWorkoutPlan should have gym and home plans', () => {
        expect(defaultWorkoutPlan).toHaveProperty('gym');
        expect(defaultWorkoutPlan).toHaveProperty('home');
    });

    test('defaultWorkoutPlan should have 7 days for both plans', () => {
        expect(defaultWorkoutPlan.gym.days.length).toBe(7);
        expect(defaultWorkoutPlan.home.days.length).toBe(7);
    });
});
