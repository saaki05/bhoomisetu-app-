const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const compression = require('compression');
const morgan = require('morgan');

const { loadEnv } = require('./config/env');
const logger = require('./config/logger');
const swaggerSpec = require('./config/swagger');
const swaggerUi = require('swagger-ui-express');
const routes = require('./routes');
const { globalLimiter } = require('./middleware/rateLimiter');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');

const env = loadEnv();

function createApp() {
  const app = express();

  app.disable('x-powered-by');
  app.set('trust proxy', 1);

  app.use(helmet());
  app.use(cors({
    // The `cors` package checks an array origin for exact string equality,
    // so a literal "*" entry never actually matches a real Origin header —
    // it has to be passed as boolean `true` (reflect any origin) instead.
    origin: env.NODE_ENV === 'production' && env.CLIENT_ORIGIN !== '*' ? env.CLIENT_ORIGIN.split(',') : true,
    credentials: true,
  }));
  app.use(compression());
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev', {
    stream: { write: (message) => logger.http(message.trim()) },
  }));

  app.use('/api/v1', globalLimiter, routes);
  app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

module.exports = createApp;
