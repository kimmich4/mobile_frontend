

const request = require('supertest');
const fs = require('fs');
const path = require('path');

jest.mock('../rag_chain');
jest.mock('../ai_assistant');
jest.mock('../ocr_logic');
jest.mock('yt-search');

const { app } = require('../index');
const { ragChain } = require('../rag_chain');
const { chatAssistant } = require('../ai_assistant');
const { analyzeImage } = require('../ocr_logic');
const ytSearch = require('yt-search');

jest.setTimeout(600_000); // 10 min ceiling for full escalation

// constants
const LOAD_LEVELS = [1, 5, 10, 25, 50, 100, 200, 500, 600, 700, 800, 900, 1000];
const REQUEST_TIMEOUT = 5_000; // ms before a single request is counted as failed
const THRESHOLDS = {
    maxErrorPct: 0, // any 5xx or timeout is failure
    maxP95: 500, // ms
    maxP99: 1000, // ms
};

const MOCK_DIET = JSON.stringify({
    days: Array.from({ length: 7 }, (_, i) => ({ day: i + 1, meals: [] })),
});
const MOCK_WORKOUT = JSON.stringify({
    gym: { title: 'Gym Plan', days: [] },
    home: { title: 'Home Plan', days: [] },
});
const BASE_PROFILE = {
    userId: 'sqa-001', fullName: 'SQA Tester',
    age: 28, height_cm: 178, weight_kg: 80, target_weight_kg: 75,
    gender: 'male', activity_level: 'moderate', goal: 'fat loss',
    training_days_per_week: 5, preferred_workout_split: 'Push/Pull/Legs',
};

// utilities

function pct(sorted, p) {
    return sorted[Math.max(0, Math.ceil((p / 100) * sorted.length) - 1)];
}

async function timedRequest(reqFn) {
    const t0 = Date.now();
    try {
        const res = await Promise.race([
            reqFn(),
            new Promise((_, rej) =>
                setTimeout(() => rej(new Error('TIMEOUT')), REQUEST_TIMEOUT)),
        ]);
        return { ok: res.status < 500, status: res.status, ms: Date.now() - t0, err: res.status >= 500 ? `HTTP ${res.status}` : null };
    } catch (e) {
        return { ok: false, status: 0, ms: Date.now() - t0, err: e.message };
    }
}

async function runConcurrent(reqFn, n) {
    const raw = await Promise.all(Array.from({ length: n }, () => timedRequest(reqFn)));
    const times = raw.map(r => r.ms).sort((a, b) => a - b);
    const failed = raw.filter(r => !r.ok);
    const errPct = parseFloat(((failed.length / n) * 100).toFixed(2));
    const latency = { min: times[0], median: pct(times, 50), p95: pct(times, 95), p99: pct(times, 99), max: times[times.length - 1] };

    const reasons = [];
    if (errPct > THRESHOLDS.maxErrorPct) reasons.push(`error rate ${errPct}% (${[...new Set(failed.map(e => e.err))].join(', ')})`);
    if (latency.p95 > THRESHOLDS.maxP95) reasons.push(`p95 ${latency.p95}ms > ${THRESHOLDS.maxP95}ms`);
    if (latency.p99 > THRESHOLDS.maxP99) reasons.push(`p99 ${latency.p99}ms > ${THRESHOLDS.maxP99}ms`);

    return {
        concurrency: n,
        success: n - failed.length,
        errors: failed.length,
        errorPct: errPct,
        latency,
        broke: reasons.length > 0,
        reasons,
    };
}

async function escalate(label, reqFn) {
    const levels = [];
    let breakAt = null, breakReasons = [];

    for (const n of LOAD_LEVELS) {
        const r = await runConcurrent(reqFn, n);
        levels.push(r);

        if (r.broke) {
            breakAt = n;
            breakReasons = r.reasons;
            break;
        }
    }


    const prevIdx = breakAt ? LOAD_LEVELS.indexOf(breakAt) - 1 : LOAD_LEVELS.length - 1;
    const maxPassedLevel = prevIdx >= 0 ? LOAD_LEVELS[prevIdx] : null;

    return { label, breakAt, breakReasons, maxPassedLevel, levels };
}

// report writer

function writeReport(results) {
    const ts = new Date().toISOString();
    const reportPath = path.join(__dirname, '..', 'stress_report.md');
    const logPath = path.join(__dirname, '..', 'stress_log.json');

    fs.writeFileSync(logPath, JSON.stringify({ ts, thresholds: THRESHOLDS, results }, null, 2));

    const md = [];
    md.push('sqa stress test report  RAG Fitness Backend');
    md.push('');
    md.push(`date: ${ts}`);
    md.push(`engine: Node.js / Express`);
    md.push(`tool: Jest + Supertest (in-process load)`);
    md.push('');

    md.push('configuration');
    md.push('| Setting | Value |');
    md.push('|---|---|');
    md.push(`| Load levels | \`${LOAD_LEVELS.join('  ')}\` |`);
    md.push(`| Request timeout | ${REQUEST_TIMEOUT} ms |`);
    md.push(`| Max allowed error rate | ${THRESHOLDS.maxErrorPct}% |`);
    md.push(`| Max p95 latency | ${THRESHOLDS.maxP95} ms |`);
    md.push(`| Max p99 latency | ${THRESHOLDS.maxP99} ms |`);
    md.push('');

    md.push('executive summary');
    md.push('| Endpoint | Last Passing Level | Breaking Level | Root Cause |');
    md.push('|---|---|---|---|');
    for (const r of results) {
        const passed = r.maxPassedLevel ?? '';
        const broke = r.breakAt ?? ' None (survived all)';
        const cause = r.breakReasons.length ? r.breakReasons.join('; ') : '';
        md.push(`| \`${r.label}\` | **${passed}** | ${broke} | ${cause} |`);
    }
    md.push('');

    md.push('detailed results per endpoint');
    for (const r of results) {
        md.push(`### \`${r.label}\``);
        if (r.breakAt) {
            md.push(`>  **Breaks at ${r.breakAt} concurrent requests**`);
            md.push(`> Root cause: ${r.breakReasons.join(' | ')}`);
            md.push(`> Maximum safe concurrency: **${r.maxPassedLevel ?? 'N/A'}**`);
        } else {
            md.push(`>  Survived all ${LOAD_LEVELS[LOAD_LEVELS.length - 1]} concurrent requests.`);
        }
        md.push('');
        md.push('| Conc. | OK | Err | Err% | Min | Median | p95 | p99 | Max | Result |');
        md.push('|---|---|---|---|---|---|---|---|---|---|');
        for (const lvl of r.levels) {
            const p95f = lvl.latency.p95 > THRESHOLDS.maxP95 ? ' ' : '';
            const p99f = lvl.latency.p99 > THRESHOLDS.maxP99 ? ' ' : '';
            const icon = lvl.broke ? '' : '';
            md.push(
                `| ${lvl.concurrency} | ${lvl.success} | ${lvl.errors} | ${lvl.errorPct}% ` +
                `| ${lvl.latency.min} | ${lvl.latency.median} ` +
                `| ${lvl.latency.p95}${p95f} | ${lvl.latency.p99}${p99f} ` +
                `| ${lvl.latency.max} | ${icon} |`
            );
        }
        md.push('');
    }

    md.push('sqa recommendations');
    const broken = results.filter(r => r.breakAt);
    const survived = results.filter(r => !r.breakAt);

    if (survived.length) {
        md.push('endpoints that survived all load levels');
        survived.forEach(r => md.push(`- \`${r.label}\``));
        md.push('');
    }
    if (broken.length) {
        md.push('endpoints that need attention');
        for (const r of broken) {
            md.push(`- **\`${r.label}\`**  safe up to **${r.maxPassedLevel ?? 'N/A'}** concurrent requests`);
            md.push(`  - Failure mode: ${r.breakReasons.join('; ')}`);
        }
        md.push('');
        const cap = Math.min(...broken.map(r => r.maxPassedLevel ?? 0));
        md.push(`> **System ceiling (weakest link): ${cap} concurrent requests.**`);
        md.push(`> Apply rate-limiting of **${cap} req/endpoint** before production deployment.`);
    } else {
        md.push('>  All endpoints passed all load levels. System is robust under the tested conditions.');
    }

    md.push('');
    md.push('---');
    md.push('*Report generated by Antigravity SQA Stress Runner*');

    fs.writeFileSync(reportPath, md.join('\n'));
    return { reportPath, logPath };
}

// test suite

describe('SQA Escalating Stress  Breaking Point Discovery', () => {
    const allResults = [];
    let logSpy, errSpy;

    beforeAll(() => {
        // silence express app logs so escalation output stays readable
        logSpy = jest.spyOn(console, 'log').mockImplementation(() => { });
        errSpy = jest.spyOn(console, 'error').mockImplementation(() => { });
    });

    beforeEach(() => {
        chatAssistant.mockResolvedValue('ok');
        analyzeImage.mockResolvedValue('Extracted text');
        ragChain.invoke.mockResolvedValue(MOCK_DIET);
        ytSearch.mockResolvedValue({ videos: [{ videoId: 'sqa_vid' }] });
    });

    afterEach(() => jest.clearAllMocks());

    afterAll(() => {
        logSpy.mockRestore();
        errSpy.mockRestore();

        if (allResults.length === 0) return;

        const { reportPath, logPath } = writeReport(allResults);
    });

    // individual endpoint escalations

    test('GET /health', async () => {
        const r = await escalate('GET /health', () => request(app).get('/health'));
        allResults.push(r);
        expect(r.levels.length).toBeGreaterThan(0);
    });

    test('POST /ai/chat', async () => {
        const r = await escalate('POST /ai/chat',
            () => request(app).post('/ai/chat')
                .send({ messages: [{ role: 'user', content: 'Hi' }] }));
        allResults.push(r);
        expect(r.levels.length).toBeGreaterThan(0);
    });

    test('POST /ai/analyze-report', async () => {
        const r = await escalate('POST /ai/analyze-report',
            () => request(app).post('/ai/analyze-report')
                .send({ base64Image: 'aGVsbG8=', type: 'inbody' }));
        allResults.push(r);
        expect(r.levels.length).toBeGreaterThan(0);
    });

    test('POST /ai/generate-diet', async () => {
        const r = await escalate('POST /ai/generate-diet',
            () => request(app).post('/ai/generate-diet').send(BASE_PROFILE));
        allResults.push(r);
        expect(r.levels.length).toBeGreaterThan(0);
    });

    test('POST /ai/generate-workout', async () => {
        ragChain.invoke.mockResolvedValue(MOCK_WORKOUT);
        const r = await escalate('POST /ai/generate-workout',
            () => request(app).post('/ai/generate-workout').send(BASE_PROFILE));
        allResults.push(r);
        expect(r.levels.length).toBeGreaterThan(0);
    });

    test('POST /ai/search-video', async () => {
        const r = await escalate('POST /ai/search-video',
            () => request(app).post('/ai/search-video')
                .send({ query: 'bench press tutorial' }));
        allResults.push(r);
        expect(r.levels.length).toBeGreaterThan(0);
    });
});
