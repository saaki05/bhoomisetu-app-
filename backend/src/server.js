require('dotenv').config();

const http = require('http');
const createApp = require('./app');
const { loadEnv } = require('./config/env');
const logger = require('./config/logger');
const initSocketServer = require('./sockets');
const { ensureReferenceData } = require('./services/referenceData.service');

const env = loadEnv();
const app = createApp();
const httpServer = http.createServer(app);

const io = initSocketServer(httpServer);
app.set('io', io);

async function startServer() {
  await ensureReferenceData({ includeDemoCatalog: env.BOOTSTRAP_DEMO_CATALOG });
  logger.info('Reference data and showcase catalog are ready');

  httpServer.listen(env.PORT, () => {
    logger.info(`BhoomiSetu API listening on port ${env.PORT} [${env.NODE_ENV}]`);
    logger.info(`Swagger docs available at ${env.API_BASE_URL}/api/docs`);
  });
}

startServer().catch((error) => {
  logger.error('BhoomiSetu API failed to start', { error: error.message });
  process.exit(1);
});

function shutdown(signal) {
  logger.info(`${signal} received, shutting down gracefully...`);
  httpServer.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10000).unref();
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled promise rejection', { reason });
});
