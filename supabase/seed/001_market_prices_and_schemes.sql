-- ============================================================================
-- Seed data for local/dev environments. Run after migrations:
--   psql "$DATABASE_URL" -f supabase/seed/001_market_prices_and_schemes.sql
-- Prices are illustrative mandi rates in INR per quintal unless noted.
-- ============================================================================

insert into market_prices (crop_name, category, market_name, district, state, min_price, max_price, modal_price, unit, price_date)
values
  ('Wheat', 'Cereals', 'Azadpur Mandi', 'North Delhi', 'Delhi', 2150, 2340, 2260, 'quintal', current_date),
  ('Rice (Basmati)', 'Cereals', 'Karnal Grain Market', 'Karnal', 'Haryana', 3200, 3800, 3500, 'quintal', current_date),
  ('Tomato', 'Vegetables', 'Kalimati Market', 'Pune', 'Maharashtra', 800, 1600, 1200, 'quintal', current_date),
  ('Onion', 'Vegetables', 'Lasalgaon Mandi', 'Nashik', 'Maharashtra', 900, 1800, 1350, 'quintal', current_date),
  ('Potato', 'Vegetables', 'Agra Mandi', 'Agra', 'Uttar Pradesh', 700, 1200, 950, 'quintal', current_date),
  ('Cotton', 'Cash Crops', 'Rajkot APMC', 'Rajkot', 'Gujarat', 6800, 7400, 7100, 'quintal', current_date),
  ('Sugarcane', 'Cash Crops', 'Meerut Mandi', 'Meerut', 'Uttar Pradesh', 340, 380, 360, 'quintal', current_date),
  ('Soybean', 'Oilseeds', 'Indore Mandi', 'Indore', 'Madhya Pradesh', 4200, 4700, 4450, 'quintal', current_date),
  ('Turmeric', 'Spices', 'Erode Turmeric Market', 'Erode', 'Tamil Nadu', 12000, 14500, 13200, 'quintal', current_date),
  ('Mango (Alphonso)', 'Fruits', 'Vashi APMC', 'Mumbai', 'Maharashtra', 4000, 9000, 6500, 'quintal', current_date);

insert into government_schemes
  (title, description, category, eligibility, benefits, documents_required, deadline, application_url, is_active)
values
  (
    'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
    'Income support scheme providing direct cash transfers to landholding farmer families.',
    'Income Support',
    'Small and marginal landholding farmer families across India.',
    'Rs. 6,000 per year in three equal installments credited directly to bank accounts.',
    array['Aadhaar Card', 'Land Ownership Records', 'Bank Account Passbook'],
    null,
    'https://pmkisan.gov.in',
    true
  ),
  (
    'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
    'Crop insurance scheme protecting farmers against yield losses from natural calamities, pests, and diseases.',
    'Insurance',
    'Farmers growing notified crops in notified areas, both loanee and non-loanee.',
    'Comprehensive risk cover from pre-sowing to post-harvest losses at low premium rates.',
    array['Aadhaar Card', 'Land Records', 'Bank Account Details', 'Sowing Certificate'],
    null,
    'https://pmfby.gov.in',
    true
  ),
  (
    'Soil Health Card Scheme',
    'Provides farmers with soil nutrient status reports and crop-wise fertilizer recommendations.',
    'Advisory',
    'All farmers with cultivable land.',
    'Free soil testing every 2 years with tailored fertilizer and nutrient recommendations.',
    array['Aadhaar Card', 'Land Records'],
    null,
    'https://soilhealth.dac.gov.in',
    true
  ),
  (
    'Kisan Credit Card (KCC)',
    'Provides farmers with affordable, timely credit for cultivation and other agricultural needs.',
    'Credit',
    'Farmers, tenant farmers, sharecroppers, and self-help groups engaged in agriculture.',
    'Short-term credit at subsidized interest rates with flexible repayment aligned to harvest cycles.',
    array['Aadhaar Card', 'Land Records', 'Passport Size Photo'],
    null,
    'https://www.myscheme.gov.in/schemes/kcc',
    true
  );
