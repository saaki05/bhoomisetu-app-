const { supabaseAdmin } = require('../config/supabase');
const { getWeatherForLocation, getWeatherForCoordinates } = require('./weather.service');
const AppError = require('../utils/AppError');

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

async function getLatestMarketPrices(limit = 10) {
  const { data, error } = await supabaseAdmin
    .from('market_prices')
    .select('*')
    .order('price_date', { ascending: false })
    .order('crop_name', { ascending: true })
    .limit(limit);

  if (error) return [];

  return data.map((row) => ({
    id: row.id,
    cropName: row.crop_name,
    category: row.category,
    marketName: row.market_name,
    district: row.district,
    state: row.state,
    minPrice: Number(row.min_price),
    maxPrice: Number(row.max_price),
    modalPrice: Number(row.modal_price),
    unit: row.unit,
    priceDate: row.price_date,
  }));
}

async function getActiveSchemes(limit = 5) {
  const { data, error } = await supabaseAdmin
    .from('government_schemes')
    .select('id, title, description, category, deadline, application_url')
    .is('deleted_at', null)
    .eq('is_active', true)
    .order('created_at', { ascending: false })
    .limit(limit);

  if (error) return [];

  return data.map((row) => ({
    id: row.id,
    title: row.title,
    description: row.description,
    category: row.category,
    deadline: row.deadline,
    applicationUrl: row.application_url,
  }));
}

/**
 * "Nearby" buyers are approximated by matching district rather than a true
 * geo-radius query — farms don't have geocoded coordinates captured yet
 * (that lands with the Marketplace module's location picker). District
 * matching is a real, meaningful signal in the meantime, not a stub.
 */
async function getNearbyBuyers(district, limit = 10) {
  if (!district) return [];

  const { data, error } = await supabaseAdmin
    .from('profiles')
    .select('id, full_name, avatar_url, village, district, avg_rating, total_reviews')
    .eq('role', 'buyer')
    .eq('district', district)
    .is('deleted_at', null)
    .limit(limit);

  if (error) return [];

  return data.map((row) => ({
    id: row.id,
    fullName: row.full_name,
    avatarUrl: row.avatar_url,
    village: row.village,
    district: row.district,
    avgRating: Number(row.avg_rating),
    totalReviews: row.total_reviews,
  }));
}

async function getHomeSummary(userId, { lat, lon } = {}) {
  const profile = await fetchProfile(userId);

  // A live GPS fix beats a saved district — many profiles never fill that
  // field in, and even when they do it can go stale as people move around.
  const weatherPromise =
    lat != null && lon != null
      ? getWeatherForCoordinates(lat, lon)
      : getWeatherForLocation({ district: profile.district, state: profile.state });

  const [weather, marketPrices, schemes, nearbyBuyers] = await Promise.all([
    weatherPromise,
    getLatestMarketPrices(),
    getActiveSchemes(),
    profile.role === 'farmer' ? getNearbyBuyers(profile.district) : Promise.resolve([]),
  ]);

  return {
    greeting: {
      fullName: profile.full_name,
      role: profile.role,
      avatarUrl: profile.avatar_url,
    },
    weather,
    marketPrices,
    governmentSchemes: schemes,
    nearbyBuyers,
    // Populated once the Marketplace module's crop_listings table exists.
    recommendedCrops: [],
  };
}

module.exports = { getHomeSummary };
