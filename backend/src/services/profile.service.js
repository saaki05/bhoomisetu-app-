const { supabaseAdmin } = require('../config/supabase');
const AppError = require('../utils/AppError');

function mapProfile(profile) {
  return {
    id: profile.id,
    role: profile.role,
    fullName: profile.full_name,
    email: profile.email,
    phone: profile.phone,
    avatarUrl: profile.avatar_url,
    bio: profile.bio,
    village: profile.village,
    district: profile.district,
    state: profile.state,
    pincode: profile.pincode,
    isPhoneVerified: profile.is_phone_verified,
    isEmailVerified: profile.is_email_verified,
    avgRating: Number(profile.avg_rating ?? 0),
    totalReviews: profile.total_reviews ?? 0,
    roleSelected: profile.role_selected ?? true,
    createdAt: profile.created_at,
  };
}

async function getProfile(userId) {
  const { data, error } = await supabaseAdmin
    .from('profiles').select('*').eq('id', userId).is('deleted_at', null).single();
  if (error || !data) throw AppError.notFound('User profile not found', 'PROFILE_NOT_FOUND');
  return mapProfile(data);
}

async function updateProfile(userId, input) {
  const update = {};
  const fields = {
    fullName: 'full_name', phone: 'phone', bio: 'bio', village: 'village',
    district: 'district', state: 'state', pincode: 'pincode',
  };
  for (const [source, target] of Object.entries(fields)) {
    if (Object.hasOwn(input, source)) update[target] = input[source];
  }

  if (input.latitude !== undefined) {
    // PostGIS geography accepts WKT through PostgREST for a geography column.
    update.location = `POINT(${input.longitude} ${input.latitude})`;
  }

  const { data, error } = await supabaseAdmin
    .from('profiles').update(update).eq('id', userId).select('*').single();
  if (error || !data) throw AppError.internal('Failed to update profile', 'PROFILE_UPDATE_FAILED');
  return mapProfile(data);
}

async function setAvatar(userId, avatarUrl) {
  const { data, error } = await supabaseAdmin
    .from('profiles').update({ avatar_url: avatarUrl }).eq('id', userId).select('*').single();
  if (error || !data) throw AppError.internal('Failed to update profile image', 'AVATAR_UPDATE_FAILED');
  return mapProfile(data);
}

module.exports = { getProfile, updateProfile, setAvatar };
