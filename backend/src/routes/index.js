const { Router } = require('express');
const healthRoutes = require('./health.routes');
const authRoutes = require('./auth.routes');
const homeRoutes = require('./home.routes');
const marketplaceRoutes = require('./marketplace.routes');
const ordersRoutes = require('./orders.routes');
const chatRoutes = require('./chat.routes');
const profileRoutes = require('./profile.routes');
const advisoryRoutes = require('./advisory.routes');

const router = Router();

router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/home', homeRoutes);
router.use('/marketplace', marketplaceRoutes);
router.use('/orders', ordersRoutes);
router.use('/chat', chatRoutes);
router.use('/profile', profileRoutes);
router.use('/advisory', advisoryRoutes);

module.exports = router;
