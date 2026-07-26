const authService = require('../services/auth.service');
const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');

const register = asyncHandler(async (req, res) => {
  const result = await authService.register(req.body);
  sendSuccess(res, { statusCode: 201, message: 'Account created successfully', data: result });
});

const login = asyncHandler(async (req, res) => {
  const result = await authService.login(req.body);
  sendSuccess(res, { message: 'Logged in successfully', data: result });
});

const requestOtp = asyncHandler(async (req, res) => {
  await authService.requestOtp(req.body);
  sendSuccess(res, { message: 'OTP sent successfully' });
});

const verifyOtp = asyncHandler(async (req, res) => {
  const result = await authService.verifyOtp(req.body);
  sendSuccess(res, { message: 'Phone number verified successfully', data: result });
});

const googleSignIn = asyncHandler(async (req, res) => {
  const result = await authService.googleSignIn(req.body);
  sendSuccess(res, { message: 'Signed in with Google successfully', data: result });
});

const refresh = asyncHandler(async (req, res) => {
  const result = await authService.refresh(req.body);
  sendSuccess(res, { message: 'Token refreshed successfully', data: result });
});

const logout = asyncHandler(async (req, res) => {
  await authService.logout(req.body);
  sendSuccess(res, { message: 'Logged out successfully' });
});

const forgotPassword = asyncHandler(async (req, res) => {
  await authService.forgotPassword(req.body);
  sendSuccess(res, { message: 'If that email is registered, a reset link has been sent' });
});

const resetPassword = asyncHandler(async (req, res) => {
  await authService.resetPassword(req.body);
  sendSuccess(res, { message: 'Password reset successfully' });
});

const me = asyncHandler(async (req, res) => {
  const user = await authService.getCurrentUser(req.user.id);
  sendSuccess(res, { data: user });
});

module.exports = {
  register,
  login,
  requestOtp,
  verifyOtp,
  googleSignIn,
  refresh,
  logout,
  forgotPassword,
  resetPassword,
  me,
};
