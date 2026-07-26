const AppError = require('../utils/AppError');

/**
 * Restricts a route to the given roles. Must run after `authenticate`.
 * Usage: router.get('/admin/stats', authenticate, authorize('admin'), handler)
 */
function authorize(...allowedRoles) {
  return function authorizeMiddleware(req, res, next) {
    if (!req.user) {
      return next(AppError.unauthorized('Authentication required', 'UNAUTHENTICATED'));
    }
    if (!allowedRoles.includes(req.user.role)) {
      return next(AppError.forbidden(
        `Role '${req.user.role}' is not permitted to access this resource`,
        'ROLE_NOT_ALLOWED',
      ));
    }
    return next();
  };
}

module.exports = authorize;
