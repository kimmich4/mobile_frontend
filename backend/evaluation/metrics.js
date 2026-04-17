"use strict";

const DEFAULT_STOPWORDS = new Set([
    "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "has", "he",
    "in", "is", "it", "its", "of", "on", "that", "the", "to", "was", "were", "will",
    "with", "or", "this", "these", "those", "your", "you", "their", "them", "his",
    "her", "our", "we", "they", "i", "me", "my"
]);

const TERM_SYNONYMS = {
    shellfish: ["shellfish", "shrimp", "prawn", "crab", "lobster", "clam", "mussel", "oyster", "scallop"],
    lactose: ["lactose", "milk", "cheese", "cream", "ice cream", "yogurt", "whey"],
    dairy: ["milk", "cheese", "cream", "ice cream", "yogurt", "butter"],
    sugar: ["sugar", "sugary", "dessert", "soft drink", "soda", "juice", "candy", "syrup"],
    overhead: ["overhead press", "shoulder press", "military press", "push press", "handstand push-up"],
    plyometric: ["plyometric", "box jump", "jump squat", "bounding", "broad jump"],
    spinal: ["deadlift", "good morning", "heavy squat", "barbell row", "romanian deadlift"],
    impact: ["jump", "bounding", "sprint", "plyometric", "hop"]
};

function normalizeText(text) {
    return String(text || "")
        .toLowerCase()
        .replace(/[`"'â€œâ€â€˜â€™]/g, "")
        .replace(/[^a-z0-9\s]/g, " ")
        .replace(/\s+/g, " ")
        .trim();
}

function tokenize(text) {
    const normalized = normalizeText(text);
    return normalized ? normalized.split(" ") : [];
}

function tokenizeContent(text) {
    return tokenize(text).filter((token) => token && !DEFAULT_STOPWORDS.has(token));
}

function countTokens(tokens) {
    const counts = new Map();
    for (const token of tokens) {
        counts.set(token, (counts.get(token) || 0) + 1);
    }
    return counts;
}

function intersectionSize(left, right) {
    let size = 0;
    for (const [token, leftCount] of left.entries()) {
        const rightCount = right.get(token) || 0;
        size += Math.min(leftCount, rightCount);
    }
    return size;
}

function exactMatch(reference, prediction) {
    return normalizeText(reference) === normalizeText(prediction) ? 1 : 0;
}

function f1Score(reference, prediction) {
    const refTokens = tokenize(reference);
    const predTokens = tokenize(prediction);

    if (refTokens.length === 0 && predTokens.length === 0) {
        return 1;
    }
    if (refTokens.length === 0 || predTokens.length === 0) {
        return 0;
    }

    const overlap = intersectionSize(countTokens(refTokens), countTokens(predTokens));
    if (overlap === 0) {
        return 0;
    }

    const precision = overlap / predTokens.length;
    const recall = overlap / refTokens.length;
    return (2 * precision * recall) / (precision + recall);
}

function uniqueRelevantHits(results, relevantIds, k) {
    if (!Array.isArray(relevantIds) || relevantIds.length === 0) {
        return 0;
    }

    const expected = new Set(relevantIds.map(String));
    const seen = new Set();
    const sliced = Array.isArray(results) ? results.slice(0, k) : [];

    for (const result of sliced) {
        const candidateId = result?.id ?? result?.payload?.id ?? result?.payload?.doc_id;
        const normalizedId = candidateId == null ? null : String(candidateId);
        if (normalizedId && expected.has(normalizedId)) {
            seen.add(normalizedId);
        }
    }

    return seen.size;
}

function recallAtK(results, relevantIds, k) {
    if (!Array.isArray(relevantIds) || relevantIds.length === 0) {
        return null;
    }
    return uniqueRelevantHits(results, relevantIds, k) / relevantIds.length;
}

function precisionAtK(results, relevantIds, k) {
    if (!Array.isArray(relevantIds) || relevantIds.length === 0) {
        return null;
    }
    if (!k) {
        return 0;
    }
    return uniqueRelevantHits(results, relevantIds, k) / k;
}

function meanReciprocalRank(results, relevantIds) {
    if (!Array.isArray(relevantIds) || relevantIds.length === 0) {
        return null;
    }

    const expected = new Set(relevantIds.map(String));
    const ranked = Array.isArray(results) ? results : [];

    for (let index = 0; index < ranked.length; index += 1) {
        const candidateId = ranked[index]?.id ?? ranked[index]?.payload?.id ?? ranked[index]?.payload?.doc_id;
        const normalizedId = candidateId == null ? null : String(candidateId);
        if (normalizedId && expected.has(normalizedId)) {
            return 1 / (index + 1);
        }
    }

    return 0;
}

function splitIntoClaims(text) {
    return String(text || "")
        .split(/[.!?\n]+/)
        .map((part) => part.trim())
        .filter(Boolean);
}

function bestClaimSupportScore(claim, contexts) {
    const claimTokens = tokenizeContent(claim);
    if (claimTokens.length === 0) {
        return 1;
    }

    const claimCounts = countTokens(claimTokens);
    let bestScore = 0;

    for (const context of contexts) {
        const contextTokens = tokenizeContent(context);
        if (contextTokens.length === 0) {
            continue;
        }

        const overlap = intersectionSize(claimCounts, countTokens(contextTokens));
        const recall = overlap / claimTokens.length;
        bestScore = Math.max(bestScore, recall);
        if (bestScore >= 1) {
            return 1;
        }
    }

    return bestScore;
}

function safeJsonParse(text) {
    try {
        return { valid: true, value: JSON.parse(String(text || "")) };
    } catch {
        return { valid: false, value: null };
    }
}

function collectLeafStrings(value, bucket = []) {
    if (value == null) {
        return bucket;
    }
    if (typeof value === "string") {
        const trimmed = value.trim();
        if (trimmed) {
            bucket.push(trimmed);
        }
        return bucket;
    }
    if (typeof value === "number" || typeof value === "boolean") {
        return bucket;
    }
    if (Array.isArray(value)) {
        for (const item of value) {
            collectLeafStrings(item, bucket);
        }
        return bucket;
    }
    if (typeof value === "object") {
        for (const item of Object.values(value)) {
            collectLeafStrings(item, bucket);
        }
    }
    return bucket;
}

function extractAtomicClaims(answer) {
    const parsed = safeJsonParse(answer);
    if (!parsed.valid) {
        return splitIntoClaims(answer);
    }

    return collectLeafStrings(parsed.value)
        .flatMap((value) => splitIntoClaims(value))
        .map((claim) => claim.trim())
        .filter((claim) => tokenizeContent(claim).length >= 2);
}

function faithfulnessScore(answer, contexts, threshold = 0.5) {
    const claims = extractAtomicClaims(answer);
    if (claims.length === 0) {
        return {
            score: 1,
            supportedClaims: 0,
            totalClaims: 0,
            threshold,
            perClaim: []
        };
    }

    const contextList = Array.isArray(contexts) ? contexts.filter(Boolean) : [];
    if (contextList.length === 0) {
        return {
            score: 0,
            supportedClaims: 0,
            totalClaims: claims.length,
            threshold,
            perClaim: claims.map((claim) => ({
                claim,
                supportScore: 0,
                supported: false
            }))
        };
    }

    let supportedClaims = 0;
    const perClaim = [];

    for (const claim of claims) {
        const supportScore = bestClaimSupportScore(claim, contextList);
        const supported = supportScore >= threshold;
        if (supported) {
            supportedClaims += 1;
        }
        perClaim.push({ claim, supportScore, supported });
    }

    return {
        score: supportedClaims / claims.length,
        supportedClaims,
        totalClaims: claims.length,
        threshold,
        perClaim
    };
}

function parseGroundTruthRequirements(reference) {
    try {
        const parsed = JSON.parse(String(reference || ""));
        return Array.isArray(parsed?.requirements) ? parsed.requirements.filter(Boolean) : [];
    } catch {
        return [];
    }
}

function requirementCoverageScore(reference, prediction, threshold = 0.5) {
    const requirements = parseGroundTruthRequirements(reference);
    if (requirements.length === 0) {
        return null;
    }

    const predictionContexts = extractAtomicClaims(prediction);
    if (predictionContexts.length === 0) {
        return {
            score: 0,
            coveredRequirements: 0,
            totalRequirements: requirements.length,
            threshold,
            perRequirement: requirements.map((requirement) => ({
                requirement,
                supportScore: 0,
                covered: false
            }))
        };
    }

    let coveredRequirements = 0;
    const perRequirement = [];

    for (const requirement of requirements) {
        const supportScore = bestClaimSupportScore(requirement, predictionContexts);
        const covered = supportScore >= threshold;
        if (covered) {
            coveredRequirements += 1;
        }

        perRequirement.push({
            requirement,
            supportScore,
            covered
        });
    }

    return {
        score: coveredRequirements / requirements.length,
        coveredRequirements,
        totalRequirements: requirements.length,
        threshold,
        perRequirement
    };
}

function collectForbiddenTerms(example, retrievalResults) {
    const terms = new Set();
    const addTerm = (term) => {
        const normalized = normalizeText(term);
        if (normalized) {
            terms.add(normalized);
            if (TERM_SYNONYMS[normalized]) {
                for (const synonym of TERM_SYNONYMS[normalized]) {
                    terms.add(normalizeText(synonym));
                }
            }
        }
    };

    for (const result of Array.isArray(retrievalResults) ? retrievalResults : []) {
        const payload = result?.payload || {};
        for (const item of Array.isArray(payload.contraindicated_foods) ? payload.contraindicated_foods : []) {
            addTerm(item?.food);
        }
        for (const item of Array.isArray(payload.contraindicated_exercises) ? payload.contraindicated_exercises : []) {
            addTerm(item?.exercise);
        }
        for (const allergy of Array.isArray(payload.allergies) ? payload.allergies : []) {
            addTerm(allergy);
        }
    }

    const metadata = example?.metadata || {};
    addTerm(metadata.allergy);

    for (const requirement of parseGroundTruthRequirements(example?.groundTruthAnswer)) {
        const normalizedRequirement = normalizeText(requirement);
        if (normalizedRequirement.startsWith("avoid ")) {
            addTerm(normalizedRequirement.replace(/^avoid\s+/, ""));
        }
        if (normalizedRequirement.startsWith("no ")) {
            addTerm(normalizedRequirement.replace(/^no\s+/, ""));
        }
    }

    return [...terms].filter(Boolean);
}

function answerLeaves(answer) {
    const parsed = safeJsonParse(answer);
    if (!parsed.valid) {
        return splitIntoClaims(answer);
    }
    return collectLeafStrings(parsed.value);
}

function restrictionAdherenceScore(example, answer, retrievalResults) {
    const planSegments = answerLeaves(answer).map(normalizeText).filter(Boolean);
    const forbiddenTerms = collectForbiddenTerms(example, retrievalResults);

    if (forbiddenTerms.length === 0) {
        return {
            score: 1,
            totalForbiddenTerms: 0,
            violations: []
        };
    }

    const violations = [];
    const seen = new Set();

    for (const term of forbiddenTerms) {
        const tokens = term.split(" ").filter(Boolean);
        if (tokens.length === 0) {
            continue;
        }

        const match = planSegments.find((segment) => {
            if (/^(avoid|no|without|exclude|excluded|free of)\b/.test(segment)) {
                return false;
            }
            if (segment.includes(term)) {
                return true;
            }
            if (tokens.length === 1) {
                return segment.split(" ").includes(tokens[0]);
            }
            const segmentTokens = segment.split(" ");
            return tokens.every((token) => segmentTokens.includes(token));
        });

        if (match && !seen.has(term)) {
            seen.add(term);
            violations.push({ term, matchedText: match });
        }
    }

    const denominator = Math.max(1, Math.min(forbiddenTerms.length, 6));
    return {
        score: Math.max(0, 1 - (violations.length / denominator)),
        totalForbiddenTerms: forbiddenTerms.length,
        violations
    };
}

function planGroundingScore(example, answer, retrievalResults, retrievalContexts) {
    const requirementCoverage = requirementCoverageScore(example?.groundTruthAnswer, answer);
    const restrictionAdherence = restrictionAdherenceScore(example, answer, retrievalResults);
    const supportSignals = Array.isArray(retrievalContexts) && retrievalContexts.length > 0
        ? faithfulnessScore(answer, retrievalContexts, 0.2)
        : { score: 0, supportedClaims: 0, totalClaims: 0, threshold: 0.2, perClaim: [] };

    const weighted = [
        { weight: 0.65, value: restrictionAdherence.score },
        { weight: 0.25, value: requirementCoverage?.score ?? 0 },
        { weight: 0.10, value: supportSignals.score }
    ];
    const score = weighted.reduce((sum, item) => sum + (item.value * item.weight), 0);

    return {
        score,
        restrictionAdherence,
        requirementCoverage,
        supportSignals
    };
}

function overallPlanScore(metrics) {
    const weighted = [
        { weight: 0.35, value: metrics.restrictionAdherence },
        { weight: 0.25, value: metrics.requirementCoverage },
        { weight: 0.20, value: metrics.jsonValidity },
        { weight: 0.20, value: metrics.structureScore }
    ];

    const valid = weighted.filter((item) => typeof item.value === "number" && Number.isFinite(item.value));
    if (valid.length === 0) {
        return null;
    }

    const totalWeight = valid.reduce((sum, item) => sum + item.weight, 0);
    return valid.reduce((sum, item) => sum + (item.value * item.weight), 0) / totalWeight;
}

function average(values) {
    const filtered = values.filter((value) => typeof value === "number" && Number.isFinite(value));
    if (filtered.length === 0) {
        return null;
    }
    return filtered.reduce((sum, value) => sum + value, 0) / filtered.length;
}

module.exports = {
    average,
    exactMatch,
    f1Score,
    faithfulnessScore,
    meanReciprocalRank,
    normalizeText,
    overallPlanScore,
    parseGroundTruthRequirements,
    planGroundingScore,
    precisionAtK,
    recallAtK,
    requirementCoverageScore,
    restrictionAdherenceScore,
    splitIntoClaims,
    tokenize
};
