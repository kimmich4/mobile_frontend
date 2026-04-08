const { getEmbedding, queryQdrant } = require('../rag_logic');
const { qdrant } = require('../qdrant_client');
const { HfInference } = require('@huggingface/inference');

jest.mock('@huggingface/inference');
jest.mock('../qdrant_client');

describe('RAG Logic Helpers', () => {
    test('getEmbedding should return a numeric vector', async () => {
        const mockFeatureExtraction = jest.fn().mockResolvedValue([0.1, 0.2, 0.3]);
        HfInference.prototype.featureExtraction = mockFeatureExtraction;

        const result = await getEmbedding("test query");
        expect(result).toEqual([0.1, 0.2, 0.3]);
    });

    test('queryQdrant should call search on qdrant client', async () => {
        const mockSearch = jest.fn().mockResolvedValue([{ id: 1, payload: {} }]);
        qdrant.search = mockSearch;

        const result = await queryQdrant([0.1, 0.2]);
        expect(mockSearch).toHaveBeenCalledWith("athlete_health_context", expect.objectContaining({
            vector: [0.1, 0.2],
            limit: 3
        }));
        expect(result).toEqual([{ id: 1, payload: {} }]);
    });
});
