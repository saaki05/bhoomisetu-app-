-- ============================================================================
-- 0004_marketplace.sql
-- Crop categories, listings, listing images, and bookmarks — the core
-- Marketplace data model.
-- ============================================================================

create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  icon_name text,
  parent_id uuid references categories (id) on delete set null,
  display_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index idx_categories_parent on categories (parent_id);

create table crop_listings (
  id uuid primary key default gen_random_uuid(),
  farmer_id uuid not null references profiles (id) on delete cascade,
  farm_id uuid references farms (id) on delete set null,
  category_id uuid not null references categories (id),
  title text not null,
  description text,
  status crop_listing_status not null default 'draft',
  price_per_unit numeric(10, 2) not null check (price_per_unit > 0),
  unit text not null default 'quintal',
  quantity_available numeric(10, 2) not null check (quantity_available >= 0),
  suggested_market_price numeric(10, 2),
  is_organic boolean not null default false,
  organic_certificate_url text,
  harvest_date date,
  district text,
  state text,
  village text,
  location geography(point, 4326),
  avg_rating numeric(3, 2) not null default 0 check (avg_rating between 0 and 5),
  total_reviews integer not null default 0,
  view_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_listings_farmer on crop_listings (farmer_id) where deleted_at is null;
create index idx_listings_category on crop_listings (category_id) where deleted_at is null;
create index idx_listings_status on crop_listings (status) where deleted_at is null;
create index idx_listings_location on crop_listings using gist (location);
create index idx_listings_district on crop_listings (district) where deleted_at is null;
create index idx_listings_title_trgm on crop_listings using gin (title gin_trgm_ops);
create index idx_listings_created_at on crop_listings (created_at desc);

create trigger trg_listings_updated_at
  before update on crop_listings
  for each row execute function set_updated_at();

create trigger trg_listings_audit
  after insert or update or delete on crop_listings
  for each row execute function audit_log_trigger();

create table crop_listing_images (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references crop_listings (id) on delete cascade,
  image_url text not null,
  display_order integer not null default 0,
  created_at timestamptz not null default now()
);

create index idx_listing_images_listing on crop_listing_images (listing_id);

create table bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles (id) on delete cascade,
  listing_id uuid not null references crop_listings (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, listing_id)
);

create table listing_reports (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references crop_listings (id) on delete cascade,
  reported_by uuid not null references profiles (id) on delete cascade,
  reason text not null,
  details text,
  status text not null default 'pending' check (status in ('pending', 'reviewed', 'dismissed')),
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Row Level Security
-- ----------------------------------------------------------------------------
alter table categories enable row level security;
alter table crop_listings enable row level security;
alter table crop_listing_images enable row level security;
alter table bookmarks enable row level security;
alter table listing_reports enable row level security;

create policy "categories_public_read" on categories for select using (is_active);
create policy "categories_admin_write" on categories for all using (is_admin()) with check (is_admin());

create policy "listings_public_read_active" on crop_listings
  for select using (deleted_at is null and status <> 'draft');
create policy "listings_farmer_read_own" on crop_listings
  for select using (farmer_id = auth.uid());
create policy "listings_farmer_manage_own" on crop_listings
  for all using (farmer_id = auth.uid()) with check (farmer_id = auth.uid());
create policy "listings_admin_full_access" on crop_listings
  for all using (is_admin()) with check (is_admin());

create policy "listing_images_public_read" on crop_listing_images for select using (true);
create policy "listing_images_manage_via_listing" on crop_listing_images for all
  using (exists (select 1 from crop_listings l where l.id = listing_id and l.farmer_id = auth.uid()))
  with check (exists (select 1 from crop_listings l where l.id = listing_id and l.farmer_id = auth.uid()));

create policy "bookmarks_manage_own" on bookmarks for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "listing_reports_create_own" on listing_reports for insert
  with check (reported_by = auth.uid());
create policy "listing_reports_admin_read" on listing_reports for select using (is_admin());
