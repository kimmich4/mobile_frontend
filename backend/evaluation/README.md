# RAG Evaluation Harness

This folder adds a separate accuracy test harness for the backend RAG pipeline without changing the existing backend files.

## What it measures

- Retrieval quality: `Recall@k`, `Precision@k`, `MRR`
- Answer quality: `Exact Match`, token-level `F1`
- Grounding: deterministic `faithfulness` score
- Optional LLM judge: DeepSeek correctness and faithfulness scoring

## Why this fits this project

The current backend already uses:

- HuggingFace embeddings in `rag_logic.js`
- Qdrant retrieval in `qdrant_client.js`
- DeepSeek generation in `plan_generator.js`

So the evaluation runner calls the same retrieval and generation layers instead of benchmarking a fake path.

## Dataset format

Use a JSON array. Each item should look like:

```json
{
  "id": "diet-diabetes-cutting-001",
  "question": "Generate a safe 7-day diet plan for a male athlete with type 2 diabetes who wants fat loss.",
  "searchQuery": "type 2 diabetes, none,none",
  "contextPrefix": "User Profile: Omar...\nVector Database Constraints: {{VECTOR_CONTEXT}}",
  "task": "Create a 7-day diet plan (Day 1 to Day 7). Return only JSON.",
  "groundTruthAnswer": "{\"requirements\":[\"7 days\",\"avoid high-sugar foods\",\"blood-sugar-aware meal choices\"]}",
  "relevantDocumentIds": ["real-qdrant-id-1", "real-qdrant-id-2"]
}
```

Required fields:

- `question`
- `task`

Strongly recommended fields:

- `searchQuery`
- `groundTruthAnswer`
- `relevantDocumentIds`
- `contextPrefix`

## Run it

Use the benchmark dataset:

```bash
node evaluation/index.js --dataset evaluation/benchmark.dataset.json --mode full --judge llm --output evaluation/reports/benchmark-report.json
```

Build a live benchmark file with the currently retrieved real Qdrant ids:

```bash
node evaluation/prepare_live_benchmark.js evaluation/benchmark.dataset.json evaluation/benchmark.live.dataset.json
```

If a live generation run is interrupted after answers were already saved, rescore the report offline:

```bash
node evaluation/rescore_report.js evaluation/reports/live-benchmark-report.json evaluation/benchmark.live.dataset.json
```

## Visualize reports

Generate charts from the real live benchmark report:

```bash
python evaluation/visualize_report.py --report evaluation/reports/live-benchmark-report.json --reports-dir evaluation/reports --output-dir evaluation/graphs/live
```

The visualization script writes:

- `summary_metrics.png` as the main `LLM Alone` vs `LLM + RAG` safety summary
- `f1_comparison.png` as a secondary lexical-overlap view built from the real report values
- `per_example_heatmap.png`
- `baseline_lift_heatmap.png` when baseline comparison exists
- `judge_scatter.png` as the per-case overall improvement map
- `dashboard.json` listing all generated images

## Qdrant labeling helpers

Export a searchable catalog of the current vector collection:

```bash
node -e "const { exportCollectionCatalog } = require('./evaluation/qdrant_tools'); exportCollectionCatalog({ outputPath: './evaluation/reports/qdrant-catalog.json' }).then(() => console.log('done'));"
```

Export the current top retrieval candidates for each benchmark example:

```bash
node -e "const { buildLabelCandidates } = require('./evaluation/qdrant_tools'); buildLabelCandidates({ datasetPath: './evaluation/benchmark.dataset.json', outputPath: './evaluation/reports/label-candidates.json' }).then(() => console.log('done'));"
```

## Environment

The runner reuses the same env vars as the backend:

- `HF_API_KEY`
- `QDRANT_URL`
- `QDRANT_API_KEY`

## Practical advice

- Start with `20-50` hand-labeled examples.
- Put the true Qdrant point ids in `relevantDocumentIds`.
- Keep gold answers short and precise if you want `EM` to be meaningful.
- Treat deterministic faithfulness as a fast regression signal, not a perfect hallucination detector.
- Use the optional LLM judge for deeper review, but compare it against a few manually checked samples before trusting it.
- Use `benchmark.dataset.json` as a starter regression set, then split into easy and hard suites as it grows.
- Watch `jsonValidity` and `structureScore` closely for this project because the mobile app expects rigid JSON shapes, not free-form text.
- For the most honest retrieval score, use `prepare_live_benchmark.js` only as a bootstrap step, then manually confirm or correct those ids.
- `requirementCoverage`, `restrictionAdherence`, and `planGrounding` are more informative than plain `F1` for these long structured plans because the project goal is to avoid unsafe foods and exercises while staying grounded in retrieved safety evidence.
