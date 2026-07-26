const request = require('supertest');

jest.mock('../src/services/marketplace.service');

const marketplaceService = require('../src/services/marketplace.service');
const createApp = require('../src/app');
const { signAccessToken } = require('../src/utils/jwt');

describe('Marketplace routes', () => {
  const app = createApp();
  const farmerToken = signAccessToken({ sub: 'farmer-1', role: 'farmer', email: 'farmer@example.com' });
  const buyerToken = signAccessToken({ sub: 'buyer-1', role: 'buyer', email: 'buyer@example.com' });

  afterEach(() => jest.clearAllMocks());

  describe('GET /api/v1/marketplace/listings', () => {
    it('rejects an invalid query', async () => {
      const response = await request(app).get('/api/v1/marketplace/listings').query({ minPrice: 'not-a-number' });

      expect(response.status).toBe(400);
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });

    it('returns paginated results with defaults applied', async () => {
      marketplaceService.searchListings.mockResolvedValue({
        items: [{ id: 'listing-1', title: 'Wheat' }],
        page: 1,
        pageSize: 20,
        total: 1,
        totalPages: 1,
      });

      const response = await request(app).get('/api/v1/marketplace/listings');

      expect(response.status).toBe(200);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.meta).toMatchObject({ page: 1, pageSize: 20, total: 1 });
      expect(marketplaceService.searchListings).toHaveBeenCalledWith(
        expect.objectContaining({ page: 1, pageSize: 20, sortBy: 'newest' }),
      );
    });
  });

  describe('POST /api/v1/marketplace/listings', () => {
    const validPayload = {
      categoryId: '11111111-1111-1111-1111-111111111111',
      title: 'Fresh Wheat',
      pricePerUnit: 2200,
      quantityAvailable: 50,
    };

    it('rejects requests from an unauthenticated caller', async () => {
      const response = await request(app).post('/api/v1/marketplace/listings').send(validPayload);
      expect(response.status).toBe(401);
    });

    it('rejects requests from a buyer role', async () => {
      const response = await request(app)
        .post('/api/v1/marketplace/listings')
        .set('Authorization', `Bearer ${buyerToken}`)
        .send(validPayload);

      expect(response.status).toBe(403);
      expect(response.body.code).toBe('ROLE_NOT_ALLOWED');
      expect(marketplaceService.createListing).not.toHaveBeenCalled();
    });

    it('creates a listing for an authenticated farmer', async () => {
      marketplaceService.createListing.mockResolvedValue({ id: 'listing-1', ...validPayload });

      const response = await request(app)
        .post('/api/v1/marketplace/listings')
        .set('Authorization', `Bearer ${farmerToken}`)
        .send(validPayload);

      expect(response.status).toBe(201);
      expect(marketplaceService.createListing).toHaveBeenCalledWith(
        'farmer-1',
        expect.objectContaining({ title: 'Fresh Wheat' }),
      );
    });
  });

  describe('POST /api/v1/marketplace/listings/:id/report', () => {
    it('rejects a report with too short a reason', async () => {
      const response = await request(app)
        .post('/api/v1/marketplace/listings/listing-1/report')
        .set('Authorization', `Bearer ${buyerToken}`)
        .send({ reason: 'x' });

      expect(response.status).toBe(400);
      expect(marketplaceService.reportListing).not.toHaveBeenCalled();
    });

    it('submits a report for an authenticated user', async () => {
      marketplaceService.reportListing.mockResolvedValue();

      const response = await request(app)
        .post('/api/v1/marketplace/listings/listing-1/report')
        .set('Authorization', `Bearer ${buyerToken}`)
        .send({ reason: 'Misleading price' });

      expect(response.status).toBe(201);
      expect(marketplaceService.reportListing).toHaveBeenCalledWith(
        'buyer-1',
        'listing-1',
        expect.objectContaining({ reason: 'Misleading price' }),
      );
    });
  });

  describe('POST /api/v1/marketplace/listings/:id/bookmark', () => {
    it('toggles a bookmark for the authenticated user', async () => {
      marketplaceService.toggleBookmark.mockResolvedValue({ bookmarked: true });

      const response = await request(app)
        .post('/api/v1/marketplace/listings/listing-1/bookmark')
        .set('Authorization', `Bearer ${buyerToken}`);

      expect(response.status).toBe(200);
      expect(response.body.data.bookmarked).toBe(true);
      expect(marketplaceService.toggleBookmark).toHaveBeenCalledWith('buyer-1', 'listing-1');
    });
  });
});
