class AppError extends Error {
  constructor(message, statusCode, code, details) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.code = code || 'INTERNAL_ERROR';
    this.details = details;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }

  static badRequest(message, code = 'BAD_REQUEST', details) {
    return new AppError(message, 400, code, details);
  }

  static unauthorized(message = 'Unauthorized', code = 'UNAUTHORIZED', details) {
    return new AppError(message, 401, code, details);
  }

  static forbidden(message = 'Forbidden', code = 'FORBIDDEN', details) {
    return new AppError(message, 403, code, details);
  }

  static notFound(message = 'Resource not found', code = 'NOT_FOUND', details) {
    return new AppError(message, 404, code, details);
  }

  static conflict(message, code = 'CONFLICT', details) {
    return new AppError(message, 409, code, details);
  }

  static tooManyRequests(message = 'Too many requests', code = 'RATE_LIMITED', details) {
    return new AppError(message, 429, code, details);
  }

  static internal(message = 'Internal server error', code = 'INTERNAL_ERROR', details) {
    return new AppError(message, 500, code, details);
  }
}

module.exports = AppError;
