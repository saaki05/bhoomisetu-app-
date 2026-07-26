function sendSuccess(res, { statusCode = 200, message = 'Success', data = null, meta = null } = {}) {
  const body = { success: true, message, data };
  if (meta) body.meta = meta;
  return res.status(statusCode).json(body);
}

function sendError(res, { statusCode = 500, message = 'Something went wrong', code = 'INTERNAL_ERROR', details = null } = {}) {
  const body = { success: false, message, code };
  if (details) body.details = details;
  return res.status(statusCode).json(body);
}

module.exports = { sendSuccess, sendError };
