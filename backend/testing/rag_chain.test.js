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
        expect(JSON.parse(response)).toEqual({ result: "success" });
    });

    test('ragChain should normalize alternative workout JSON shapes', async () => {
        getEmbedding.mockResolvedValue([0.1, 0.2]);
        queryQdrant.mockResolvedValue([{ payload: { issue: "Back Pain", contraindicated_exercises: [{ exercise: "Deadlift" }] } }]);
        generateAnswer.mockResolvedValue(JSON.stringify({
            "7_day_exercise_plan": [
                {
                    gym_workout: [{ exercise: "Deadlift", sets: "3", reps: "8" }],
                    home_workout: ["Bird-Dog (3x10)"]
                }
            ]
        }));

        const response = await ragChain.invoke({
            searchQuery: "Back Pain",
            contextPrefix: "User Context. {{VECTOR_CONTEXT}}",
            task: "Create a 7-day exercise plan."
        });

        const parsed = JSON.parse(response);
        expect(parsed).toHaveProperty('gym');
        expect(parsed).toHaveProperty('home');
        expect(parsed.gym.days[0].exercises[0].name).toContain('Safe substitute');
    });
});
