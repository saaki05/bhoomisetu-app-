const { Router } = require('express');
const { sendSuccess } = require('../utils/apiResponse');
const { supabaseAdmin } = require('../config/supabase');

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

router.get('/readiness', async (req, res) => {
  const [databaseResult, authResult] = await Promise.all([
    supabaseAdmin.from('profiles').select('id', { head: true, count: 'exact' }),
    supabaseAdmin.auth.admin.listUsers({ page: 1, perPage: 1 }),
  ]);

  const databaseReady = !databaseResult.error;
  const authAdminReady = !authResult.error;
  const ready = databaseReady && authAdminReady;

  return res.status(ready ? 200 : 503).json({
    success: ready,
    message: ready ? 'BhoomiSetu dependencies are ready' : 'BhoomiSetu dependencies need configuration',
    data: {
      status: ready ? 'ready' : 'not_ready',
      database: databaseReady ? 'ok' : 'unavailable',
      authAdmin: authAdminReady ? 'ok' : 'unavailable',
      timestamp: new Date().toISOString(),
    },
  });
});

module.exports = router;
