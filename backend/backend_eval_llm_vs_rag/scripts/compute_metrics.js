const path = require("path");
const {
  readJson,
  writeJson,
  computeDerivedValues,
  stripJsonFences
} = require("./backend_flow");

const ROOT = path.resolve(__dirname, "..");

function textOf(value) {
  return JSON.stringify(value || "").toLowerCase();
}

function containsAny(haystack, terms) {
  const t = haystack.toLowerCase();
  return terms.filter((term) => term && t.includes(String(term).toLowerCase()));
}

function safeArray(value) {
  return Array.isArray(value) ? value : [];
}

function normalizeOutput(result) {
  if (result?.parsedOutput) return result.parsedOutput;
  if (result?.cleanedContent) {
    try {
      return JSON.parse(stripJsonFences(result.cleanedContent));
    } catch (_) {
      return null;
    }
  }
  return null;
}

function sumDietCalories(day) {
  return safeArray(day.meals).reduce((sum, meal) => {
    return sum + safeArray(meal.items).reduce((itemSum, item) => itemSum + Number(item.calories || 0), 0);
  }, 0);
}

function dietStructureScore(output) {
  const checks = [];
  const days = safeArray(output?.days);
  checks.push(days.length === 7);
  for (let i = 0; i < 7; i += 1) {
    const day = days[i] || {};
    checks.push(day.day === i + 1);
    checks.push(Number.isFinite(Number(day.totalCalories)));
    checks.push(typeof day.protein === "string");
    checks.push(typeof day.carbs === "string");
    checks.push(typeof day.fats === "string");
    checks.push(Array.isArray(day.meals) && day.meals.length > 0);
    for (const meal of safeArray(day.meals)) {
      checks.push(typeof meal.title === "string" && meal.title.length > 0);
      checks.push(Array.isArray(meal.items) && meal.items.length > 0);
      for (const item of safeArray(meal.items)) {
        checks.push(typeof item.name === "string" && item.name.length > 0);
        checks.push(Number.isFinite(Number(item.calories)));
      }
    }
  }
  return checks;
}

function workoutStructureScore(output) {
  const checks = [];
  for (const mode of ["gym", "home"]) {
    checks.push(typeof output?.[mode]?.title === "string");
    const days = safeArray(output?.[mode]?.days);
    checks.push(days.length === 7);
    for (let i = 0; i < 7; i += 1) {
      const day = days[i] || {};
      checks.push(day.day === i + 1);
      checks.push(Array.isArray(day.exercises) && day.exercises.length > 0);
      for (const exercise of safeArray(day.exercises)) {
        checks.push(Number.isFinite(Number(exercise.id)));
        checks.push(typeof exercise.name === "string" && exercise.name.length > 0);
        checks.push(typeof exercise.difficulty === "string" && exercise.difficulty.length > 0);
        checks.push(typeof exercise.equipment === "string" && exercise.equipment.length > 0);
        checks.push(String(exercise.sets || "").length > 0);
        checks.push(String(exercise.reps || "").length > 0);
        checks.push(Number.isFinite(Number(exercise.calories)));
      }
    }
  }
  return checks;
}

function scoreDietInstructions(output, targetCalories) {
  const days = safeArray(output?.days);
  const text = textOf(output);
  const checks = [];
  checks.push(Boolean(output));
  checks.push(days.length === 7);
  checks.push(days.map((d) => d.day).join(",") === "1,2,3,4,5,6,7");
  checks.push(days.length === 7 && days.every((d) => Number(d.totalCalories) === targetCalories));
  checks.push(days.length === 7 && days.every((d) => sumDietCalories(d) === targetCalories));
  checks.push(days.length === 7 && days.some((d) => safeArray(d.meals).length >= 5));
  checks.push(days.length > 0 && safeArray(days[0].meals).some((m) => !["breakfast", "lunch", "dinner", "snack"].includes(String(m.title || "").toLowerCase())));
  checks.push(/\(\d+\s?(g|ml)\)|\d+\s?(g|ml)/i.test(text));
  checks.push(true);
  return checks;
}

function scoreWorkoutInstructions(output, expected) {
  const text = textOf(output);
  const checks = [];
  const gymDays = safeArray(output?.gym?.days);
  const homeDays = safeArray(output?.home?.days);
  const exerciseCounts = [...gymDays, ...homeDays].map((day) => safeArray(day.exercises).length);
  checks.push(Boolean(output));
  checks.push(Boolean(output?.gym));
  checks.push(Boolean(output?.home));
  checks.push(gymDays.length === 7);
  checks.push(homeDays.length === 7);
  checks.push(gymDays.map((d) => d.day).join(",") === "1,2,3,4,5,6,7" && homeDays.map((d) => d.day).join(",") === "1,2,3,4,5,6,7");
  checks.push(exerciseCounts.length === 14 && exerciseCounts.every((count) => count >= 6 && count <= 10));
  checks.push(text.includes("warm") || text.includes("cool"));
  checks.push(containsAny(text, expected.positiveTerms || []).length > 0);
  checks.push(true);
  return checks;
}

function calcEfficiency(rawLatencyMs, rawTokens, maxLatencyMs, maxTokens) {
  const latencyNorm = maxLatencyMs ? rawLatencyMs / maxLatencyMs : 1;
  const tokenNorm = maxTokens ? rawTokens / maxTokens : 1;
  const penalty = (latencyNorm + tokenNorm) / 2;
  return Math.max(0, Math.min(1, 1 - penalty));
}

function scoreCase(example, result, globalMax) {
  const output = normalizeOutput(result);
  const route = example.route;
  const expected = example.expected || {};
  const derived = result.derived || computeDerivedValues(example.requestBody);
  const outputText = textOf(output || result.cleanedContent || result.error || "");
  const forbiddenHits = containsAny(outputText, expected.forbiddenTerms || []);
  const positiveHits = containsAny(outputText, expected.positiveTerms || []);
  const usedAttributes = containsAny(outputText, expected.requiredUserAttributes || []);
  const tokenUsage = Number(result.usage?.total_tokens || ((result.usage?.prompt_tokens || 0) + (result.usage?.completion_tokens || 0)) || 0);
  const latencyMs = Number(result.latencyMs || 0);

  const structureChecks = route.includes("diet") ? dietStructureScore(output) : workoutStructureScore(output);
  const instructionChecks = route.includes("diet")
    ? scoreDietInstructions(output, derived.targetCalories)
    : scoreWorkoutInstructions(output, expected);
  const completedSections = route.includes("diet")
    ? [Array.isArray(output?.days) && output.days.length === 7]
    : [Array.isArray(output?.gym?.days) && output.gym.days.length === 7, Array.isArray(output?.home?.days) && output.home.days.length === 7];
  const constraints = [
    forbiddenHits.length === 0,
    positiveHits.length > 0,
    ...containsAny(outputText, ["allergy", "injury", "condition", "low impact", "gluten-free", "lactose-free", "iron-rich", "diabetes"]).length ? [true] : [false]
  ];

  const calculationErrors = [];
  if (route.includes("diet") && Array.isArray(output?.days)) {
    for (const day of output.days) {
      calculationErrors.push(Math.abs(Number(day.totalCalories || 0) - derived.targetCalories));
      calculationErrors.push(Math.abs(sumDietCalories(day) - derived.targetCalories));
    }
  }

  const checkableClaims = [
    ...structureChecks,
    forbiddenHits.length === 0,
    usedAttributes.length > 0
  ];
  if (result.mode === "rag" && result.retrieval?.vectorContext) {
    checkableClaims.push(!outputText.includes("vector database") || result.retrieval.vectorContext.length > 0);
  }

  const tp =
    structureChecks.filter(Boolean).length +
    instructionChecks.filter(Boolean).length +
    completedSections.filter(Boolean).length +
    constraints.filter(Boolean).length +
    usedAttributes.length +
    (forbiddenHits.length === 0 ? 1 : 0);
  const fp = forbiddenHits.length + calculationErrors.filter((e) => e > 0).length + (result.parsedOk === false ? 1 : 0);
  const totalRequired =
    structureChecks.length +
    instructionChecks.length +
    completedSections.length +
    constraints.length +
    (expected.requiredUserAttributes || []).length +
    1;
  const fn = Math.max(0, totalRequired - tp);

  const precision = tp + fp === 0 ? 0 : tp / (tp + fp);
  const recall = tp + fn === 0 ? 0 : tp / (tp + fn);
  const f1 = precision + recall === 0 ? 0 : (2 * precision * recall) / (precision + recall);
  const instructionAdherence = instructionChecks.filter(Boolean).length / instructionChecks.length;
  const constraintCompliance = constraints.filter(Boolean).length / constraints.length;
  const structureCompliance = structureChecks.filter(Boolean).length / structureChecks.length;
  const completeness = completedSections.filter(Boolean).length / completedSections.length;
  const personalization = usedAttributes.length / (expected.requiredUserAttributes || []).length;
  const faithfulness = checkableClaims.filter(Boolean).length / checkableClaims.length;
  const meanAbsoluteError = calculationErrors.length
    ? calculationErrors.reduce((a, b) => a + b, 0) / calculationErrors.length
    : null;
  const percentageError = meanAbsoluteError === null ? null : (meanAbsoluteError / derived.targetCalories) * 100;
  const efficiencyScore = calcEfficiency(latencyMs, tokenUsage, globalMax.latencyMs, globalMax.tokens);
  const overallScore =
    0.20 * instructionAdherence +
    0.20 * constraintCompliance +
    0.15 * structureCompliance +
    0.15 * completeness +
    0.10 * personalization +
    0.10 * faithfulness +
    0.05 * f1 +
    0.05 * efficiencyScore;

  return {
    caseId: example.caseId,
    mode: result.mode,
    route,
    parsedOk: Boolean(result.parsedOk),
    confusion: { TP: tp, FP: fp, FN: fn },
    precision,
    recall,
    f1,
    instruction_adherence: instructionAdherence,
    constraint_compliance: constraintCompliance,
    structure_compliance: structureCompliance,
    completeness,
    personalization,
    faithfulness,
    calculation_correctness: {
      targetCalories: derived.targetCalories,
      absoluteErrors: calculationErrors,
      mean_absolute_error: meanAbsoluteError,
      percentage_error: percentageError
    },
    latency_ms: latencyMs,
    token_usage: tokenUsage,
    efficiency_score: efficiencyScore,
    overall_score: overallScore,
    detectedFailures: {
      malformedOutput: !result.parsedOk,
      forbiddenHits,
      missingPositiveTerms: positiveHits.length === 0,
      usedAttributes,
      calculationErrors: calculationErrors.filter((e) => e > 0)
    }
  };
}

function mean(values) {
  const valid = values.filter((v) => typeof v === "number" && Number.isFinite(v));
  return valid.length ? valid.reduce((a, b) => a + b, 0) / valid.length : 0;
}

function sd(values) {
  const valid = values.filter((v) => typeof v === "number" && Number.isFinite(v));
  if (valid.length < 2) return 0;
  const m = mean(valid);
  return Math.sqrt(valid.reduce((sum, v) => sum + ((v - m) ** 2), 0) / (valid.length - 1));
}

function aggregate(perCase) {
  const modes = [...new Set(perCase.map((r) => r.mode))];
  const out = {};
  for (const mode of modes) {
    const rows = perCase.filter((r) => r.mode === mode);
    out[mode] = {
      cases: rows.length,
      precision: mean(rows.map((r) => r.precision)),
      recall: mean(rows.map((r) => r.recall)),
      f1: mean(rows.map((r) => r.f1)),
      instruction_adherence: mean(rows.map((r) => r.instruction_adherence)),
      constraint_compliance: mean(rows.map((r) => r.constraint_compliance)),
      structure_compliance: mean(rows.map((r) => r.structure_compliance)),
      completeness: mean(rows.map((r) => r.completeness)),
      personalization: mean(rows.map((r) => r.personalization)),
      faithfulness: mean(rows.map((r) => r.faithfulness)),
      mean_absolute_error: mean(rows.map((r) => r.calculation_correctness.mean_absolute_error).filter((v) => v !== null)),
      latency_ms: mean(rows.map((r) => r.latency_ms)),
      latency_sd_ms: sd(rows.map((r) => r.latency_ms)),
      token_usage: mean(rows.map((r) => r.token_usage)),
      overall_score: mean(rows.map((r) => r.overall_score))
    };
  }
  return out;
}

function computeMetrics() {
  const cases = readJson(path.join(ROOT, "config", "eval_cases.json"));
  const llmOnly = readJson(path.join(ROOT, "results", "raw_outputs_llm_only.json"));
  const rag = readJson(path.join(ROOT, "results", "raw_outputs_rag.json"));
  const allResults = [...llmOnly, ...rag];
  const globalMax = {
    latencyMs: Math.max(...allResults.map((r) => Number(r.latencyMs || 0)), 1),
    tokens: Math.max(...allResults.map((r) => Number(r.usage?.total_tokens || 0)), 1)
  };

  const perCase = [];
  for (const result of allResults) {
    const example = cases.find((c) => c.caseId === result.caseId);
    if (!example) throw new Error(`Missing case for result ${result.caseId}`);
    perCase.push(scoreCase(example, result, globalMax));
  }

  const summary = {
    generatedAt: new Date().toISOString(),
    caseCountPerMode: 7,
    totalDeepSeekRequestsExpected: 14,
    equations: readJson(path.join(ROOT, "config", "scoring_schema.json")).equations,
    perCase,
    aggregate: aggregate(perCase)
  };

  writeJson(path.join(ROOT, "results", "metrics_per_case.json"), perCase);
  writeJson(path.join(ROOT, "results", "metrics_summary.json"), summary);
  writeJson(path.join(ROOT, "logs", "failures.json"), perCase.filter((r) => {
    const f = r.detectedFailures;
    return f.malformedOutput || f.forbiddenHits.length || f.missingPositiveTerms || f.calculationErrors.length;
  }));
  return summary;
}

if (require.main === module) {
  computeMetrics();
}

module.exports = { computeMetrics, scoreCase, aggregate };
