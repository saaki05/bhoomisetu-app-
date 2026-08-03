const request = require('supertest');

jest.mock('../src/services/profile.service');
jest.mock('../src/services/storage.service');

const profileService = require('../src/services/profile.service');
const createApp = require('../src/app');
const { signAccessToken } = require('../src/utils/jwt');

describe('Profile routes', () => {
  const app = createApp();
  const token = signAccessToken({ sub: 'user-1', role: 'farmer', email: 'farmer@example.com' });

  afterEach(() => jest.clearAllMocks());

  it('rejects an unauthenticated profile request', async () => {
    const response = await request(app).get('/api/v1/profile');
    expect(response.status).toBe(401);
  });

  it('returns the authenticated profile', async () => {
    profileService.getProfile.mockResolvedValue({ id: 'user-1', fullName: 'Asha Farmer' });
    const response = await request(app).get('/api/v1/profile').set('Authorization', `Bearer ${token}`);
    expect(response.status).toBe(200);
    expect(response.body.data.fullName).toBe('Asha Farmer');
    expect(profileService.getProfile).toHaveBeenCalledWith('user-1');
  });

  it('validates that latitude and longitude are supplied together', async () => {
    const response = await request(app)
      .patch('/api/v1/profile')
      .set('Authorization', `Bearer ${token}`)
      .send({ fullName: 'Asha Farmer', latitude: 12.9 });
    expect(response.status).toBe(400);
    expect(profileService.updateProfile).not.toHaveBeenCalled();
  });

  it('updates contact and location fields', async () => {
    profileService.updateProfile.mockResolvedValue({ id: 'user-1', fullName: 'Asha Farmer', district: 'Chennai' });
    const response = await request(app)
      .patch('/api/v1/profile')
      .set('Authorization', `Bearer ${token}`)
      .send({ fullName: 'Asha Farmer', district: 'Chennai', latitude: 13.0827, longitude: 80.2707 });
    expect(response.status).toBe(200);
    expect(response.body.data.district).toBe('Chennai');
  });
});
