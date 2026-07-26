/**
 * Validates req.body / req.query / req.params against Zod schemas and
 * replaces them with the parsed (and type-coerced) values on success.
 * Usage: router.post('/x', validate({ body: createXSchema }), handler)
 */
function validate(schemas) {
  return function validateMiddleware(req, res, next) {
    try {
      if (schemas.body) req.body = schemas.body.parse(req.body);
      if (schemas.query) req.query = schemas.query.parse(req.query);
      if (schemas.params) req.params = schemas.params.parse(req.params);
      next();
    } catch (err) {
      next(err);
    }
  };
}

module.exports = validate;
