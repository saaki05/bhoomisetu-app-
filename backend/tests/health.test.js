const request = require('supertest');
const createApp = require('../src/app');

describe('GET /api/v1/health', () => {
  const app = createApp();

  it('returns API information at the service root', async () => {
    const response = await request(app).get('/');

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      success: true,
      message: 'BhoomiSetu API is online',
      data: { health: '/api/v1/health' },
    });
  });

  it('returns 200 with a healthy status payload', async () => {
    const response = await request(app).get('/api/v1/health');

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({ success: true, data: { status: 'ok' } });
  });

  it('returns a structured 404 for unknown routes', async () => {
    const response = await request(app).get('/api/v1/does-not-exist');

    expect(response.status).toBe(404);
    expect(response.body).toMatchObject({ success: false, code: 'ROUTE_NOT_FOUND' });
  });
});
