const { Router } = require('express');
const controller = require('../controllers/auth.controller');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { authLimiter, otpLimiter } = require('../middleware/rateLimiter');
const {
  registerSchema,
  loginSchema,
  otpRequestSchema,
  otpVerifySchema,
  googleSignInSchema,
  refreshSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  selectRoleSchema,
} = require('../validators/auth.validator');

const router = Router();

/**
 * @openapi
 * /auth/register:
 *   post:
 *     summary: Create a new farmer/buyer/expert account
 *     tags: [Auth]
 *     security: []
 */
router.post('/register', authLimiter, validate({ body: registerSchema }), controller.register);

/**
 * @openapi
 * /auth/login:
 *   post:
 *     summary: Log in with email and password
 *     tags: [Auth]
 *     security: []
 */
router.post('/login', authLimiter, validate({ body: loginSchema }), controller.login);

/**
 * @openapi
 * /auth/otp/request:
 *   post:
 *     summary: Send a one-time password to a phone number
 *     tags: [Auth]
 *     security: []
 */
router.post('/otp/request', otpLimiter, validate({ body: otpRequestSchema }), controller.requestOtp);

/**
 * @openapi
 * /auth/otp/verify:
 *   post:
 *     summary: Verify an OTP and log in (or complete registration on first verification)
 *     tags: [Auth]
 *     security: []
 */
router.post('/otp/verify', authLimiter, validate({ body: otpVerifySchema }), controller.verifyOtp);

/**
 * @openapi
 * /auth/google:
 *   post:
 *     summary: Sign in with a Google ID token
 *     tags: [Auth]
 *     security: []
 */
router.post('/google', authLimiter, validate({ body: googleSignInSchema }), controller.googleSignIn);

/**
 * @openapi
 * /auth/refresh:
 *   post:
 *     summary: Exchange a refresh token for a new access/refresh token pair
 *     tags: [Auth]
 *     security: []
 */
router.post('/refresh', validate({ body: refreshSchema }), controller.refresh);

/**
 * @openapi
 * /auth/logout:
 *   post:
 *     summary: Revoke a refresh token
 *     tags: [Auth]
 *     security: []
 */
router.post('/logout', validate({ body: refreshSchema }), controller.logout);

/**
 * @openapi
 * /auth/forgot-password:
 *   post:
 *     summary: Request a password reset email
 *     tags: [Auth]
 *     security: []
 */
router.post('/forgot-password', authLimiter, validate({ body: forgotPasswordSchema }), controller.forgotPassword);

/**
 * @openapi
 * /auth/reset-password:
 *   post:
 *     summary: Set a new password using a recovery access token
 *     tags: [Auth]
 *     security: []
 */
router.post('/reset-password', authLimiter, validate({ body: resetPasswordSchema }), controller.resetPassword);

/**
 * @openapi
 * /auth/me:
 *   get:
 *     summary: Get the authenticated user's profile
 *     tags: [Auth]
 */
router.get('/me', authenticate, controller.me);

/**
 * @openapi
 * /auth/role:
 *   patch:
 *     summary: Set the account type for a user who signed up without one (Google/OTP)
 *     tags: [Auth]
 */
router.patch('/role', authenticate, validate({ body: selectRoleSchema }), controller.selectRole);

module.exports = router;
