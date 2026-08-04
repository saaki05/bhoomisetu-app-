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

function buildCorsOriginPolicy() {
  if (env.NODE_ENV !== 'production' || env.CLIENT_ORIGIN === '*') return true;

  const allowedOrigins = env.CLIENT_ORIGIN.split(',').map((origin) => origin.trim());
  const netlifyPreviewSuffixes = allowedOrigins.flatMap((origin) => {
    try {
      const hostname = new URL(origin).hostname;
      return hostname.endsWith('.netlify.app') ? [`--${hostname}`] : [];
    } catch (_) {
      return [];
    }
  });

  return (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) return callback(null, true);
    try {
      const url = new URL(origin);
      const isOwnNetlifyPreview =
        url.protocol === 'https:' && netlifyPreviewSuffixes.some((suffix) => url.hostname.endsWith(suffix));
      return callback(null, isOwnNetlifyPreview);
    } catch (_) {
      return callback(null, false);
    }
  };
}

function createApp() {
  const app = express();

  app.disable('x-powered-by');
  app.set('trust proxy', 1);

  app.use(helmet());
  app.use(cors({
    // The `cors` package checks an array origin for exact string equality,
    // so a literal "*" entry never actually matches a real Origin header —
    // it has to be passed as boolean `true` (reflect any origin) instead.
    origin: buildCorsOriginPolicy(),
    credentials: true,
  }));
  app.use(compression());
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev', {
    stream: { write: (message) => logger.http(message.trim()) },
  }));

  app.get('/', (req, res) => {
    res.status(200).json({
      success: true,
      message: 'BhoomiSetu API is online',
      data: {
        health: '/api/v1/health',
        readiness: '/api/v1/health/readiness',
        documentation: '/api/docs',
      },
    });
  });

  app.use('/api/v1', globalLimiter, routes);
  app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

module.exports = createApp;
