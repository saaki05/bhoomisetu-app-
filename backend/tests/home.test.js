const request = require('supertest');

jest.mock('../src/services/home.service');

const homeService = require('../src/services/home.service');
const createApp = require('../src/app');
const { signAccessToken } = require('../src/utils/jwt');

describe('GET /api/v1/home/summary', () => {
  const app = createApp();

  afterEach(() => jest.clearAllMocks());

  it('rejects unauthenticated requests', async () => {
    const response = await request(app).get('/api/v1/home/summary');

    expect(response.status).toBe(401);
    expect(homeService.getHomeSummary).not.toHaveBeenCalled();
  });

  it('returns the aggregated summary for an authenticated user', async () => {
    const token = signAccessToken({ sub: 'user-1', role: 'farmer', email: 'farmer@example.com' });
    homeService.getHomeSummary.mockResolvedValue({
      greeting: { fullName: 'Test Farmer', role: 'farmer', avatarUrl: null },
      weather: null,
      marketPrices: [],
      governmentSchemes: [],
      nearbyBuyers: [],
      recommendedCrops: [],
    });

    const response = await request(app).get('/api/v1/home/summary').set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(response.body.data.greeting.fullName).toBe('Test Farmer');
    expect(homeService.getHomeSummary).toHaveBeenCalledWith('user-1');
  });
});
