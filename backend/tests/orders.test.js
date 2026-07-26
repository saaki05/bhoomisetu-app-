const request = require('supertest');

jest.mock('../src/services/orders.service');

const ordersService = require('../src/services/orders.service');
const createApp = require('../src/app');
const { signAccessToken } = require('../src/utils/jwt');

describe('Orders routes', () => {
  const app = createApp();
  const buyerToken = signAccessToken({ sub: 'buyer-1', role: 'buyer', email: 'buyer@example.com' });
  const farmerToken = signAccessToken({ sub: 'farmer-1', role: 'farmer', email: 'farmer@example.com' });

  afterEach(() => jest.clearAllMocks());

  describe('POST /api/v1/orders', () => {
    const validPayload = {
      listingId: '11111111-1111-1111-1111-111111111111',
      quantity: 5,
      deliveryAddress: '123 Farm Road',
      contactPhone: '9876543210',
    };

    it('rejects requests from a farmer role', async () => {
      const response = await request(app)
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${farmerToken}`)
        .send(validPayload);

      expect(response.status).toBe(403);
      expect(response.body.code).toBe('ROLE_NOT_ALLOWED');
      expect(ordersService.createOrder).not.toHaveBeenCalled();
    });

    it('creates an order for an authenticated buyer', async () => {
      ordersService.createOrder.mockResolvedValue({ id: 'order-1', status: 'pending' });

      const response = await request(app)
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${buyerToken}`)
        .send(validPayload);

      expect(response.status).toBe(201);
      expect(ordersService.createOrder).toHaveBeenCalledWith(
        'buyer-1',
        expect.objectContaining({ quantity: 5 }),
      );
    });
  });

  describe('PATCH /api/v1/orders/:id/status', () => {
    it('rejects an invalid status value', async () => {
      const response = await request(app)
        .patch('/api/v1/orders/order-1/status')
        .set('Authorization', `Bearer ${farmerToken}`)
        .send({ status: 'not-a-real-status' });

      expect(response.status).toBe(400);
      expect(ordersService.updateOrderStatus).not.toHaveBeenCalled();
    });

    it('surfaces a forbidden error when the service rejects the transition', async () => {
      const AppError = require('../src/utils/AppError');
      ordersService.updateOrderStatus.mockRejectedValue(
        AppError.forbidden('Only the farmer can do that', 'ROLE_NOT_ALLOWED'),
      );

      const response = await request(app)
        .patch('/api/v1/orders/order-1/status')
        .set('Authorization', `Bearer ${buyerToken}`)
        .send({ status: 'accepted' });

      expect(response.status).toBe(403);
      expect(response.body.code).toBe('ROLE_NOT_ALLOWED');
    });

    it('updates the status for a valid request', async () => {
      ordersService.updateOrderStatus.mockResolvedValue({ id: 'order-1', status: 'accepted' });

      const response = await request(app)
        .patch('/api/v1/orders/order-1/status')
        .set('Authorization', `Bearer ${farmerToken}`)
        .send({ status: 'accepted' });

      expect(response.status).toBe(200);
      expect(response.body.data.status).toBe('accepted');
    });
  });

  describe('GET /api/v1/orders', () => {
    it('rejects unauthenticated requests', async () => {
      const response = await request(app).get('/api/v1/orders');
      expect(response.status).toBe(401);
    });

    it('returns paginated orders for the authenticated user', async () => {
      ordersService.listOrders.mockResolvedValue({ items: [], page: 1, pageSize: 20, total: 0, totalPages: 0 });

      const response = await request(app).get('/api/v1/orders').set('Authorization', `Bearer ${buyerToken}`);

      expect(response.status).toBe(200);
      expect(ordersService.listOrders).toHaveBeenCalledWith('buyer-1', expect.objectContaining({ page: 1 }));
    });
  });
});
