const crypto = require('crypto');
const { supabaseAdmin } = require('../config/supabase');
const AppError = require('../utils/AppError');

const LISTING_IMAGES_BUCKET = 'crop-listing-images';

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

module.exports = { uploadListingImage, LISTING_IMAGES_BUCKET };
