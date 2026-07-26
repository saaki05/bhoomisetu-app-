-- ============================================================================
-- 0003_market_prices_and_schemes.sql
-- Standalone reference data the Home screen (and later the Marketplace and
-- Government Schemes modules) read from: daily mandi price snapshots and
-- government scheme listings.
-- ============================================================================

create table market_prices (
  id uuid primary key default gen_random_uuid(),
  crop_name text not null,
  category text,
  market_name text not null,
  district text,
  state text not null,
  min_price numeric(10, 2) not null check (min_price >= 0),
  max_price numeric(10, 2) not null check (max_price >= min_price),
  modal_price numeric(10, 2) not null check (modal_price between min_price and max_price),
  unit text not null default 'quintal',
  price_date date not null default current_date,
  created_at timestamptz not null default now()
);

create index idx_market_prices_crop_date on market_prices (crop_name, price_date desc);
create index idx_market_prices_state_district on market_prices (state, district);

create table government_schemes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  category text not null,
  eligibility text,
  benefits text,
  documents_required text[] not null default '{}',
  deadline date,
  application_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_schemes_active on government_schemes (is_active) where deleted_at is null;

create trigger trg_schemes_updated_at
  before update on government_schemes
  for each row execute function set_updated_at();

create table scheme_bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles (id) on delete cascade,
  scheme_id uuid not null references government_schemes (id) on delete cascade,
  reminder_at timestamptz,
  created_at timestamptz not null default now(),
  unique (user_id, scheme_id)
);

alter table market_prices enable row level security;
alter table government_schemes enable row level security;
alter table scheme_bookmarks enable row level security;

create policy "market_prices_public_read" on market_prices for select using (true);
create policy "market_prices_admin_write" on market_prices for all using (is_admin()) with check (is_admin());

create policy "schemes_public_read" on government_schemes for select using (deleted_at is null and is_active);
create policy "schemes_admin_full_access" on government_schemes for all using (is_admin()) with check (is_admin());

create policy "scheme_bookmarks_manage_own" on scheme_bookmarks for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
