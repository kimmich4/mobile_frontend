# Benchmark Notes

This benchmark file is a starter set for the current backend routes:

- `/ai/generate-diet`
- `/ai/generate-workout`

## What is already useful

- The prompts match the current route structure in `index.js`
- Each example includes realistic profile context and a concise gold answer rubric
- The set covers conditions, allergies, injuries, and split preferences

## What you should still label for production-quality scoring

- Replace placeholder `relevantDocumentIds` with the real Qdrant point ids from your collection
- Expand `groundTruthAnswer` if you want stricter `F1` and `EM`
- Add 20-50 more examples per route for stable metrics

## Recommended dataset split

- `benchmark.dataset.json`: main regression suite
- `benchmark.dataset.dev.json`: cases you use while tuning prompts
- `benchmark.dataset.hard.json`: adversarial and hallucination-prone cases

## Good next examples to add

- CKD or renal diet restrictions
- peanut allergy with muscle-gain diet
- ankle sprain with home-only workout
- obesity + hypertension with beginner full-body plan
- empty search query cases to test the no-context fallback path
