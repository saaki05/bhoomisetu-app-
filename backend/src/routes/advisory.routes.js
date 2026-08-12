const { Router } = require('express');
const controller = require('../controllers/advisory.controller');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { advisoryLimiter } = require('../middleware/rateLimiter');
const { chatMessageSchema } = require('../validators/advisory.validator');

const router = Router();

/**
 * @openapi
 * /advisory/chat:
 *   post:
 *     summary: Ask the AI farming advisor a question
 *     tags: [Advisory]
 */
router.post(
  '/chat',
  authenticate,
  advisoryLimiter,
  validate({ body: chatMessageSchema }),
  controller.chat,
);

module.exports = router;
