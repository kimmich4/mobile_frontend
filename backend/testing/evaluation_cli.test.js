const { runEvaluation, reportMarkdown, writeBackendFlowDoc } = require('../backend_eval_llm_vs_rag/scripts/run_evaluation');

describe('evaluation runner exports', () => {
    test('exposes callable evaluation helpers', () => {
        expect(typeof runEvaluation).toBe('function');
        expect(typeof reportMarkdown).toBe('function');
        expect(typeof writeBackendFlowDoc).toBe('function');
    });
});
