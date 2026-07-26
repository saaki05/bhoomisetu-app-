const request = require('supertest');

jest.mock('../src/services/auth.service');

const authService = require('../src/services/auth.service');
const createApp = require('../src/app');

describe('Auth routes', () => {
  const app = createApp();

  afterEach(() => jest.clearAllMocks());

  describe('POST /api/v1/auth/register', () => {
    it('rejects an invalid payload with structured field errors', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({ email: 'not-an-email' });

      expect(response.status).toBe(400);
      expect(response.body.code).toBe('VALIDATION_ERROR');
      expect(response.body.details.fieldErrors).toHaveProperty('fullName');
      expect(response.body.details.fieldErrors).toHaveProperty('password');
      expect(authService.register).not.toHaveBeenCalled();
    });

    it('creates an account and returns tokens for a valid payload', async () => {
      authService.register.mockResolvedValue({
        user: { id: 'user-1', role: 'farmer', fullName: 'Test Farmer', email: 'farmer@example.com' },
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      });

      const response = await request(app).post('/api/v1/auth/register').send({
        fullName: 'Test Farmer',
        email: 'farmer@example.com',
        password: 'Passw0rd1',
        role: 'farmer',
      });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.accessToken).toBe('access-token');
      expect(authService.register).toHaveBeenCalledWith(
        expect.objectContaining({ email: 'farmer@example.com', role: 'farmer' }),
      );
    });
  });

  describe('POST /api/v1/auth/login', () => {
    it('returns 401 when the service rejects the credentials', async () => {
      const AppError = require('../src/utils/AppError');
      authService.login.mockRejectedValue(AppError.unauthorized('Invalid email or password', 'INVALID_CREDENTIALS'));

      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({ email: 'farmer@example.com', password: 'wrong-password' });

      expect(response.status).toBe(401);
      expect(response.body.code).toBe('INVALID_CREDENTIALS');
    });
  });

  describe('GET /api/v1/auth/me', () => {
    it('rejects requests without a bearer token', async () => {
      const response = await request(app).get('/api/v1/auth/me');

      expect(response.status).toBe(401);
      expect(response.body.code).toBe('MISSING_TOKEN');
    });

    it('returns the current user for a valid access token', async () => {
      const { signAccessToken } = require('../src/utils/jwt');
      const token = signAccessToken({ sub: 'user-1', role: 'farmer', email: 'farmer@example.com' });

      authService.getCurrentUser.mockResolvedValue({ id: 'user-1', role: 'farmer', fullName: 'Test Farmer' });

      const response = await request(app).get('/api/v1/auth/me').set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);
      expect(response.body.data).toMatchObject({ id: 'user-1', role: 'farmer' });
      expect(authService.getCurrentUser).toHaveBeenCalledWith('user-1');
    });
  });
});
