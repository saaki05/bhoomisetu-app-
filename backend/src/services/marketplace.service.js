const { supabaseAdmin } = require('../config/supabase');
const { uploadListingImage } = require('./storage.service');
const AppError = require('../utils/AppError');

function mapListing(row) {
  return {
    id: row.id,
    farmerId: row.farmer_id,
    categoryId: row.category_id,
    categoryName: row.categories?.name,
    title: row.title,
    description: row.description,
    status: row.status,
    pricePerUnit: Number(row.price_per_unit),
    unit: row.unit,
    quantityAvailable: Number(row.quantity_available),
    suggestedMarketPrice: row.suggested_market_price ? Number(row.suggested_market_price) : null,
    isOrganic: row.is_organic,
    organicCertificateUrl: row.organic_certificate_url,
    harvestDate: row.harvest_date,
    district: row.district,
    state: row.state,
    village: row.village,
    avgRating: Number(row.avg_rating),
    totalReviews: row.total_reviews,
    images: (row.crop_listing_images ?? [])
      .sort((a, b) => a.display_order - b.display_order)
      .map((img) => img.image_url),
    farmer: row.profiles
      ? {
          id: row.profiles.id,
          fullName: row.profiles.full_name,
          avatarUrl: row.profiles.avatar_url,
          avgRating: Number(row.profiles.avg_rating),
          totalReviews: row.profiles.total_reviews,
          phone: row.profiles.phone,
        }
      : undefined,
    createdAt: row.created_at,
  };
}

const LISTING_SELECT = `
  *,
  categories ( name ),
  crop_listing_images ( image_url, display_order ),
  profiles!crop_listings_farmer_id_fkey ( id, full_name, avatar_url, avg_rating, total_reviews, phone )
`;

async function listCategories() {
  const { data, error } = await supabaseAdmin
    .from('categories')
    .select('id, name, slug, icon_name, parent_id, display_order')
    .eq('is_active', true)
    .order('display_order', { ascending: true });

  if (error) throw AppError.internal('Failed to load categories');
  return data.map((c) => ({
    id: c.id,
    name: c.name,
    slug: c.slug,
    iconName: c.icon_name,
    parentId: c.parent_id,
  }));
}

async function searchListings(filters) {
  let query = supabaseAdmin
    .from('crop_listings')
    .select(LISTING_SELECT, { count: 'exact' })
    .is('deleted_at', null)
    .eq('status', 'active');

  if (filters.q) query = query.ilike('title', `%${filters.q}%`);
  if (filters.categoryId) query = query.eq('category_id', filters.categoryId);
  if (filters.district) query = query.eq('district', filters.district);
  if (filters.state) query = query.eq('state', filters.state);
  if (filters.organic !== undefined) query = query.eq('is_organic', filters.organic);
  if (filters.minPrice !== undefined) query = query.gte('price_per_unit', filters.minPrice);
  if (filters.maxPrice !== undefined) query = query.lte('price_per_unit', filters.maxPrice);

  const sortMap = {
    newest: { column: 'created_at', ascending: false },
    price_asc: { column: 'price_per_unit', ascending: true },
    price_desc: { column: 'price_per_unit', ascending: false },
    rating: { column: 'avg_rating', ascending: false },
  };
  const sort = sortMap[filters.sortBy] ?? sortMap.newest;
  query = query.order(sort.column, { ascending: sort.ascending });

  const from = (filters.page - 1) * filters.pageSize;
  const to = from + filters.pageSize - 1;
  query = query.range(from, to);

  const { data, error, count } = await query;
  if (error) throw AppError.internal('Failed to search listings');

  return {
    items: data.map(mapListing),
    page: filters.page,
    pageSize: filters.pageSize,
    total: count ?? 0,
    totalPages: Math.ceil((count ?? 0) / filters.pageSize),
  };
}

async function getListingById(id) {
  const { data, error } = await supabaseAdmin
    .from('crop_listings')
    .select(LISTING_SELECT)
    .eq('id', id)
    .is('deleted_at', null)
    .single();

  if (error || !data) throw AppError.notFound('Listing not found', 'LISTING_NOT_FOUND');

  await supabaseAdmin
    .from('crop_listings')
    .update({ view_count: (data.view_count ?? 0) + 1 })
    .eq('id', id);

  return mapListing(data);
}

async function createListing(farmerId, payload) {
  const { data, error } = await supabaseAdmin
    .from('crop_listings')
    .insert({
      farmer_id: farmerId,
      farm_id: payload.farmId ?? null,
      category_id: payload.categoryId,
      title: payload.title,
      description: payload.description ?? null,
      status: payload.status,
      price_per_unit: payload.pricePerUnit,
      unit: payload.unit,
      quantity_available: payload.quantityAvailable,
      suggested_market_price: payload.suggestedMarketPrice ?? null,
      is_organic: payload.isOrganic,
      harvest_date: payload.harvestDate ?? null,
      district: payload.district ?? null,
      state: payload.state ?? null,
      village: payload.village ?? null,
    })
    .select(LISTING_SELECT)
    .single();

  if (error) throw AppError.internal('Failed to create listing');
  return mapListing(data);
}

async function updateListing(farmerId, listingId, payload) {
  const { data: existing, error: fetchError } = await supabaseAdmin
    .from('crop_listings')
    .select('id, farmer_id')
    .eq('id', listingId)
    .is('deleted_at', null)
    .single();

  if (fetchError || !existing) throw AppError.notFound('Listing not found', 'LISTING_NOT_FOUND');
  if (existing.farmer_id !== farmerId) {
    throw AppError.forbidden('You can only edit your own listings', 'NOT_LISTING_OWNER');
  }

  const updates = {};
  const fieldMap = {
    categoryId: 'category_id',
    farmId: 'farm_id',
    title: 'title',
    description: 'description',
    status: 'status',
    pricePerUnit: 'price_per_unit',
    unit: 'unit',
    quantityAvailable: 'quantity_available',
    suggestedMarketPrice: 'suggested_market_price',
    isOrganic: 'is_organic',
    harvestDate: 'harvest_date',
    district: 'district',
    state: 'state',
    village: 'village',
  };
  for (const [key, column] of Object.entries(fieldMap)) {
    if (payload[key] !== undefined) updates[column] = payload[key];
  }

  const { data, error } = await supabaseAdmin
    .from('crop_listings')
    .update(updates)
    .eq('id', listingId)
    .select(LISTING_SELECT)
    .single();

  if (error) throw AppError.internal('Failed to update listing');
  return mapListing(data);
}

async function deleteListing(farmerId, listingId) {
  const { data: existing, error: fetchError } = await supabaseAdmin
    .from('crop_listings')
    .select('id, farmer_id')
    .eq('id', listingId)
    .is('deleted_at', null)
    .single();

  if (fetchError || !existing) throw AppError.notFound('Listing not found', 'LISTING_NOT_FOUND');
  if (existing.farmer_id !== farmerId) {
    throw AppError.forbidden('You can only delete your own listings', 'NOT_LISTING_OWNER');
  }

  const { error } = await supabaseAdmin
    .from('crop_listings')
    .update({ deleted_at: new Date().toISOString() })
    .eq('id', listingId);

  if (error) throw AppError.internal('Failed to delete listing');
}

async function addListingImages(farmerId, listingId, files) {
  const { data: existing, error: fetchError } = await supabaseAdmin
    .from('crop_listings')
    .select('id, farmer_id')
    .eq('id', listingId)
    .is('deleted_at', null)
    .single();

  if (fetchError || !existing) throw AppError.notFound('Listing not found', 'LISTING_NOT_FOUND');
  if (existing.farmer_id !== farmerId) {
    throw AppError.forbidden('You can only edit your own listings', 'NOT_LISTING_OWNER');
  }

  const { count } = await supabaseAdmin
    .from('crop_listing_images')
    .select('id', { count: 'exact', head: true })
    .eq('listing_id', listingId);

  if ((count ?? 0) + files.length > 6) {
    throw AppError.badRequest('A listing can have at most 6 images', 'TOO_MANY_IMAGES');
  }

  const urls = await Promise.all(
    files.map((file) =>
      uploadListingImage({
        listingId,
        buffer: file.buffer,
        mimeType: file.mimetype,
        originalName: file.originalname,
      }),
    ),
  );

  const rows = urls.map((url, index) => ({
    listing_id: listingId,
    image_url: url,
    display_order: (count ?? 0) + index,
  }));

  const { data, error } = await supabaseAdmin.from('crop_listing_images').insert(rows).select('image_url');
  if (error) throw AppError.internal('Failed to save uploaded images');
  return data.map((row) => row.image_url);
}

async function reportListing(userId, listingId, payload) {
  const { data: existing } = await supabaseAdmin
    .from('crop_listings')
    .select('id')
    .eq('id', listingId)
    .is('deleted_at', null)
    .maybeSingle();

  if (!existing) throw AppError.notFound('Listing not found', 'LISTING_NOT_FOUND');

  const { error } = await supabaseAdmin.from('listing_reports').insert({
    listing_id: listingId,
    reported_by: userId,
    reason: payload.reason,
    details: payload.details ?? null,
  });

  if (error) throw AppError.internal('Failed to submit report');
}

async function toggleBookmark(userId, listingId) {
  const { data: existing } = await supabaseAdmin
    .from('bookmarks')
    .select('id')
    .eq('user_id', userId)
    .eq('listing_id', listingId)
    .maybeSingle();

  if (existing) {
    await supabaseAdmin.from('bookmarks').delete().eq('id', existing.id);
    return { bookmarked: false };
  }

  const { error } = await supabaseAdmin.from('bookmarks').insert({ user_id: userId, listing_id: listingId });
  if (error) throw AppError.internal('Failed to bookmark listing');
  return { bookmarked: true };
}

async function listBookmarks(userId) {
  const { data, error } = await supabaseAdmin
    .from('bookmarks')
    .select(`listing_id, crop_listings ( ${LISTING_SELECT} )`)
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) throw AppError.internal('Failed to load bookmarks');
  return data.filter((row) => row.crop_listings).map((row) => mapListing(row.crop_listings));
}

module.exports = {
  listCategories,
  searchListings,
  getListingById,
  createListing,
  updateListing,
  deleteListing,
  addListingImages,
  reportListing,
  toggleBookmark,
  listBookmarks,
};
