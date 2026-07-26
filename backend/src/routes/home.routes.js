const { Router } = require('express');
const controller = require('../controllers/home.controller');
const authenticate = require('../middleware/authenticate');

const router = Router();

/**
 * @openapi
 * /home/summary:
 *   get:
 *     summary: Aggregated data for the Home screen (weather, market prices, schemes, nearby buyers)
 *     tags: [Home]
 */
router.get('/summary', authenticate, controller.summary);

module.exports = router;
