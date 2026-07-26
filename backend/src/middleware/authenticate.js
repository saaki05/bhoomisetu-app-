const AppError = require('../utils/AppError');
const asyncHandler = require('../utils/asyncHandler');
const { verifyAccessToken } = require('../utils/jwt');

/**
 * Verifies the bearer access token and attaches { id, role, email } to req.user.
 * Also keeps the raw token on req.accessToken so downstream code can build a
 * request-scoped Supabase client that respects Row Level Security.
 */
const authenticate = asyncHandler(async (req, res, next) => {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    throw AppError.unauthorized('Missing or malformed Authorization header', 'MISSING_TOKEN');
  }

  const payload = verifyAccessToken(token);

  req.user = { id: payload.sub, role: payload.role, email: payload.email };
  req.accessToken = token;
  next();
});

module.exports = authenticate;
