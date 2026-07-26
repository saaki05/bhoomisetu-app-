const { loadEnv } = require('../config/env');
const { getRedisClient } = require('../config/redis');

const env = loadEnv();

// Single-process fallback for when no Redis is configured (fine for a
// single instance). With REDIS_URL set, revocation is shared across every
// horizontally-scaled API instance instead of being process-local.
const memoryBlocklist = new Set();

async function revokeRefreshToken(jti, ttlSeconds) {
  if (env.REDIS_URL) {
    await getRedisClient().set(`revoked-jti:${jti}`, '1', 'EX', Math.max(ttlSeconds, 1));
    return;
  }
  memoryBlocklist.add(jti);
}

async function isRefreshTokenRevoked(jti) {
  if (env.REDIS_URL) {
    const value = await getRedisClient().get(`revoked-jti:${jti}`);
    return value !== null;
  }
  return memoryBlocklist.has(jti);
}

module.exports = { revokeRefreshToken, isRefreshTokenRevoked };
