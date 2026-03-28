require("dotenv").config();
const { RunnableLambda, RunnableSequence } = require("@langchain/core/runnables");

const { getEmbedding, queryQdrant } = require("./rag_logic");
const { generateAnswer } = require("./plan_generator");

// ─────────────────────────────────────────────────────────────────────────────
// 🦜 LangChain Full Plan Orchestration Pipeline
//
//  Step 1  →  Validate & normalise query
//  Step 2  →  Generate HuggingFace embedding   
//  Step 3  →  Search Qdrant vector DB          
//  Step 4  →  Build Prompt (resolves vector DB results into the generic Context)
//  Step 5  →  DeepSeek LLM Generation (generates JSON plan)
//
// ─────────────────────────────────────────────────────────────────────────────

// Step 1 — Validate & normalise the incoming health-profile query
const step_validateQuery = RunnableLambda.from(async (inputObj) => {
    console.log(`\n🦜 [LangChain Full Plan] Step 1 — Validate Query`);

    // Support either a raw string (for old unit tests) or the full object (from Express routes)
    const state = typeof inputObj === 'string' ? { searchQuery: inputObj, contextPrefix: "", task: "" } : inputObj;

    console.log(`   Input: "${state.searchQuery}"`);

    const cleanProfile = state.searchQuery
        ? state.searchQuery.toLowerCase().replace(/none/g, "").replace(/[,.\s]/g, "")
        : "";

    if (!cleanProfile) {
        console.log(`   ⚠️  Empty/none profile — chain will short-circuit vector search.`);
        return { ...state, skip: true };
    }

    console.log(`   ✅ Query is valid, passing to embedding step.`);
    return { ...state, skip: false };
});

// Step 2 — Generate embedding via HuggingFace (delegates to getEmbedding in rag_logic.js)
const step_getEmbedding = RunnableLambda.from(async (state) => {
    console.log(`\n🦜 [LangChain Full Plan] Step 2 — Get Embedding`);
    if (state.skip) {
        console.log(`   ⏭️  Skipping embedding (empty profile).`);
        return state;
    }
    console.log(`   🔢 Calling HuggingFace for: "${state.searchQuery}"`);
    try {
        const vector = await getEmbedding(state.searchQuery);
        console.log(`   ✅ Embedding generated. Vector length: ${vector.length}`);
        return { ...state, vector };
    } catch (e) {
        console.error("   ⚠️ Embedding Error:", e.message);
        return { ...state, skip: true }; // Fallback
    }
});

// Step 3 — Search Qdrant vector DB (delegates to queryQdrant in rag_logic.js)
const step_qdrantSearch = RunnableLambda.from(async (state) => {
    console.log(`\n🦜 [LangChain Full Plan] Step 3 — Qdrant Search`);
    if (state.skip) {
        console.log(`   ⏭️  Skipping Qdrant search.`);
        return state;
    }
    console.log(`   🔍 Searching collection "athlete_health_context" …`);
    let result = [];
    try {
        result = await queryQdrant(state.vector);
    } catch (e) {
        console.error("   ⚠️ Qdrant Search Error:", e.message);
    }

    if (result && result.length > 0) {
        console.log(`   ✅ Found ${result.length} matches.`);
        console.log("   Results payload:", JSON.stringify(result.map(r => ({ score: r.score, payload: r.payload })), null, 2));
    } else {
        console.log(`   ℹ️  0 matches found.`);
    }
    return { ...state, results: result };
});

// Step 4 — Build Final Prompt from context string
const step_buildFinalContext = RunnableLambda.from(async (state) => {
    console.log(`\n🦜 [LangChain Full Plan] Step 4 — Build Final Context`);

    // Resolve Vector String
    let vectorContext = "No specific contraindications found in database.";
    if (!state.skip && state.results && state.results.length > 0) {
        vectorContext = state.results.map(r => {
            const p = r.payload;
            return `Issue: ${p.issue || 'N/A'}. Constraints: Foods to avoid (${(p.contraindicated_foods || []).map(f => f.food).join(", ")}), Exercises to avoid (${(p.contraindicated_exercises || []).map(e => e.exercise).join(", ")})`;
        }).join("\n");
        console.log(`   ✅ Vector Context resolved.`);
    } else {
        console.log(`   ℹ️  No vector results to format — using default string.`);
    }

    // Inject the resolved vectorContext into the {{VECTOR_CONTEXT}} placeholder
    const finalContext = state.contextPrefix ? state.contextPrefix.replace('{{VECTOR_CONTEXT}}', vectorContext) : vectorContext;
    return { ...state, finalContext };
});

// Step 5 — AI Generation (DeepSeek via plan_generator.js)
const step_generateAnswer = RunnableLambda.from(async (state) => {
    console.log(`\n🦜 [LangChain Full Plan] Step 5 — LLM Generation`);

    // If we only passed a string (like a basic unit test), just return the context directly.
    if (!state.task) {
        console.log(`   ⏭️  No task provided. Returning resolved context string.`);
        return state.finalContext;
    }

    console.log(`   🧠 Calling DeepSeek V3...`);

    // Print the final complete prompt so the user can see everything clearly
    console.log(`\n================= 📝 FINAL AI PROMPT =================`);
    console.log(`[Context Body]:\n${state.finalContext}`);
    console.log(`\n[Task Header]:\n${state.task}`);
    console.log(`======================================================\n`);

    // This calls the robust generateAnswer function which includes the 3-attempt retry loop
    const aiResponse = await generateAnswer(state.finalContext, state.task);
    console.log(`   ✅ Successfully generated AI Plan.`);
    return aiResponse; // Returns the raw JSON string
});

// ─── Compose the sequence ──
const ragChain = RunnableSequence.from([
    step_validateQuery,
    step_getEmbedding,
    step_qdrantSearch,
    step_buildFinalContext,
    step_generateAnswer
]);

module.exports = { ragChain };
