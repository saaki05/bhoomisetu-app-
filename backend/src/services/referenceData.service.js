const crypto = require('crypto');

const { supabaseAdmin } = require('../config/supabase');

const categories = [
  { name: 'Cereals', slug: 'cereals', icon_name: 'grass', display_order: 1 },
  { name: 'Vegetables', slug: 'vegetables', icon_name: 'eco', display_order: 2 },
  { name: 'Fruits', slug: 'fruits', icon_name: 'nutrition', display_order: 3 },
  { name: 'Pulses', slug: 'pulses', icon_name: 'spa', display_order: 4 },
  { name: 'Oilseeds', slug: 'oilseeds', icon_name: 'opacity', display_order: 5 },
  { name: 'Spices', slug: 'spices', icon_name: 'local_fire_department', display_order: 6 },
  { name: 'Cash Crops', slug: 'cash-crops', icon_name: 'payments', display_order: 7 },
  { name: 'Flowers', slug: 'flowers', icon_name: 'local_florist', display_order: 8 },
  { name: 'Dairy', slug: 'dairy', icon_name: 'icecream', display_order: 9 },
  { name: 'Other', slug: 'other', icon_name: 'more_horiz', display_order: 99 },
];

const marketPrices = [
  ['Wheat', 'Cereals', 'Azadpur Mandi', 'North Delhi', 'Delhi', 2150, 2340, 2260],
  ['Rice (Basmati)', 'Cereals', 'Karnal Grain Market', 'Karnal', 'Haryana', 3200, 3800, 3500],
  ['Tomato', 'Vegetables', 'Koyambedu Market', 'Chennai', 'Tamil Nadu', 800, 1600, 1200],
  ['Onion', 'Vegetables', 'Lasalgaon Mandi', 'Nashik', 'Maharashtra', 900, 1800, 1350],
  ['Potato', 'Vegetables', 'Agra Mandi', 'Agra', 'Uttar Pradesh', 700, 1200, 950],
  ['Cotton', 'Cash Crops', 'Rajkot APMC', 'Rajkot', 'Gujarat', 6800, 7400, 7100],
  ['Sugarcane', 'Cash Crops', 'Meerut Mandi', 'Meerut', 'Uttar Pradesh', 340, 380, 360],
  ['Soybean', 'Oilseeds', 'Indore Mandi', 'Indore', 'Madhya Pradesh', 4200, 4700, 4450],
  ['Turmeric', 'Spices', 'Erode Turmeric Market', 'Erode', 'Tamil Nadu', 12000, 14500, 13200],
  ['Mango (Alphonso)', 'Fruits', 'Vashi APMC', 'Mumbai', 'Maharashtra', 4000, 9000, 6500],
].map(([crop_name, category, market_name, district, state, min_price, max_price, modal_price]) => ({
  crop_name,
  category,
  market_name,
  district,
  state,
  min_price,
  max_price,
  modal_price,
  unit: 'quintal',
}));

const schemes = [
  {
    title: 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
    description: 'Income support through direct transfers to eligible landholding farmer families.',
    category: 'Income Support',
    eligibility: 'Eligible landholding farmer families across India.',
    benefits: 'Rs. 6,000 per year in three installments paid directly to the registered bank account.',
    documents_required: ['Aadhaar Card', 'Land Ownership Records', 'Bank Account Passbook'],
    application_url: 'https://pmkisan.gov.in',
    is_active: true,
  },
  {
    title: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
    description: 'Crop insurance against notified yield losses caused by calamities, pests, and diseases.',
    category: 'Insurance',
    eligibility: 'Farmers growing notified crops in notified areas.',
    benefits: 'Risk cover from pre-sowing through post-harvest at subsidized premium rates.',
    documents_required: ['Aadhaar Card', 'Land Records', 'Bank Account Details'],
    application_url: 'https://pmfby.gov.in',
    is_active: true,
  },
  {
    title: 'Soil Health Card Scheme',
    description: 'Soil nutrient reports with crop-specific fertilizer and soil amendment guidance.',
    category: 'Advisory',
    eligibility: 'All farmers with cultivable land.',
    benefits: 'Periodic soil testing and tailored nutrient recommendations.',
    documents_required: ['Aadhaar Card', 'Land Records'],
    application_url: 'https://soilhealth.dac.gov.in',
    is_active: true,
  },
  {
    title: 'Kisan Credit Card (KCC)',
    description: 'Affordable and timely credit for cultivation and related agricultural needs.',
    category: 'Credit',
    eligibility: 'Farmers, tenant farmers, sharecroppers, and agricultural self-help groups.',
    benefits: 'Subsidized short-term credit with repayment aligned to harvest cycles.',
    documents_required: ['Aadhaar Card', 'Land Records', 'Passport Size Photo'],
    application_url: 'https://www.myscheme.gov.in/schemes/kcc',
    is_active: true,
  },
];

const demoFarmers = [
  {
    email: 'kaveri-organic-farms@bhoomisetu.app',
    fullName: 'Kaveri Organic Farms',
    village: 'Thiruvallur',
    district: 'Chennai',
    state: 'Tamil Nadu',
    bio: 'Family-run farm specialising in traceable vegetables and naturally grown seasonal produce.',
  },
  {
    email: 'green-valley-collective@bhoomisetu.app',
    fullName: 'Green Valley Collective',
    village: 'Pollachi',
    district: 'Coimbatore',
    state: 'Tamil Nadu',
    bio: 'Farmer collective supplying grains, fruits, and spices directly from verified member farms.',
  },
];

const demoListings = [
  {
    farmerEmail: demoFarmers[0].email,
    categorySlug: 'vegetables',
    title: 'Farm Fresh Organic Tomatoes',
    description: 'Hand-picked tomatoes graded for freshness and packed on the day of dispatch.',
    price_per_unit: 1450,
    quantity_available: 42,
    is_organic: true,
    district: 'Chennai',
    state: 'Tamil Nadu',
    village: 'Thiruvallur',
    image: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=1200&q=82',
  },
  {
    farmerEmail: demoFarmers[0].email,
    categorySlug: 'vegetables',
    title: 'Premium Red Onions',
    description: 'Clean, well-cured red onions suitable for retail, restaurants, and bulk kitchens.',
    price_per_unit: 1320,
    quantity_available: 65,
    is_organic: false,
    district: 'Chennai',
    state: 'Tamil Nadu',
    village: 'Thiruvallur',
    image: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=1200&q=82',
  },
  {
    farmerEmail: demoFarmers[1].email,
    categorySlug: 'cereals',
    title: 'Naturally Grown Paddy Rice',
    description: 'Carefully dried paddy from cooperative farms with transparent harvest information.',
    price_per_unit: 3180,
    quantity_available: 120,
    is_organic: true,
    district: 'Coimbatore',
    state: 'Tamil Nadu',
    village: 'Pollachi',
    image: 'https://images.unsplash.com/photo-1536055401920-5e7b4e1e3b32?auto=format&fit=crop&w=1200&q=82',
  },
  {
    farmerEmail: demoFarmers[1].email,
    categorySlug: 'spices',
    title: 'Erode Grade Turmeric',
    description: 'Polished turmeric fingers with deep colour and consistent quality for wholesale buyers.',
    price_per_unit: 12800,
    quantity_available: 28,
    is_organic: false,
    district: 'Erode',
    state: 'Tamil Nadu',
    village: 'Gobichettipalayam',
    image: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?auto=format&fit=crop&w=1200&q=82',
  },
];

function ensureNoError(error, operation) {
  if (error) throw new Error(`${operation}: ${error.message}`);
}

async function ensureCategories() {
  const { error } = await supabaseAdmin
    .from('categories')
    .upsert(categories.map((category) => ({ ...category, is_active: true })), { onConflict: 'slug' });
  ensureNoError(error, 'Unable to seed crop categories');
}

async function ensureMarketPrices() {
  const priceDate = new Date().toISOString().slice(0, 10);
  const { data: existing, error: readError } = await supabaseAdmin
    .from('market_prices')
    .select('crop_name, market_name')
    .eq('price_date', priceDate);
  ensureNoError(readError, 'Unable to read market prices');

  const keys = new Set((existing ?? []).map((row) => `${row.crop_name}|${row.market_name}`));
  const missing = marketPrices
    .filter((row) => !keys.has(`${row.crop_name}|${row.market_name}`))
    .map((row) => ({ ...row, price_date: priceDate }));
  if (missing.length === 0) return;

  const { error } = await supabaseAdmin.from('market_prices').insert(missing);
  ensureNoError(error, 'Unable to seed market prices');
}

async function ensureGovernmentSchemes() {
  const { data: existing, error: readError } = await supabaseAdmin
    .from('government_schemes')
    .select('title')
    .is('deleted_at', null);
  ensureNoError(readError, 'Unable to read government schemes');

  const titles = new Set((existing ?? []).map((row) => row.title));
  const missing = schemes.filter((scheme) => !titles.has(scheme.title));
  if (missing.length === 0) return;

  const { error } = await supabaseAdmin.from('government_schemes').insert(missing);
  ensureNoError(error, 'Unable to seed government schemes');
}

async function ensureDemoFarmer(farmer) {
  const { data: existing, error: readError } = await supabaseAdmin
    .from('profiles')
    .select('id')
    .eq('email', farmer.email)
    .maybeSingle();
  ensureNoError(readError, `Unable to find demo farmer ${farmer.fullName}`);

  let id = existing?.id;
  if (!id) {
    const password = crypto.randomBytes(32).toString('base64url');
    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email: farmer.email,
      password,
      email_confirm: true,
      user_metadata: { full_name: farmer.fullName, role: 'farmer' },
    });
    ensureNoError(error, `Unable to create demo farmer ${farmer.fullName}`);
    id = data.user.id;
  }

  const { error: updateError } = await supabaseAdmin
    .from('profiles')
    .update({
      role: 'farmer',
      full_name: farmer.fullName,
      village: farmer.village,
      district: farmer.district,
      state: farmer.state,
      bio: farmer.bio,
      is_email_verified: true,
      is_active: true,
      deleted_at: null,
    })
    .eq('id', id);
  ensureNoError(updateError, `Unable to update demo farmer ${farmer.fullName}`);
  return id;
}

async function ensureDemoCatalog() {
  const farmerIds = new Map();
  for (const farmer of demoFarmers) {
    farmerIds.set(farmer.email, await ensureDemoFarmer(farmer));
  }

  const { data: categoryRows, error: categoryError } = await supabaseAdmin
    .from('categories')
    .select('id, slug');
  ensureNoError(categoryError, 'Unable to resolve demo listing categories');
  const categoryIds = new Map(categoryRows.map((row) => [row.slug, row.id]));

  for (const listing of demoListings) {
    const farmerId = farmerIds.get(listing.farmerEmail);
    const { data: existing, error: readError } = await supabaseAdmin
      .from('crop_listings')
      .select('id')
      .eq('farmer_id', farmerId)
      .eq('title', listing.title)
      .is('deleted_at', null)
      .maybeSingle();
    ensureNoError(readError, `Unable to find demo listing ${listing.title}`);

    let listingId = existing?.id;
    if (!listingId) {
      const { data: created, error: createError } = await supabaseAdmin
        .from('crop_listings')
        .insert({
          farmer_id: farmerId,
          category_id: categoryIds.get(listing.categorySlug),
          title: listing.title,
          description: listing.description,
          status: 'active',
          price_per_unit: listing.price_per_unit,
          unit: 'quintal',
          quantity_available: listing.quantity_available,
          suggested_market_price: listing.price_per_unit,
          is_organic: listing.is_organic,
          harvest_date: new Date(Date.now() + 7 * 86400000).toISOString().slice(0, 10),
          district: listing.district,
          state: listing.state,
          village: listing.village,
          avg_rating: 4.7,
          total_reviews: 18,
        })
        .select('id')
        .single();
      ensureNoError(createError, `Unable to create demo listing ${listing.title}`);
      listingId = created.id;
    }

    const { count, error: imageReadError } = await supabaseAdmin
      .from('crop_listing_images')
      .select('id', { count: 'exact', head: true })
      .eq('listing_id', listingId);
    ensureNoError(imageReadError, `Unable to inspect images for ${listing.title}`);
    if ((count ?? 0) === 0) {
      const { error: imageError } = await supabaseAdmin
        .from('crop_listing_images')
        .insert({ listing_id: listingId, image_url: listing.image, display_order: 0 });
      ensureNoError(imageError, `Unable to seed image for ${listing.title}`);
    }
  }
}

async function ensureReferenceData({ includeDemoCatalog = true } = {}) {
  await ensureCategories();
  await Promise.all([ensureMarketPrices(), ensureGovernmentSchemes()]);
  if (includeDemoCatalog) await ensureDemoCatalog();
}

module.exports = { ensureReferenceData };
