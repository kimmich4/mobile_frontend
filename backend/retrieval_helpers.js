function cleanText(value) {
    return String(value || "").trim();
}

function normalizeNone(value) {
    const text = cleanText(value);
    return /^(none|not specified|null|undefined)$/i.test(text) ? "" : text;
}

function labeledPart(label, value) {
    const text = normalizeNone(value);
    return text ? `${label}: ${text}` : "";
}

function joinQueryParts(parts) {
    return parts.map(normalizeNone).filter(Boolean).join(". ");
}

function buildDietSearchQuery(input) {
    return joinQueryParts([
        labeledPart("Medical conditions", input.healthConditions),
        labeledPart("Food allergies or restrictions", input.allergies),
        labeledPart("Medical report diet notes", input.medicalReport),
        labeledPart("InBody nutrition notes", input.inbodyReport)
    ]);
}

function buildWorkoutSearchQuery(input) {
    return joinQueryParts([
        labeledPart("Medical conditions", input.healthConditions),
        labeledPart("Injuries or movement restrictions", input.injuries),
        labeledPart("Experience", input.experience),
        labeledPart("Medical report movement notes", input.medicalReport),
        labeledPart("InBody training notes", input.inbodyReport)
    ]);
}

function compactList(values, limit = 10) {
    const seen = new Set();
    const compact = [];

    for (const value of values) {
        const text = cleanText(value);
        if (!text) continue;

        const key = text.toLowerCase();
        if (seen.has(key)) continue;

        seen.add(key);
        compact.push(text);
        if (compact.length >= limit) break;
    }

    return compact;
}

function payloadText(payload) {
    const values = [
        payload.issue,
        payload.goal,
        ...(payload.dietary_restrictions || []),
        ...(payload.allergies || []),
        ...(payload.contraindicated_foods || []).map((item) => item.food || item),
        ...(payload.contraindicated_exercises || []).map((item) => item.exercise || item)
    ];
    return values.join(" ").toLowerCase();
}

function tokenize(text) {
    return compactList(
        String(text || "")
            .toLowerCase()
            .replace(/[^a-z0-9\s-]/g, " ")
            .split(/\s+/)
            .filter((token) => token.length > 2 && !["and", "the", "with", "for", "none"].includes(token)),
        30
    );
}

function rankRetrievedResults(results, searchQuery) {
    const tokens = tokenize(searchQuery);
    if (!tokens.length) return results || [];

    return [...(results || [])].sort((a, b) => {
        const aText = payloadText(a.payload || {});
        const bText = payloadText(b.payload || {});
        const aScore = tokens.reduce((score, token) => score + (aText.includes(token) ? 1 : 0), 0);
        const bScore = tokens.reduce((score, token) => score + (bText.includes(token) ? 1 : 0), 0);

        if (bScore !== aScore) return bScore - aScore;
        return (b.score || 0) - (a.score || 0);
    });
}

function formatVectorContext(results, maxResults = 3) {
    const issues = [];
    const allergies = [];
    const dietRestrictions = [];
    const foodsToAvoid = [];
    const exercisesToAvoid = [];

    for (const result of (results || []).slice(0, maxResults)) {
        const payload = result.payload || {};
        if (payload.issue) issues.push(payload.issue);
        for (const item of payload.allergies || []) allergies.push(item);
        for (const item of payload.dietary_restrictions || []) dietRestrictions.push(item);
        for (const item of payload.contraindicated_foods || []) foodsToAvoid.push(item.food || item);
        for (const item of payload.contraindicated_exercises || []) exercisesToAvoid.push(item.exercise || item);
    }

    const lines = [];
    const compactIssues = compactList(issues, 3);
    const compactAllergies = compactList(allergies, 6);
    const compactDiet = compactList(dietRestrictions, 6);
    const compactFoods = compactList(foodsToAvoid);
    const compactExercises = compactList(exercisesToAvoid);

    if (compactIssues.length) lines.push(`Relevant issues: ${compactIssues.join("; ")}`);
    if (compactAllergies.length) lines.push(`Allergies: ${compactAllergies.join(", ")}`);
    if (compactDiet.length) lines.push(`Diet restrictions: ${compactDiet.join(", ")}`);
    if (compactFoods.length) lines.push(`Foods to avoid (${compactFoods.join(", ")})`);
    if (compactExercises.length) lines.push(`Exercises to avoid (${compactExercises.join(", ")})`);

    return lines.length ? lines.join("\n") : "No specific contraindications found in database.";
}

module.exports = {
    buildDietSearchQuery,
    buildWorkoutSearchQuery,
    formatVectorContext,
    rankRetrievedResults
};
