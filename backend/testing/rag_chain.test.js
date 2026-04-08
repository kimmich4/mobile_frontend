const { ragChain } = require('../rag_chain');
const { getEmbedding, queryQdrant } = require('../rag_logic');
const { generateAnswer } = require('../plan_generator');

jest.mock('../rag_logic');
jest.mock('../plan_generator');

describe('RAG Chain Orchestration', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    test('ragChain should skip vector search for empty query', async () => {
        generateAnswer.mockResolvedValue('{"result": "success"}');
        
        await ragChain.invoke({ searchQuery: "none", contextPrefix: "{{VECTOR_CONTEXT}}", task: "Generate diet" });

        expect(getEmbedding).not.toHaveBeenCalled();
        expect(queryQdrant).not.toHaveBeenCalled();
        expect(generateAnswer).toHaveBeenCalledWith(
            expect.stringContaining("No specific contraindications"),
            "Generate diet"
        );
    });

    test('ragChain should perform full search for valid query', async () => {
        getEmbedding.mockResolvedValue([0.1, 0.2]);
        queryQdrant.mockResolvedValue([{ payload: { issue: "Diabetes", contraindicated_foods: [{food: "Sugar"}] } }]);
        generateAnswer.mockResolvedValue('{"result": "success"}');

        const response = await ragChain.invoke({ 
            searchQuery: "Diabetes", 
            contextPrefix: "User Context. {{VECTOR_CONTEXT}}", 
            task: "Generate diet" 
        });

        expect(getEmbedding).toHaveBeenCalledWith("Diabetes");
        expect(queryQdrant).toHaveBeenCalledWith([0.1, 0.2]);
        expect(generateAnswer).toHaveBeenCalledWith(
            expect.stringContaining("Issue: Diabetes"),
            "Generate diet"
        );
        expect(response).toBe('{"result": "success"}');
    });
});
