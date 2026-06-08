

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

// helpers

/* fire count identical requests in parallel and return all results.*/
async function concurrent(reqFn, count) {
    return Promise.all(Array.from({ length: count }, () => reqFn()));
}

/* fire count requests one after another and collect results and durations.*/
async function sequential(reqFn, count) {
    const results = [];
    for (let i = 0; i < count; i++) {
        const t0 = Date.now();
        const res = await reqFn();
        results.push({ res, ms: Date.now() - t0 });
    }
    return results;
}

/* standard user profile payload used across diet or workout tests.*/
const BASE_PROFILE = {
    userId: 'stress-user-001',
    fullName: 'Stress Tester',
    age: 28,
    height_cm: 178,
    weight_kg: 80,
    target_weight_kg: 75,
    gender: 'male',
    activity_level: 'moderate',
    goal: 'fat loss',
    health_conditions: 'none',
    allergies: 'none',
    injuries: 'none',
    experience_level: 'intermediate',
    training_days_per_week: 5,
    preferred_workout_split: 'Push/Pull/Legs',
};

// Service Level Agreement thresholds (ms) 
//maximum acceptable response time for an API request to be considered successful.
const SLA = {
    health: 50, // trivial endpoint
    chat: 150,
    analyzeReport: 150,
    generateDiet: 200,
    generateWorkout: 200,
    searchVideo: 150,
};

// mock payloads
const MOCK_DIET = JSON.stringify({ days: Array.from({ length: 7 }, (_, i) => ({ day: i + 1, meals: [] })) });
const MOCK_WORKOUT = JSON.stringify({ gym: { title: 'Gym Plan', days: [] }, home: { title: 'Home Plan', days: [] } });

// 1. get /health concurrent and sequential stress
describe('Stress: GET /health', () => {
    const hit = () => request(app).get('/health');

    test('handles 50 concurrent requests — all return 200', async () => {
        const results = await concurrent(hit, 50);
        results.forEach(r => {
            expect(r.status).toBe(200);
            expect(r.body.status).toBe('ok');
        });
    });

    test('handles 100 sequential requests within SLA', async () => {
        const results = await sequential(hit, 100);
        results.forEach(({ res, ms }) => {
            expect(res.status).toBe(200);
            expect(ms).toBeLessThan(SLA.health);
        });
    });
});

// 2. post /ai/chat concurrent and burst
describe('Stress: POST /ai/chat', () => {
    beforeEach(() => {
        chatAssistant.mockResolvedValue('Stress test response from AI');
    });

    afterEach(() => jest.clearAllMocks());

    const hit = (msgOverride) =>
        request(app)
            .post('/ai/chat')
            .send({ messages: msgOverride ?? [{ role: 'user', content: 'Hello' }] });

    test('handles 30 concurrent chat requests — all succeed', async () => {
        const results = await concurrent(hit, 30);
        results.forEach(r => {
            expect(r.status).toBe(200);
            expect(r.body.response).toBe('Stress test response from AI');
        });
        expect(chatAssistant).toHaveBeenCalledTimes(30);
    });

    test('handles 50 sequential requests within SLA', async () => {
        const results = await sequential(hit, 50);
        results.forEach(({ res, ms }) => {
            expect(res.status).toBe(200);
            expect(ms).toBeLessThan(SLA.chat);
        });
    });

    test('rejects missing messages consistently under load (20 concurrent)', async () => {
        const results = await concurrent(
            () => request(app).post('/ai/chat').send({}),
            20
        );
        results.forEach(r => expect(r.status).toBe(400));
    });

    test('handles extremely long message array (500 messages)', async () => {
        const bigMessages = Array.from({ length: 500 }, (_, i) => ({
            role: i % 2 === 0 ? 'user' : 'assistant',
            content: `Message number ${i} — ${'x'.repeat(200)}`,
        }));
        const res = await hit(bigMessages);
        expect(res.status).toBe(200);
    });

    test('handles 10 concurrent requests where AI throws errors', async () => {
        chatAssistant.mockRejectedValue(new Error('Simulated AI outage'));
        const results = await concurrent(hit, 10);
        results.forEach(r => expect(r.status).toBe(500));
    });
});

// 3. post /ai/analyze-report concurrent and large payload
describe('Stress: POST /ai/analyze-report', () => {
    beforeEach(() => {
        analyzeImage.mockResolvedValue('Extracted report text');
    });

    afterEach(() => jest.clearAllMocks());

    const hit = (body) =>
        request(app)
            .post('/ai/analyze-report')
            .send(body ?? { base64Image: 'aGVsbG8=', type: 'inbody' });

    test('handles 20 concurrent report-analysis requests — all succeed', async () => {
        const results = await concurrent(hit, 20);
        results.forEach(r => {
            expect(r.status).toBe(200);
            expect(r.body.extractedText).toBe('Extracted report text');
        });
    });

    test('handles 30 sequential requests within SLA', async () => {
        const results = await sequential(hit, 30);
        results.forEach(({ res, ms }) => {
            expect(res.status).toBe(200);
            expect(ms).toBeLessThan(SLA.analyzeReport);
        });
    });

    test('handles large base64 image payload (≈ 5 MB string)', async () => {
        const largeBase64 = 'A'.repeat(5 * 1024 * 1024); // 5 mb
        const res = await hit({ base64Image: largeBase64, type: 'medical' });
        expect(res.status).toBe(200);
    });

    test('rejects missing image consistently under load (15 concurrent)', async () => {
        const results = await concurrent(
            () => request(app).post('/ai/analyze-report').send({ type: 'medical' }),
            15
        );
        results.forEach(r => expect(r.status).toBe(400));
    });
});

// 4. post /ai/generate-diet concurrent and edge profiles
describe('Stress: POST /ai/generate-diet', () => {
    beforeEach(() => {
        ragChain.invoke.mockResolvedValue(MOCK_DIET);
    });

    afterEach(() => jest.clearAllMocks());

    const hit = (body) =>
        request(app)
            .post('/ai/generate-diet')
            .send(body ?? BASE_PROFILE);

    test('handles 25 concurrent diet-plan requests — all return 7 days', async () => {
        const results = await concurrent(hit, 25);
        results.forEach(r => {
            expect(r.status).toBe(200);
            expect(r.body.days).toHaveLength(7);
        });
        expect(ragChain.invoke).toHaveBeenCalledTimes(25);
    });

    test('handles 40 sequential requests within SLA', async () => {
        const results = await sequential(hit, 40);
        results.forEach(({ res, ms }) => {
            expect(res.status).toBe(200);
            expect(ms).toBeLessThan(SLA.generateDiet);
        });
    });

    test('handles extreme body weight values without crashing (1 kg → 500 kg)', async () => {
        const weights = [1, 50, 100, 200, 300, 500];
        const results = await concurrent(
            () => { }, // placeholder replaced below
            0
        );
        const realResults = await Promise.all(
            weights.map(w => hit({ ...BASE_PROFILE, weight_kg: w }))
        );
        realResults.forEach(r => expect(r.status).toBe(200));
    });

    test('handles all activity-level variants concurrently', async () => {
        const levels = ['sedentary', 'lightly active', 'moderate', 'very active', 'extra active'];
        const realResults = await Promise.all(
            levels.map(l => hit({ ...BASE_PROFILE, activity_level: l }))
        );
        realResults.forEach(r => expect(r.status).toBe(200));
    });

    test('handles all goal variants concurrently', async () => {
        const goals = ['lose weight', 'build muscle', 'maintain weight', 'fat loss', 'bulk'];
        const realResults = await Promise.all(
            goals.map(g => hit({ ...BASE_PROFILE, goal: g }))
        );
        realResults.forEach(r => expect(r.status).toBe(200));
    });

    test('returns 500 gracefully when ragChain fails under load (15 concurrent)', async () => {
        ragChain.invoke.mockRejectedValue(new Error('Vector DB unreachable'));
        const results = await concurrent(hit, 15);
        results.forEach(r => expect(r.status).toBe(500));
    });

    test('handles missing optional fields without crashing (20 concurrent)', async () => {
        const minimal = { weight_kg: 70, height_cm: 175, age: 25, gender: 'female' };
        const results = await concurrent(() => hit(minimal), 20);
        results.forEach(r => expect(r.status).toBe(200));
    });

    test('handles maximum field lengths without crashing', async () => {
        const longString = 'x'.repeat(2000);
        const res = await hit({
            ...BASE_PROFILE,
            health_conditions: longString,
            allergies: longString,
            injuries: longString,
            other_medical: longString,
            other_allergy: longString,
            medical_report_text: longString,
            inbody_report_text: longString,
        });
        expect(res.status).toBe(200);
    });
});

// 5. post /ai/generate-workout concurrent and edge profiles
describe('Stress: POST /ai/generate-workout', () => {
    beforeEach(() => {
        ragChain.invoke.mockResolvedValue(MOCK_WORKOUT);
    });

    afterEach(() => jest.clearAllMocks());

    const hit = (body) =>
        request(app)
            .post('/ai/generate-workout')
            .send(body ?? BASE_PROFILE);

    test('handles 25 concurrent workout-plan requests — all return gym + home', async () => {
        const results = await concurrent(hit, 25);
        results.forEach(r => {
            expect(r.status).toBe(200);
            expect(r.body).toHaveProperty('gym');
            expect(r.body).toHaveProperty('home');
        });
        expect(ragChain.invoke).toHaveBeenCalledTimes(25);
    });

    test('handles 40 sequential requests within SLA', async () => {
        const results = await sequential(hit, 40);
        results.forEach(({ res, ms }) => {
            expect(res.status).toBe(200);
            expect(ms).toBeLessThan(SLA.generateWorkout);
        });
    });

    test('handles all training-day counts (1–7) concurrently', async () => {
        const days = [1, 2, 3, 4, 5, 6, 7];
        const results = await Promise.all(
            days.map(d => hit({ ...BASE_PROFILE, training_days_per_week: d }))
        );
        results.forEach(r => expect(r.status).toBe(200));
    });

    test('handles common workout splits concurrently', async () => {
        const splits = [
            'Push/Pull/Legs', 'Upper/Lower', 'Full Body',
            'Bro Split', 'Arnold Split', 'Not specified',
        ];
        const results = await Promise.all(
            splits.map(s => hit({ ...BASE_PROFILE, preferred_workout_split: s }))
        );
        results.forEach(r => expect(r.status).toBe(200));
    });

    test('returns 500 gracefully when ragChain fails under load (15 concurrent)', async () => {
        ragChain.invoke.mockRejectedValue(new Error('Vector DB unreachable'));
        const results = await concurrent(hit, 15);
        results.forEach(r => expect(r.status).toBe(500));
    });

    test('handles missing optional fields without crashing (20 concurrent)', async () => {
        const minimal = { weight_kg: 70, height_cm: 175, age: 25, gender: 'male' };
        const results = await concurrent(() => hit(minimal), 20);
        results.forEach(r => expect(r.status).toBe(200));
    });
});

// 6. post /ai/search-video concurrent and edge cases
describe('Stress: POST /ai/search-video', () => {
    beforeEach(() => {
        ytSearch.mockResolvedValue({ videos: [{ videoId: 'stress_vid_001' }] });
    });

    afterEach(() => jest.clearAllMocks());

    const hit = (query) =>
        request(app)
            .post('/ai/search-video')
            .send({ query: query ?? 'bench press tutorial' });

    test('handles 30 concurrent video-search requests — all return videoId', async () => {
        const results = await concurrent(hit, 30);
        results.forEach(r => {
            expect(r.status).toBe(200);
            expect(r.body.videoId).toBe('stress_vid_001');
        });
    });

    test('handles 50 sequential requests within SLA', async () => {
        const results = await sequential(() => hit(), 50);
        results.forEach(({ res, ms }) => {
            expect(res.status).toBe(200);
            expect(ms).toBeLessThan(SLA.searchVideo);
        });
    });

    test('rejects empty query consistently under load (20 concurrent)', async () => {
        const results = await concurrent(
            () => request(app).post('/ai/search-video').send({}),
            20
        );
        results.forEach(r => expect(r.status).toBe(400));
    });

    test('handles very long query string without crashing', async () => {
        const longQuery = 'workout '.repeat(500); // 4 kb query
        const res = await hit(longQuery);
        expect(res.status).toBe(200);
    });

    test('returns 404 gracefully when YouTube returns no videos (10 concurrent)', async () => {
        ytSearch.mockResolvedValue({ videos: [] });
        const results = await concurrent(hit, 10);
        results.forEach(r => expect(r.status).toBe(404));
    });

    test('returns 500 gracefully when YouTube search throws (10 concurrent)', async () => {
        ytSearch.mockRejectedValue(new Error('YouTube API down'));
        const results = await concurrent(hit, 10);
        results.forEach(r => expect(r.status).toBe(500));
    });
});

// 7. mixed endpoint stress all routes hit simultaneously
describe('Stress: Mixed concurrent load across all endpoints', () => {
    beforeEach(() => {
        chatAssistant.mockResolvedValue('ok');
        analyzeImage.mockResolvedValue('ok');
        ragChain.invoke.mockResolvedValue(MOCK_DIET);
        ytSearch.mockResolvedValue({ videos: [{ videoId: 'mix_vid' }] });
    });

    afterEach(() => jest.clearAllMocks());

    test('all endpoints respond correctly under simultaneous load', async () => {
        const requests = [
            ...Array.from({ length: 10 }, () =>
                request(app).get('/health')
            ),
            ...Array.from({ length: 10 }, () =>
                request(app).post('/ai/chat').send({ messages: [{ role: 'user', content: 'Hi' }] })
            ),
            ...Array.from({ length: 10 }, () =>
                request(app).post('/ai/analyze-report').send({ base64Image: 'abc=', type: 'inbody' })
            ),
            ...Array.from({ length: 10 }, () =>
                request(app).post('/ai/generate-diet').send(BASE_PROFILE)
            ),
            ...Array.from({ length: 10 }, () =>
                request(app).post('/ai/generate-workout').send(BASE_PROFILE)
            ),
            ...Array.from({ length: 10 }, () =>
                request(app).post('/ai/search-video').send({ query: 'squat form' })
            ),
        ];

        const results = await Promise.all(requests);
        const failed = results.filter(r => r.status >= 500);
        expect(failed.length).toBe(0); // zero server errors
    });
});

// 8. performance benchmarks p95 latency
describe('Stress: Performance benchmarks (p95 latency)', () => {
    beforeEach(() => {
        chatAssistant.mockResolvedValue('bench');
        ragChain.invoke.mockResolvedValue(MOCK_WORKOUT);
        ytSearch.mockResolvedValue({ videos: [{ videoId: 'bench_vid' }] });
    });

    afterEach(() => jest.clearAllMocks());

    function p95(timings) {
        const sorted = [...timings].sort((a, b) => a - b);
        return sorted[Math.floor(sorted.length * 0.95)];
    }

    async function bench(reqFn, count) {
        const timings = [];
        await Promise.all(
            Array.from({ length: count }, async () => {
                const t0 = Date.now();
                await reqFn();
                timings.push(Date.now() - t0);
            })
        );
        return timings;
    }

    test('/health p95 latency < 250 ms over 100 requests', async () => {
        const timings = await bench(() => request(app).get('/health'), 100);
        expect(p95(timings)).toBeLessThan(250);
    });

    test('/ai/chat p95 latency < 200 ms over 50 requests', async () => {
        const timings = await bench(
            () => request(app).post('/ai/chat').send({ messages: [{ role: 'user', content: 'perf' }] }),
            50
        );
        expect(p95(timings)).toBeLessThan(200);
    });

    test('/ai/generate-workout p95 latency < 300 ms over 30 requests', async () => {
        const timings = await bench(
            () => request(app).post('/ai/generate-workout').send(BASE_PROFILE),
            30
        );
        expect(p95(timings)).toBeLessThan(300);
    });
});
