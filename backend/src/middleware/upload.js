const multer = require('multer');
const AppError = require('../utils/AppError');

const ALLOWED_MIME_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp']);

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 8 * 1024 * 1024, files: 6 },
  fileFilter: (req, file, cb) => {
    if (!ALLOWED_MIME_TYPES.has(file.mimetype)) {
      cb(AppError.badRequest('Only JPEG, PNG, or WebP images are allowed', 'INVALID_IMAGE_TYPE'));
      return;
    }
    cb(null, true);
  },
});

module.exports = upload;
