# DeepSeek LLM-only vs LLM + RAG Evaluation

This isolated folder evaluates the backend's real DeepSeek plan-generation behavior in two modes:

1. `llm_only`: one natural human-style prompt, no backend prompt structure, no retrieval, no injected chunks.
2. `rag`: backend-equivalent flow for `/ai/generate-diet` and `/ai/generate-workout`, including the same calculated context, prompt structure, Hugging Face embedding call, Qdrant search, vector-context formatting, and DeepSeek payload shape.

No existing backend files are edited by this evaluation.

## Run

From `backend/`:

```bash
node backend_eval_llm_vs_rag/scripts/run_evaluation.js
python backend_eval_llm_vs_rag/scripts/generate_diagrams.py
python backend_eval_llm_vs_rag/scripts/generate_charts.py
```

The Node runner expects the existing backend `.env` values:

- `HF_API_KEY`
- `QDRANT_URL`
- `QDRANT_API_KEY`

The run is capped at exactly 7 LLM-only cases and exactly 7 LLM + RAG cases. It writes redacted request captures and raw responses under `results/`.

## Outputs

- `config/eval_cases.json`: exactly 7 reusable evaluation cases.
- `config/scoring_schema.json`: scoring rubric and equations created before evaluation.
- `prompts/llm_only_plain_prompt.txt`: natural prompt template for the LLM-only mode.
- `results/case_XX_llm_only/*`: prompt, redacted request payload, raw response, normalized output.
- `results/case_XX_rag/*`: prompt, redacted request payload, raw response, retrieved context, normalized output.
- `results/raw_outputs_llm_only.json`
- `results/raw_outputs_rag.json`
- `results/metrics_per_case.json`
- `results/metrics_summary.json`
- `logs/failures.json`
- `charts/*.png`
- `reports/backend_flow_reconstruction.json`
- `reports/final_comparison_report.md`

## Metrics

The scoring uses deterministic checklist items tied to the backend output requirements. For each item:

- TP = correctly satisfied required item.
- FP = wrong, unsupported, or forbidden item.
- FN = required item missing or not satisfied.
- TN is not used.

Equations:

- `precision = TP / (TP + FP)`
- `recall = TP / (TP + FN)`
- `F1 = 2 * (precision * recall) / (precision + recall)`
- `instruction_adherence = followed_instructions / total_instructions`
- `constraint_compliance = satisfied_constraints / total_constraints`
- `structure_compliance = correctly_present_fields / total_required_fields`
- `completeness = completed_required_sections / total_required_sections`
- `personalization = used_relevant_user_attributes / total_relevant_user_attributes`
- `faithfulness = supported_claims / total_checkable_claims`
- `overall_score = 0.20*instruction_adherence + 0.20*constraint_compliance + 0.15*structure_compliance + 0.15*completeness + 0.10*personalization + 0.10*faithfulness + 0.05*F1 + 0.05*efficiency_score`

## Confirmed From Code

The evaluator reconstructs the production flow from:

- `../index.js`
- `../rag_chain.js`
- `../rag_logic.js`
- `../qdrant_client.js`
- `../plan_generator.js`

The deterministic scoring model is evaluation-specific because the backend does not include a gold-answer judge.
