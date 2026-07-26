const rateLimit = require('express-rate-limit');
const { RedisStore } = require('rate-limit-redis');
const { loadEnv } = require('../config/env');
const { getRedisClient } = require('../config/redis');
const { sendError } = require('../utils/apiResponse');

const env = loadEnv();

/**
 * When REDIS_URL is configured, rate-limit counters live in Redis so the
 * limit is shared across every horizontally-scaled API instance instead of
 * resetting per process. Without it, counters are kept in memory — fine for
 * a single instance, which is what "no Redis configured" implies anyway.
 */
function buildLimiter({ windowMs, max, message, prefix }) {
  return rateLimit({
    windowMs,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    store: env.REDIS_URL
      ? new RedisStore({
        sendCommand: (...args) => getRedisClient().call(...args),
        prefix: `rl:${prefix}:`,
      })
      : undefined,
    handler: (req, res) => sendError(res, {
      statusCode: 429,
      message: message || 'Too many requests, please try again later',
      code: 'RATE_LIMITED',
    }),
  });
}

const globalLimiter = buildLimiter({
  windowMs: env.RATE_LIMIT_WINDOW_MS,
  max: env.RATE_LIMIT_MAX,
  prefix: 'global',
});

const authLimiter = buildLimiter({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: 'Too many authentication attempts, please try again in a few minutes',
  prefix: 'auth',
});

const otpLimiter = buildLimiter({
  windowMs: 5 * 60 * 1000,
  max: 5,
  message: 'Too many OTP requests, please wait before requesting another code',
  prefix: 'otp',
});

module.exports = { globalLimiter, authLimiter, otpLimiter };
