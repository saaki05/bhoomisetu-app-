const { Router } = require('express');
const authenticate = require('../middleware/authenticate');
const validate = require('../middleware/validate');
const upload = require('../middleware/upload');
const controller = require('../controllers/profile.controller');
const { updateProfileSchema } = require('../validators/profile.validator');

const router = Router();
router.use(authenticate);
router.get('/', controller.getProfile);
router.patch('/', validate({ body: updateProfileSchema }), controller.updateProfile);
router.post('/avatar', upload.images.single('image'), controller.uploadAvatar);

module.exports = router;
