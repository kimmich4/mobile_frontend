# SQA Stress Test Report — RAG Fitness Backend

**Date:** 2026-05-16T16:20:10.131Z
**Engine:** Node.js / Express
**Tool:** Jest + Supertest (in-process load)

## Configuration
| Setting | Value |
|---|---|
| Load levels | `1 → 5 → 10 → 25 → 50 → 100 → 200 → 500 → 600 → 700 → 800 → 900 → 1000` |
| Request timeout | 5000 ms |
| Max allowed error rate | 0% |
| Max p95 latency | 500 ms |
| Max p99 latency | 1000 ms |

## Executive Summary
| Endpoint | Last Passing Level | Breaking Level | Root Cause |
|---|---|---|---|
| `GET /health` | **600** | 700 | p95 531ms > 500ms |
| `POST /ai/chat` | **700** | 800 | p95 551ms > 500ms |
| `POST /ai/analyze-report` | **600** | 700 | p95 551ms > 500ms |
| `POST /ai/generate-diet` | **700** | 800 | p95 555ms > 500ms |
| `POST /ai/generate-workout` | **600** | 700 | p95 555ms > 500ms |
| `POST /ai/search-video` | **600** | 700 | p95 501ms > 500ms |

## Detailed Results per Endpoint
### `GET /health`
> ❌ **Breaks at 700 concurrent requests**
> Root cause: p95 531ms > 500ms
> Maximum safe concurrency: **600**

| Conc. | OK | Err | Err% | Min | Median | p95 | p99 | Max | Result |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0% | 14 | 14 | 14 | 14 | 14 | ✅ |
| 5 | 5 | 0 | 0% | 9 | 9 | 10 | 10 | 10 | ✅ |
| 10 | 10 | 0 | 0% | 16 | 17 | 18 | 18 | 18 | ✅ |
| 25 | 25 | 0 | 0% | 22 | 24 | 26 | 26 | 26 | ✅ |
| 50 | 50 | 0 | 0% | 41 | 45 | 47 | 48 | 48 | ✅ |
| 100 | 100 | 0 | 0% | 77 | 84 | 88 | 89 | 89 | ✅ |
| 200 | 200 | 0 | 0% | 168 | 176 | 181 | 183 | 183 | ✅ |
| 500 | 500 | 0 | 0% | 410 | 437 | 453 | 455 | 456 | ✅ |
| 600 | 600 | 0 | 0% | 371 | 398 | 442 | 445 | 445 | ✅ |
| 700 | 700 | 0 | 0% | 456 | 499 | 531 ⚠️ | 533 | 534 | ❌ |

### `POST /ai/chat`
> ❌ **Breaks at 800 concurrent requests**
> Root cause: p95 551ms > 500ms
> Maximum safe concurrency: **700**

| Conc. | OK | Err | Err% | Min | Median | p95 | p99 | Max | Result |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0% | 65 | 65 | 65 | 65 | 65 | ✅ |
| 5 | 5 | 0 | 0% | 6 | 7 | 8 | 8 | 8 | ✅ |
| 10 | 10 | 0 | 0% | 12 | 12 | 14 | 14 | 14 | ✅ |
| 25 | 25 | 0 | 0% | 16 | 20 | 22 | 22 | 22 | ✅ |
| 50 | 50 | 0 | 0% | 36 | 41 | 45 | 45 | 45 | ✅ |
| 100 | 100 | 0 | 0% | 81 | 85 | 90 | 91 | 92 | ✅ |
| 200 | 200 | 0 | 0% | 138 | 158 | 180 | 181 | 181 | ✅ |
| 500 | 500 | 0 | 0% | 332 | 424 | 452 | 456 | 457 | ✅ |
| 600 | 600 | 0 | 0% | 422 | 442 | 463 | 465 | 466 | ✅ |
| 700 | 700 | 0 | 0% | 419 | 455 | 497 | 517 | 523 | ✅ |
| 800 | 800 | 0 | 0% | 483 | 516 | 551 ⚠️ | 552 | 554 | ❌ |

### `POST /ai/analyze-report`
> ❌ **Breaks at 700 concurrent requests**
> Root cause: p95 551ms > 500ms
> Maximum safe concurrency: **600**

| Conc. | OK | Err | Err% | Min | Median | p95 | p99 | Max | Result |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0% | 45 | 45 | 45 | 45 | 45 | ✅ |
| 5 | 5 | 0 | 0% | 5 | 6 | 7 | 7 | 7 | ✅ |
| 10 | 10 | 0 | 0% | 7 | 8 | 9 | 9 | 9 | ✅ |
| 25 | 25 | 0 | 0% | 14 | 17 | 18 | 19 | 19 | ✅ |
| 50 | 50 | 0 | 0% | 29 | 33 | 37 | 37 | 37 | ✅ |
| 100 | 100 | 0 | 0% | 61 | 67 | 75 | 75 | 76 | ✅ |
| 200 | 200 | 0 | 0% | 110 | 119 | 127 | 129 | 129 | ✅ |
| 500 | 500 | 0 | 0% | 288 | 310 | 337 | 339 | 340 | ✅ |
| 600 | 600 | 0 | 0% | 395 | 423 | 471 | 476 | 477 | ✅ |
| 700 | 700 | 0 | 0% | 429 | 492 | 551 ⚠️ | 558 | 559 | ❌ |

### `POST /ai/generate-diet`
> ❌ **Breaks at 800 concurrent requests**
> Root cause: p95 555ms > 500ms
> Maximum safe concurrency: **700**

| Conc. | OK | Err | Err% | Min | Median | p95 | p99 | Max | Result |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0% | 41 | 41 | 41 | 41 | 41 | ✅ |
| 5 | 5 | 0 | 0% | 5 | 5 | 6 | 6 | 6 | ✅ |
| 10 | 10 | 0 | 0% | 9 | 11 | 13 | 13 | 13 | ✅ |
| 25 | 25 | 0 | 0% | 16 | 19 | 23 | 23 | 23 | ✅ |
| 50 | 50 | 0 | 0% | 34 | 36 | 39 | 39 | 39 | ✅ |
| 100 | 100 | 0 | 0% | 77 | 85 | 92 | 93 | 93 | ✅ |
| 200 | 200 | 0 | 0% | 107 | 121 | 134 | 136 | 137 | ✅ |
| 500 | 500 | 0 | 0% | 292 | 318 | 383 | 385 | 387 | ✅ |
| 600 | 600 | 0 | 0% | 399 | 423 | 447 | 450 | 451 | ✅ |
| 700 | 700 | 0 | 0% | 427 | 461 | 491 | 493 | 495 | ✅ |
| 800 | 800 | 0 | 0% | 495 | 526 | 555 ⚠️ | 560 | 561 | ❌ |

### `POST /ai/generate-workout`
> ❌ **Breaks at 700 concurrent requests**
> Root cause: p95 555ms > 500ms
> Maximum safe concurrency: **600**

| Conc. | OK | Err | Err% | Min | Median | p95 | p99 | Max | Result |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0% | 44 | 44 | 44 | 44 | 44 | ✅ |
| 5 | 5 | 0 | 0% | 7 | 9 | 9 | 9 | 9 | ✅ |
| 10 | 10 | 0 | 0% | 9 | 11 | 12 | 12 | 12 | ✅ |
| 25 | 25 | 0 | 0% | 15 | 17 | 19 | 19 | 19 | ✅ |
| 50 | 50 | 0 | 0% | 35 | 36 | 38 | 39 | 39 | ✅ |
| 100 | 100 | 0 | 0% | 63 | 70 | 82 | 83 | 84 | ✅ |
| 200 | 200 | 0 | 0% | 118 | 128 | 143 | 145 | 146 | ✅ |
| 500 | 500 | 0 | 0% | 305 | 323 | 352 | 354 | 355 | ✅ |
| 600 | 600 | 0 | 0% | 366 | 392 | 420 | 423 | 424 | ✅ |
| 700 | 700 | 0 | 0% | 515 | 535 | 555 ⚠️ | 559 | 561 | ❌ |

### `POST /ai/search-video`
> ❌ **Breaks at 700 concurrent requests**
> Root cause: p95 501ms > 500ms
> Maximum safe concurrency: **600**

| Conc. | OK | Err | Err% | Min | Median | p95 | p99 | Max | Result |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0% | 38 | 38 | 38 | 38 | 38 | ✅ |
| 5 | 5 | 0 | 0% | 5 | 5 | 5 | 5 | 5 | ✅ |
| 10 | 10 | 0 | 0% | 9 | 11 | 13 | 13 | 13 | ✅ |
| 25 | 25 | 0 | 0% | 18 | 22 | 25 | 25 | 25 | ✅ |
| 50 | 50 | 0 | 0% | 39 | 44 | 51 | 52 | 52 | ✅ |
| 100 | 100 | 0 | 0% | 91 | 96 | 101 | 101 | 101 | ✅ |
| 200 | 200 | 0 | 0% | 131 | 148 | 157 | 158 | 158 | ✅ |
| 500 | 500 | 0 | 0% | 331 | 340 | 351 | 354 | 355 | ✅ |
| 600 | 600 | 0 | 0% | 359 | 373 | 407 | 410 | 411 | ✅ |
| 700 | 700 | 0 | 0% | 425 | 474 | 501 ⚠️ | 503 | 504 | ❌ |

## SQA Recommendations
### Endpoints that need attention
- **`GET /health`** — safe up to **600** concurrent requests
  - Failure mode: p95 531ms > 500ms
- **`POST /ai/chat`** — safe up to **700** concurrent requests
  - Failure mode: p95 551ms > 500ms
- **`POST /ai/analyze-report`** — safe up to **600** concurrent requests
  - Failure mode: p95 551ms > 500ms
- **`POST /ai/generate-diet`** — safe up to **700** concurrent requests
  - Failure mode: p95 555ms > 500ms
- **`POST /ai/generate-workout`** — safe up to **600** concurrent requests
  - Failure mode: p95 555ms > 500ms
- **`POST /ai/search-video`** — safe up to **600** concurrent requests
  - Failure mode: p95 501ms > 500ms

> **System ceiling (weakest link): 600 concurrent requests.**
> Apply rate-limiting of **600 req/endpoint** before production deployment.

---
*Report generated by Antigravity SQA Stress Runner*