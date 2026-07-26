const { Router } = require('express');
const controller = require('../controllers/orders.controller');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const {
  createOrderSchema,
  updateOrderStatusSchema,
  listOrdersQuerySchema,
  createReviewSchema,
} = require('../validators/orders.validator');

const router = Router();

router.use(authenticate);

/**
 * @openapi
 * /orders:
 *   get:
 *     summary: List the current user's orders (as buyer and/or farmer)
 *     tags: [Orders]
 *   post:
 *     summary: Place an order against a crop listing (buyers only)
 *     tags: [Orders]
 */
router.get('/', validate({ query: listOrdersQuerySchema }), controller.listOrders);
router.post('/', validate({ body: createOrderSchema }), controller.createOrder);

/**
 * @openapi
 * /orders/{id}:
 *   get:
 *     summary: Get a single order with its status history
 *     tags: [Orders]
 */
router.get('/:id', controller.getOrder);

/**
 * @openapi
 * /orders/{id}/status:
 *   patch:
 *     summary: Transition an order's status (accept/reject/prepare/deliver/cancel)
 *     tags: [Orders]
 */
router.patch('/:id/status', validate({ body: updateOrderStatusSchema }), controller.updateOrderStatus);

/**
 * @openapi
 * /orders/{id}/review:
 *   post:
 *     summary: Review the farmer after an order has been delivered (buyer only)
 *     tags: [Orders]
 */
router.post('/:id/review', validate({ body: createReviewSchema }), controller.createReview);

module.exports = router;
