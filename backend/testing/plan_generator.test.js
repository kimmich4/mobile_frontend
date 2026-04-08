const { calculateBMR, calculateTDEE, adjustCalories } = require('../plan_generator');

describe('Plan Generator calculations', () => {
    test('calculateBMR should calculate correctly for male', () => {
        // formula: 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        const bmr = calculateBMR(70, 175, 25, 'male');
        expect(bmr).toBeCloseTo(1724.05, 1);
    });

    test('calculateBMR should calculate correctly for female', () => {
        // formula: 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
        const bmr = calculateBMR(60, 165, 30, 'female');
        expect(bmr).toBeCloseTo(1383.68, 1);
    });

    test('calculateTDEE should apply correct multiplier', () => {
        const bmr = 2000;
        expect(calculateTDEE(bmr, 'sedentary')).toBe(2000 * 1.2);
        expect(calculateTDEE(bmr, 'moderate')).toBe(2000 * 1.55);
        expect(calculateTDEE(bmr, 'very active')).toBe(2000 * 1.9);
        expect(calculateTDEE(bmr, 'unknown')).toBe(2000 * 1.375); // default
    });

    test('adjustCalories should adjust based on goals', () => {
        const tdee = 2500;
        expect(adjustCalories(tdee, 'lose weight')).toBe(2000);
        expect(adjustCalories(tdee, 'build muscle')).toBe(3000);
        expect(adjustCalories(tdee, 'maintain')).toBe(2500);
    });
});
