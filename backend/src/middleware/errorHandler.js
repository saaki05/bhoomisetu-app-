const AppError = require('../utils/AppError');
const { sendError } = require('../utils/apiResponse');
const logger = require('../config/logger');
const { loadEnv } = require('../config/env');

const env = loadEnv();

function notFoundHandler(req, res, next) {
  next(AppError.notFound(`Route ${req.method} ${req.originalUrl} not found`, 'ROUTE_NOT_FOUND'));
}

// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  let error = err;

  if (!(error instanceof AppError)) {
    if (error.name === 'ZodError') {
      error = AppError.badRequest('Validation failed', 'VALIDATION_ERROR', error.flatten());
    } else if (error.name === 'JsonWebTokenError') {
      error = AppError.unauthorized('Invalid authentication token', 'INVALID_TOKEN');
    } else if (error.name === 'TokenExpiredError') {
      error = AppError.unauthorized('Authentication token expired', 'TOKEN_EXPIRED');
    } else {
      error = AppError.internal(
        env.NODE_ENV === 'production' ? 'Something went wrong' : error.message,
      );
    }
  }

  if (!error.isOperational || error.statusCode >= 500) {
    logger.error(err.message, { stack: err.stack, path: req.originalUrl, method: req.method });
  } else {
    logger.warn(error.message, { code: error.code, path: req.originalUrl, method: req.method });
  }

  return sendError(res, {
    statusCode: error.statusCode || 500,
    message: error.message,
    code: error.code,
    details: env.NODE_ENV === 'production' ? undefined : error.details,
  });
}

module.exports = { notFoundHandler, errorHandler };
