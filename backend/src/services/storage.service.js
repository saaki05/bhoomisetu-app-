const crypto = require('crypto');
const { supabaseAdmin } = require('../config/supabase');
const AppError = require('../utils/AppError');

const LISTING_IMAGES_BUCKET = 'crop-listing-images';
const PROFILE_IMAGES_BUCKET = 'profile-images';
const LISTING_VIDEOS_BUCKET = 'crop-listing-videos';

/**
 * Uploads a single image buffer to Supabase Storage and returns its public
 * URL. The bucket is expected to be created (public read) as part of
 * Supabase project setup — see docs/DEPLOYMENT.md.
 */
async function uploadListingImage({ listingId, buffer, mimeType, originalName }) {
  const extension = (originalName.split('.').pop() || 'jpg').toLowerCase();
  const path = `${listingId}/${crypto.randomUUID()}.${extension}`;

  const { error } = await supabaseAdmin.storage
    .from(LISTING_IMAGES_BUCKET)
    .upload(path, buffer, { contentType: mimeType, upsert: false });

  if (error) {
    throw AppError.internal('Failed to upload image', 'IMAGE_UPLOAD_FAILED');
  }

  const { data } = supabaseAdmin.storage.from(LISTING_IMAGES_BUCKET).getPublicUrl(path);
  return data.publicUrl;
}

/** Uploads an account avatar. Buckets stay separate so public marketplace
 * media can have a different retention policy from profile media. */
async function uploadProfileImage({ userId, buffer, mimeType, originalName }) {
  const extension = (originalName.split('.').pop() || 'jpg').toLowerCase();
  const path = `${userId}/${crypto.randomUUID()}.${extension}`;
  const { error } = await supabaseAdmin.storage
    .from(PROFILE_IMAGES_BUCKET)
    .upload(path, buffer, { contentType: mimeType, upsert: false });

  if (error) throw AppError.internal('Failed to upload profile image', 'AVATAR_UPLOAD_FAILED');
  const { data } = supabaseAdmin.storage.from(PROFILE_IMAGES_BUCKET).getPublicUrl(path);
  return data.publicUrl;
}

async function uploadListingVideo({ userId, listingId, buffer, mimeType, originalName }) {
  const extension = (originalName.split('.').pop() || 'mp4').toLowerCase();
  const path = `${userId}/${listingId}/${crypto.randomUUID()}.${extension}`;
  const { error } = await supabaseAdmin.storage
    .from(LISTING_VIDEOS_BUCKET)
    .upload(path, buffer, { contentType: mimeType, upsert: false });
  if (error) throw AppError.internal('Failed to upload product video', 'VIDEO_UPLOAD_FAILED');
  return supabaseAdmin.storage.from(LISTING_VIDEOS_BUCKET).getPublicUrl(path).data.publicUrl;
}

module.exports = {
  uploadListingImage,
  uploadProfileImage,
  uploadListingVideo,
  LISTING_IMAGES_BUCKET,
  PROFILE_IMAGES_BUCKET,
  LISTING_VIDEOS_BUCKET,
};
