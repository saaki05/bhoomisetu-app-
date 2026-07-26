const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { loadEnv } = require('../config/env');

const env = loadEnv();

function signAccessToken(payload) {
  return jwt.sign(payload, env.JWT_ACCESS_SECRET, { expiresIn: env.JWT_ACCESS_EXPIRES_IN });
}

/**
 * Refresh tokens carry a `jti` so a specific token (not just a secret) can
 * be revoked on logout via the Redis denylist in `tokenBlocklist.js`,
 * without needing to invalidate every other session for that user.
 */
function signRefreshToken(payload) {
  const jti = crypto.randomUUID();
  const token = jwt.sign({ ...payload, jti }, env.JWT_REFRESH_SECRET, {
    expiresIn: env.JWT_REFRESH_EXPIRES_IN,
  });
  return { token, jti };
}

function verifyAccessToken(token) {
  return jwt.verify(token, env.JWT_ACCESS_SECRET);
}

function verifyRefreshToken(token) {
  return jwt.verify(token, env.JWT_REFRESH_SECRET);
}

module.exports = { signAccessToken, signRefreshToken, verifyAccessToken, verifyRefreshToken };
