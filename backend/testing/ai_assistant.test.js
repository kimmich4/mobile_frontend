const { chatAssistant } = require('../ai_assistant');

// Mock global fetch
global.fetch = jest.fn();

describe('AI Assistant', () => {
    beforeEach(() => {
        fetch.mockClear();
    });

    test('chatAssistant should return response from the first successful model', async () => {
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({
                choices: [{ message: { content: 'Hello from AI' } }]
            })
        });

        const messages = [{ role: 'user', content: 'Hi' }];
        const response = await chatAssistant(messages);

        expect(response).toBe('Hello from AI');
        expect(fetch).toHaveBeenCalledTimes(1);
    });

    test('chatAssistant should try next model if the first one fails with 429', async () => {
        // First model fails with 429
        fetch.mockResolvedValueOnce({
            ok: false,
            status: 429,
            text: async () => 'Rate limit exceeded'
        });
        // Second model succeeds
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({
                choices: [{ message: { content: 'Hello from model 2' } }]
            })
        });

        const messages = [{ role: 'user', content: 'Hi' }];
        const response = await chatAssistant(messages);

        expect(response).toBe('Hello from model 2');
        expect(fetch).toHaveBeenCalledTimes(2);
    });

    test('chatAssistant should throw error if all models fail', async () => {
        fetch.mockResolvedValue({
            ok: false,
            status: 500,
            text: async () => 'Internal Server Error'
        });

        const messages = [{ role: 'user', content: 'Hi' }];
        await expect(chatAssistant(messages)).rejects.toThrow('Chat API Error: 500');
    });
});
