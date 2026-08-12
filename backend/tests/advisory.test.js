const request = require('supertest');

jest.mock('../src/services/advisory.service');

const advisoryService = require('../src/services/advisory.service');
const createApp = require('../src/app');
const { signAccessToken } = require('../src/utils/jwt');

describe('POST /api/v1/advisory/chat', () => {
  const app = createApp();
  const token = signAccessToken({ sub: 'user-1', role: 'farmer', email: 'farmer@example.com' });

  afterEach(() => jest.clearAllMocks());

  it('rejects unauthenticated requests', async () => {
    const response = await request(app).post('/api/v1/advisory/chat').send({ message: 'What crop suits sandy soil?' });
    expect(response.status).toBe(401);
    expect(advisoryService.sendChatMessage).not.toHaveBeenCalled();
  });

  it('rejects an empty message', async () => {
    const response = await request(app)
      .post('/api/v1/advisory/chat')
      .set('Authorization', `Bearer ${token}`)
      .send({ message: '' });

    expect(response.status).toBe(400);
    expect(advisoryService.sendChatMessage).not.toHaveBeenCalled();
  });

  it('returns the advisor reply for a valid question', async () => {
    advisoryService.sendChatMessage.mockResolvedValue({ reply: 'Try millet in sandy soil.', model: 'llama-3.3-70b-versatile' });

    const response = await request(app)
      .post('/api/v1/advisory/chat')
      .set('Authorization', `Bearer ${token}`)
      .send({ message: 'What crop suits sandy soil?' });

    expect(response.status).toBe(200);
    expect(response.body.data.reply).toBe('Try millet in sandy soil.');
    expect(advisoryService.sendChatMessage).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'What crop suits sandy soil?', history: [] }),
    );
  });

  it('surfaces a 503-style internal error when the advisor is not configured', async () => {
    const AppError = require('../src/utils/AppError');
    advisoryService.sendChatMessage.mockRejectedValue(
      AppError.internal('The AI advisor is not configured yet.', 'ADVISORY_NOT_CONFIGURED'),
    );

    const response = await request(app)
      .post('/api/v1/advisory/chat')
      .set('Authorization', `Bearer ${token}`)
      .send({ message: 'What crop suits sandy soil?' });

    expect(response.status).toBe(500);
    expect(response.body.code).toBe('ADVISORY_NOT_CONFIGURED');
  });
});
