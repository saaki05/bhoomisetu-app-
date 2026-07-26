const { z } = require('zod');

const roleSchema = z.enum(['farmer', 'buyer', 'expert']);

const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Password must contain an uppercase letter')
  .regex(/[a-z]/, 'Password must contain a lowercase letter')
  .regex(/\d/, 'Password must contain a number');

const phoneSchema = z.string().regex(/^[6-9]\d{9}$/, 'Enter a valid 10-digit Indian mobile number');

const registerSchema = z.object({
  fullName: z.string().trim().min(2, 'Full name is required'),
  email: z.string().trim().email('Enter a valid email address'),
  phone: phoneSchema.optional(),
  password: passwordSchema,
  role: roleSchema,
});

const loginSchema = z.object({
  email: z.string().trim().email('Enter a valid email address'),
  password: z.string().min(1, 'Password is required'),
});

const otpRequestSchema = z.object({
  phone: phoneSchema,
});

const otpVerifySchema = z.object({
  phone: phoneSchema,
  otp: z.string().length(6, 'OTP must be 6 digits'),
  // Only required the first time a phone number signs in (no profile yet).
  fullName: z.string().trim().min(2).optional(),
  role: roleSchema.optional(),
});

const googleSignInSchema = z.object({
  idToken: z.string().min(1, 'Google ID token is required'),
  role: roleSchema.optional(),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

const forgotPasswordSchema = z.object({
  email: z.string().trim().email('Enter a valid email address'),
});

const selectRoleSchema = z.object({
  role: roleSchema,
});

const resetPasswordSchema = z.object({
  recoveryAccessToken: z.string().min(1, 'Recovery token is required'),
  newPassword: passwordSchema,
});

module.exports = {
  registerSchema,
  loginSchema,
  otpRequestSchema,
  otpVerifySchema,
  googleSignInSchema,
  refreshSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  selectRoleSchema,
};
