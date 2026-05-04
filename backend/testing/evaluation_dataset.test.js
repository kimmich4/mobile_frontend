const path = require('path');
const fs = require('fs');

describe('evaluation datasets', () => {
    test('loads the benchmark dataset with route metadata', () => {
        const datasetPath = path.join(__dirname, '..', 'backend_eval_llm_vs_rag', 'config', 'eval_cases.json');
        const dataset = JSON.parse(fs.readFileSync(datasetPath, 'utf8'));

        expect(dataset.length).toBeGreaterThanOrEqual(8);
        expect(dataset.every((item) => item.caseId && item.description && item.requestBody && item.expected)).toBe(true);
        expect(dataset.some((item) => item.route === '/ai/generate-diet')).toBe(true);
        expect(dataset.some((item) => item.route === '/ai/generate-workout')).toBe(true);
    });
});
