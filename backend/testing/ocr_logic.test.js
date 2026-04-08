const { analyzeImage } = require('../ocr_logic');

// Mock global fetch
global.fetch = jest.fn();

describe('OCR Logic', () => {
    beforeEach(() => {
        fetch.mockClear();
    });

    test('analyzeImage should return extracted text on success', async () => {
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({
                choices: [{ message: { content: 'Healthy report' } }]
            })
        });

        const result = await analyzeImage('base64data', 'medical');
        expect(result).toBe('Healthy report');
        expect(fetch).toHaveBeenCalledWith(
            "https://openrouter.ai/api/v1/chat/completions",
            expect.objectContaining({
                method: "POST",
                body: expect.stringContaining("meta-llama/Llama-3.2-11B-Vision-Instruct")
            })
        );
    });

    test('analyzeImage should return error message on failure', async () => {
        fetch.mockResolvedValueOnce({
            ok: false,
            status: 500,
            text: async () => 'Internal Error'
        });

        const result = await analyzeImage('base64data', 'medical');
        expect(result).toContain('Error extracting medical report');
    });
});
