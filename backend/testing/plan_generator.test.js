const { calculateBMR, calculateTDEE, adjustCalories, generateAnswer } = require('../plan_generator');

function createStreamResponse(chunks) {
    const encoder = new TextEncoder();
    let index = 0;

    return {
        ok: true,
        status: 200,
        body: {
            getReader() {
                return {
                    async read() {
                        if (index >= chunks.length) {
                            return { done: true, value: undefined };
                        }
                        return { done: false, value: encoder.encode(chunks[index++]) };
                    },
                    releaseLock() {}
                };
            }
        }
    };
}

describe('Plan Generator calculations', () => {
    beforeEach(() => {
        global.fetch = jest.fn();
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

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

    test('generateAnswer should fall back to streaming after a retryable HF error', async () => {
        global.fetch
            .mockResolvedValueOnce({
                ok: false,
                status: 504,
                text: jest.fn().mockResolvedValue('Gateway Timeout')
            })
            .mockResolvedValueOnce(createStreamResponse([
                'data: {"choices":[{"delta":{"content":"{\\"gym\\":{\\"days\\":[]},"}}]}\n',
                'data: {"choices":[{"delta":{"content":"\\"home\\":{\\"days\\":[]}}"},"finish_reason":"stop"}]}\n',
                'data: [DONE]\n'
            ]));

        const result = await generateAnswer('ctx', 'task');

        expect(JSON.parse(result)).toEqual({ gym: { days: [] }, home: { days: [] } });
        expect(global.fetch).toHaveBeenCalledTimes(2);
        expect(JSON.parse(global.fetch.mock.calls[1][1].body).stream).toBe(true);
    });
});
