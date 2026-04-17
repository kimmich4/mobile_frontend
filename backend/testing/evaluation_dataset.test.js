const path = require('path');
const { loadDataset } = require('../evaluation/dataset');

describe('evaluation datasets', () => {
    test('loads the benchmark dataset with route metadata', () => {
        const dataset = loadDataset(path.join(__dirname, '..', 'evaluation', 'benchmark.dataset.json'));

        expect(dataset.length).toBeGreaterThanOrEqual(8);
        expect(dataset.every((item) => item.question && item.task)).toBe(true);
        expect(dataset.some((item) => item.metadata.route === '/ai/generate-diet')).toBe(true);
        expect(dataset.some((item) => item.metadata.route === '/ai/generate-workout')).toBe(true);
    });
});
