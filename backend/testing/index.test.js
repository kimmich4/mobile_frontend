const request = require('supertest');
const { app } = require('../index');
const { ragChain } = require('../rag_chain');
const { chatAssistant } = require('../ai_assistant');
const { analyzeImage } = require('../ocr_logic');

jest.mock('../rag_chain');
jest.mock('../ai_assistant');
jest.mock('../ocr_logic');
jest.mock('yt-search');
const ytSearch = require('yt-search');

describe('Express API Routes', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    test('GET /health should return 200 ok', async () => {
        const res = await request(app).get('/health');
        expect(res.status).toBe(200);
        expect(res.body).toEqual({ status: 'ok', environment: 'BypassMode' });
    });

    test('POST /ai/chat should return AI response', async () => {
        chatAssistant.mockResolvedValue('Hello there!');
        const res = await request(app)
            .post('/ai/chat')
            .send({ messages: [{ role: 'user', content: 'Hi' }] });
        
        expect(res.status).toBe(200);
        expect(res.body.response).toBe('Hello there!');
    });

    test('POST /ai/analyze-report should call analyzeImage', async () => {
        analyzeImage.mockResolvedValue('Summary of report');
        const res = await request(app)
            .post('/ai/analyze-report')
            .send({ base64Image: 'data', type: 'inbody' });
        
        expect(res.status).toBe(200);
        expect(res.body.extractedText).toBe('Summary of report');
    });

    test('POST /ai/generate-diet should return diet plan JSON', async () => {
        const mockDiet = JSON.stringify({ days: [{ day: 1, meals: [] }] });
        ragChain.invoke.mockResolvedValue(mockDiet);

        const res = await request(app)
            .post('/ai/generate-diet')
            .send({ weight_kg: 70, height_cm: 175, age: 25, gender: 'male' });
        
        expect(res.status).toBe(200);
        expect(res.body.days.length).toBe(1);
    });

    test('POST /ai/generate-workout should return workout plan JSON', async () => {
        const mockWorkout = JSON.stringify({ gym: { days: [] }, home: { days: [] } });
        ragChain.invoke.mockResolvedValue(mockWorkout);

        const res = await request(app)
            .post('/ai/generate-workout')
            .send({ weight_kg: 70, height_cm: 175, age: 25, gender: 'male' });
        
        expect(res.status).toBe(200);
        expect(res.body).toHaveProperty('gym');
        expect(res.body).toHaveProperty('home');
    });

    test('POST /ai/search-video should return videoId', async () => {
        ytSearch.mockResolvedValue({
            videos: [{ videoId: 'abc12345' }]
        });

        const res = await request(app)
            .post('/ai/search-video')
            .send({ query: 'pushups' });
        
        expect(res.status).toBe(200);
        expect(res.body.videoId).toBe('abc12345');
    });
});
