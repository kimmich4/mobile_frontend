const { qdrant } = require('../qdrant_client');

describe('Qdrant Client', () => {
    test('qdrant client should be initialized', () => {
        expect(qdrant).toBeDefined();
        // Since it's a real client, we just check if it has the expected methods
        expect(typeof qdrant.search).toBe('function');
        expect(typeof qdrant.upsert).toBe('function');
    });
});
