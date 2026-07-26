const { createClient } = require('@supabase/supabase-js');
const { supabaseAdmin, supabaseAuth } = require('../config/supabase');
const { signAccessToken, signRefreshToken, verifyRefreshToken } = require('../utils/jwt');
const { revokeRefreshToken, isRefreshTokenRevoked } = require('../utils/tokenBlocklist');
const AppError = require('../utils/AppError');
const logger = require('../config/logger');
const { loadEnv } = require('../config/env');

const env = loadEnv();

const toE164 = (phone) => `+91${phone}`;

function mapProfileToUser(profile) {
  return {
    id: profile.id,
    role: profile.role,
    fullName: profile.full_name,
    email: profile.email,
    phone: profile.phone,
    avatarUrl: profile.avatar_url,
    village: profile.village,
    district: profile.district,
    state: profile.state,
    isPhoneVerified: profile.is_phone_verified,
    isEmailVerified: profile.is_email_verified,
    avgRating: Number(profile.avg_rating),
    totalReviews: profile.total_reviews,
    // Google/OTP signup carries no account type, so those users land with a
    // defaulted role they never chose. The app gates the main shell on this
    // and routes them to the role picker first.
    roleSelected: profile.role_selected ?? true,
    createdAt: profile.created_at,
  };
}

async function fetchProfile(userId) {
  const { data, error } = await supabaseAdmin
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .is('deleted_at', null)
    .single();

  if (error || !data) {
    throw AppError.notFound('User profile not found', 'PROFILE_NOT_FOUND');
  }
  return data;
}

function issueTokens(profile) {
  const basePayload = { sub: profile.id, role: profile.role, email: profile.email };
  const accessToken = signAccessToken(basePayload);
  const { token: refreshToken } = signRefreshToken(basePayload);
  return { accessToken, refreshToken };
}

async function register({ fullName, email, phone, password, role }) {
  const { data, error } = await supabaseAdmin.auth.admin.createUser({
    email,
    phone: phone ? toE164(phone) : undefined,
    password,
    email_confirm: true,
    user_metadata: { full_name: fullName, role },
  });

  if (error) {
    if (error.status === 422 || /already registered|already exists/i.test(error.message)) {
      throw AppError.conflict('An account with this email already exists', 'EMAIL_TAKEN');
    }
    logger.error('Supabase createUser failed', { error: error.message });
    throw AppError.internal('Failed to create account');
  }

  const profile = await fetchProfile(data.user.id);
  const tokens = issueTokens(profile);
  return { user: mapProfileToUser(profile), ...tokens };
}

async function login({ email, password }) {
  const { data, error } = await supabaseAuth.auth.signInWithPassword({ email, password });

  if (error || !data.session) {
    throw AppError.unauthorized('Invalid email or password', 'INVALID_CREDENTIALS');
  }

  const profile = await fetchProfile(data.user.id);
  const tokens = issueTokens(profile);
  return { user: mapProfileToUser(profile), ...tokens };
}

async function requestOtp({ phone }) {
  const { error } = await supabaseAuth.auth.signInWithOtp({ phone: toE164(phone) });
  if (error) {
    logger.error('Supabase OTP request failed', { error: error.message });
    throw AppError.internal('Failed to send OTP, please try again');
  }
}

async function verifyOtp({ phone, otp, fullName, role }) {
  const { data, error } = await supabaseAuth.auth.verifyOtp({
    phone: toE164(phone),
    token: otp,
    type: 'sms',
  });

  if (error || !data.session) {
    throw AppError.unauthorized('Invalid or expired OTP', 'INVALID_OTP');
  }

  let profile = await fetchProfile(data.user.id);
  const isFirstVerification = Date.now() - new Date(data.user.created_at).getTime() < 15000;

  if (isFirstVerification && (fullName || role)) {
    const { data: updated, error: updateError } = await supabaseAdmin
      .from('profiles')
      .update({
        full_name: fullName ?? profile.full_name,
        role: role ?? profile.role,
        role_selected: role ? true : profile.role_selected,
        is_phone_verified: true,
      })
      .eq('id', profile.id)
      .select('*')
      .single();

    if (!updateError && updated) profile = updated;
  } else if (!profile.is_phone_verified) {
    await supabaseAdmin.from('profiles').update({ is_phone_verified: true }).eq('id', profile.id);
    profile.is_phone_verified = true;
  }

  const tokens = issueTokens(profile);
  return { user: mapProfileToUser(profile), ...tokens };
}

async function googleSignIn({ idToken, role }) {
  const { data, error } = await supabaseAuth.auth.signInWithIdToken({ provider: 'google', token: idToken });

  if (error || !data.session) {
    throw AppError.unauthorized('Google sign-in failed', 'GOOGLE_SIGN_IN_FAILED');
  }

  let profile = await fetchProfile(data.user.id);
  const isFirstSignIn = Date.now() - new Date(data.user.created_at).getTime() < 15000;

  if (isFirstSignIn && role) {
    const { data: updated, error: updateError } = await supabaseAdmin
      .from('profiles')
      .update({ role, role_selected: true, is_email_verified: true })
      .eq('id', profile.id)
      .select('*')
      .single();

    if (!updateError && updated) profile = updated;
  }

  const tokens = issueTokens(profile);
  return { user: mapProfileToUser(profile), ...tokens };
}

async function refresh({ refreshToken }) {
  let payload;
  try {
    payload = verifyRefreshToken(refreshToken);
  } catch {
    throw AppError.unauthorized('Invalid or expired refresh token', 'INVALID_REFRESH_TOKEN');
  }

  if (await isRefreshTokenRevoked(payload.jti)) {
    throw AppError.unauthorized('Session has been revoked, please log in again', 'REFRESH_TOKEN_REVOKED');
  }

  const profile = await fetchProfile(payload.sub);
  const ttlSeconds = Math.max(payload.exp - Math.floor(Date.now() / 1000), 0);
  await revokeRefreshToken(payload.jti, ttlSeconds);

  const tokens = issueTokens(profile);
  return { user: mapProfileToUser(profile), ...tokens };
}

async function logout({ refreshToken }) {
  try {
    const payload = verifyRefreshToken(refreshToken);
    const ttlSeconds = Math.max(payload.exp - Math.floor(Date.now() / 1000), 0);
    await revokeRefreshToken(payload.jti, ttlSeconds);
  } catch {
    // Token already invalid/expired — logout is idempotent either way.
  }
}

async function forgotPassword({ email }) {
  const { error } = await supabaseAuth.auth.resetPasswordForEmail(email);
  if (error) {
    logger.error('Supabase resetPasswordForEmail failed', { error: error.message });
  }
  // Always resolve successfully so this endpoint can't be used to enumerate
  // registered email addresses.
}

async function resetPassword({ recoveryAccessToken, newPassword }) {
  const scopedClient = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
    global: { headers: { Authorization: `Bearer ${recoveryAccessToken}` } },
  });

  const { error } = await scopedClient.auth.updateUser({ password: newPassword });
  if (error) {
    throw AppError.badRequest('Could not reset password, the link may have expired', 'RESET_PASSWORD_FAILED');
  }
}

async function getCurrentUser(userId) {
  const profile = await fetchProfile(userId);
  return mapProfileToUser(profile);
}

/**
 * Lets a user who signed up without picking an account type (Google, OTP)
 * choose one after the fact. Once set, role_selected is permanent — this
 * isn't a "change my role" endpoint, just "finish onboarding".
 */
async function selectRole(userId, role) {
  const profile = await fetchProfile(userId);

  if (profile.role_selected) {
    throw AppError.conflict('Account type has already been set', 'ROLE_ALREADY_SELECTED');
  }

  const { data: updated, error } = await supabaseAdmin
    .from('profiles')
    .update({ role, role_selected: true })
    .eq('id', userId)
    .select('*')
    .single();

  if (error || !updated) throw AppError.internal('Failed to set account type');
  return mapProfileToUser(updated);
}

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
  getCurrentUser,
  selectRole,
};
