const { parseArgs } = require('../evaluation/index');

describe('evaluation cli', () => {
    test('parseArgs accepts visualization-friendly options', () => {
        const args = parseArgs([
            '--dataset',
            'evaluation/benchmark.dataset.json',
            '--mode',
            'full',
            '--judge',
            'llm',
            '--top-k',
            '5',
            '--output',
            'evaluation/reports/output.json'
        ]);

        expect(args).toEqual({
            datasetPath: 'evaluation/benchmark.dataset.json',
            outputPath: 'evaluation/reports/output.json',
            mode: 'full',
            judge: 'llm',
            topK: 5,
            compareAgainstBaseline: true
        });
    });
});
