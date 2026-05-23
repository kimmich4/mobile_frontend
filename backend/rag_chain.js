require("dotenv").config();
const { RunnableLambda, RunnableSequence } = require("@langchain/core/runnables");

const { getEmbedding, queryQdrant } = require("./rag_logic");
const { generateAnswer } = require("./plan_generator");
const { enforceStructuredPlan } = require("./structured_output");
const { formatVectorContext, rankRetrievedResults } = require("./retrieval_helpers");

//
// langchain full plan orchestration pipeline
//
// step 1 to validate & normalise query
// step 2 to generate huggingface embedding
// step 3 to search qdrant vector db
// step 4 to build prompt (resolves vector db results into the generic context)
// step 5 to deepseek llm generation (generates json plan)
//
//

// step 1 - validate & normalise the incoming health-profile query
const step_validateQuery = RunnableLambda.from(async (inputObj) => {
    console.log(`\nlangchain full plan step 1 - validate query`);

    // support either a raw string (for old unit tests) or the full object (from express routes)
    const state = typeof inputObj === 'string' ? { searchQuery: inputObj, contextPrefix: "", task: "" } : inputObj;

    console.log(`   Input: "${state.searchQuery}"`);

    const cleanProfile = state.searchQuery
        ? state.searchQuery.toLowerCase().replace(/none/g, "").replace(/[,.\s]/g, "")
        : "";

    if (!cleanProfile) {
        console.log(`   empty/none profile - chain will short-circuit vector search.`);
        return { ...state, skip: true };
    }

    console.log(`   query is valid, passing to embedding step.`);
    return { ...state, skip: false };
});

// step 2 - generate embedding via huggingface (delegates to getembedding in raglogic.js)
const step_getEmbedding = RunnableLambda.from(async (state) => {
    console.log(`\nlangchain full plan step 2 - get embedding`);
    if (state.skip) {
        console.log(`   skipping embedding (empty profile).`);
        return state;
    }
    console.log(`   calling huggingface for: "${state.searchQuery}"`);
    try {
        const vector = await getEmbedding(state.searchQuery);
        console.log(`   embedding generated. vector length: ${vector.length}`);
        return { ...state, vector };
    } catch (e) {
        console.error("   embedding error:", e.message);
        return { ...state, skip: true }; // fallback
    }
});

// step 3 - search qdrant vector db (delegates to queryqdrant in raglogic.js)
const step_qdrantSearch = RunnableLambda.from(async (state) => {
    console.log(`\nlangchain full plan step 3 - qdrant search`);
    if (state.skip) {
        console.log(`   skipping qdrant search.`);
        return state;
    }
    console.log(`   searching collection "athlete_health_context"...`);
    let result = [];
    try {
        result = await queryQdrant(state.vector);
        result = rankRetrievedResults(result, state.searchQuery);
    } catch (e) {
        console.error("   qdrant search error:", e.message);
    }

    if (result && result.length > 0) {
        console.log(`   found ${result.length} matches.`);
        console.log("   Results payload:", JSON.stringify(result.map(r => ({ score: r.score, payload: r.payload })), null, 2));
    } else {
        console.log(`   0 matches found.`);
    }
    return { ...state, results: result };
});

// step 4 - build final prompt from context string
const step_buildFinalContext = RunnableLambda.from(async (state) => {
    console.log(`\nlangchain full plan step 4 - build final context`);

    // resolve vector results into compact, plan-relevant safety constraints.
    let vectorContext = "No specific contraindications found in database.";
    if (!state.skip && state.results && state.results.length > 0) {
        vectorContext = formatVectorContext(state.results);
        console.log(`   vector context resolved.`);
    } else {
        console.log(`   no vector results to format - using default string.`);
    }

    // inject the resolved vectorcontext into the {{vectorcontext}} placeholder
    const finalContext = state.contextPrefix ? state.contextPrefix.replace('{{VECTOR_CONTEXT}}', vectorContext) : vectorContext;
    return { ...state, finalContext };
});

// step 5 - ai generation (deepseek via plangenerator.js)
const step_generateAnswer = RunnableLambda.from(async (state) => {
    console.log(`\nlangchain full plan step 5 - llm generation`);

    // if we only passed a string (like a basic unit test), just return the context directly.
    if (!state.task) {
        console.log(`   no task provided. returning resolved context string.`);
        return state.finalContext;
    }

    console.log(`   calling deepseek v3...`);

    // print the final complete prompt so the user can see everything clearly
    console.log(`\n================= final ai prompt =================`);
    console.log(`[Context Body]:\n${state.finalContext}`);
    console.log(`\n[Task Header]:\n${state.task}`);
    console.log(`======================================================\n`);

    // this calls the robust generateanswer function which includes the 3-attempt retry loop
    const aiResponse = await generateAnswer(state.finalContext, state.task);
    console.log(`   successfully generated ai plan.`);
    return enforceStructuredPlan(aiResponse, state.finalContext, state.task);
});

// compose the sequence
const ragChain = RunnableSequence.from([
    step_validateQuery,
    step_getEmbedding,
    step_qdrantSearch,
    step_buildFinalContext,
    step_generateAnswer
]);

module.exports = { ragChain };
