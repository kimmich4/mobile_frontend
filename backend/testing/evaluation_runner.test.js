const path = require('path');
const fs = require('fs');

function readSummary() {
    return JSON.parse(fs.readFileSync(
        path.join(__dirname, '..', 'backend_eval_llm_vs_rag', 'results', 'metrics_summary.json'),
        'utf8'
    ));
}

describe('evaluation runner artifacts', () => {
    test('summary contains per-case results for each benchmark case and mode', () => {
        const summary = readSummary();

        expect(summary.perCase).toHaveLength(40);
        expect(new Set(summary.perCase.map((row) => row.caseId)).size).toBe(20);
        expect(new Set(summary.perCase.map((row) => row.mode))).toEqual(new Set(['llm_only', 'rag']));
        expect(summary.perCase.every((row) => row.route && typeof row.parsedOk === 'boolean')).toBe(true);
    });

    test('aggregate totals match the per-case mode counts', () => {
        const summary = readSummary();
        const llmOnlyRows = summary.perCase.filter((row) => row.mode === 'llm_only');
        const ragRows = summary.perCase.filter((row) => row.mode === 'rag');

        expect(summary.aggregate.llm_only.cases).toBe(llmOnlyRows.length);
        expect(summary.aggregate.rag.cases).toBe(ragRows.length);
    });
});
