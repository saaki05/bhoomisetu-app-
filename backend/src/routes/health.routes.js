const { Router } = require('express');
const { sendSuccess } = require('../utils/apiResponse');

const router = Router();

/**
 * @openapi
 * /health:
 *   get:
 *     summary: Liveness/readiness probe
 *     tags: [System]
 *     security: []
 *     responses:
 *       200:
 *         description: Service is healthy
 */
router.get('/', (req, res) => {
  sendSuccess(res, {
    message: 'BhoomiSetu API is healthy',
    data: {
      status: 'ok',
      uptimeSeconds: process.uptime(),
      timestamp: new Date().toISOString(),
    },
  });
});

module.exports = router;
