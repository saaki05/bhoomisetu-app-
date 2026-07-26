const Redis = require('ioredis');
const { loadEnv } = require('./env');
const logger = require('./logger');

const env = loadEnv();

let client;

/**
 * Lazily creates a shared ioredis client used for rate-limit storage and
 * feature-level response caching (market prices, weather). Lazy so that
 * simply requiring this module never opens a socket before it's needed,
 * and connection errors are logged instead of crashing the process.
 */
function getRedisClient() {
  if (!client) {
    client = new Redis(env.REDIS_URL, {
      maxRetriesPerRequest: 3,
      lazyConnect: false,
    });
    client.on('error', (err) => logger.error('Redis connection error', { error: err.message }));
    client.on('connect', () => logger.info('Connected to Redis'));
  }
  return client;
}

module.exports = { getRedisClient };
