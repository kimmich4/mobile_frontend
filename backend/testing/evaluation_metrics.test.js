const path = require('path');
const fs = require('fs');

function readSummary() {
    return JSON.parse(fs.readFileSync(
        path.join(__dirname, '..', 'backend_eval_llm_vs_rag', 'results', 'metrics_summary.json'),
        'utf8'
    ));
}

describe('evaluation metrics artifacts', () => {
    test('summary records the expected metric equations', () => {
        const summary = readSummary();

        expect(summary.equations.precision).toBe('TP / (TP + FP)');
        expect(summary.equations.recall).toBe('TP / (TP + FN)');
        expect(summary.equations.f1).toContain('precision');
        expect(summary.equations.overall_score).toContain('instruction_adherence');
    });

    test('summary includes complete aggregate metrics for both modes', () => {
        const summary = readSummary();

        for (const mode of ['llm_only', 'rag']) {
            expect(summary.aggregate[mode].cases).toBe(20);
            expect(summary.aggregate[mode].precision).toBeGreaterThanOrEqual(0);
            expect(summary.aggregate[mode].recall).toBeGreaterThanOrEqual(0);
            expect(summary.aggregate[mode].f1).toBeGreaterThanOrEqual(0);
            expect(summary.aggregate[mode].overall_score).toBeGreaterThanOrEqual(0);
            expect(summary.aggregate[mode].overall_score).toBeLessThanOrEqual(1);
        }
    });
});
