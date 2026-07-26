-- ============================================================================
-- 0002_profiles_and_farms.sql
-- User profiles (1:1 with Supabase auth.users) and farmer farm records.
-- ============================================================================

create table profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role user_role not null default 'buyer',
  full_name text not null,
  phone text unique,
  email text unique,
  avatar_url text,
  bio text,
  village text,
  district text,
  state text,
  pincode text,
  location geography(point, 4326),
  is_phone_verified boolean not null default false,
  is_email_verified boolean not null default false,
  is_active boolean not null default true,
  avg_rating numeric(3, 2) not null default 0 check (avg_rating between 0 and 5),
  total_reviews integer not null default 0,
  fcm_tokens text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_profiles_role on profiles (role) where deleted_at is null;
create index idx_profiles_location on profiles using gist (location);
create index idx_profiles_district on profiles (district) where deleted_at is null;

create trigger trg_profiles_updated_at
  before update on profiles
  for each row execute function set_updated_at();

create trigger trg_profiles_audit
  after insert or update or delete on profiles
  for each row execute function audit_log_trigger();

-- Auto-create a profile row whenever a Supabase auth user is created,
-- seeded from the signup metadata the client sends (full_name, role, phone).
create or replace function handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, role, full_name, phone, email)
  values (
    new.id,
    coalesce((new.raw_user_meta_data ->> 'role')::user_role, 'buyer'),
    coalesce(new.raw_user_meta_data ->> 'full_name', 'BhoomiSetu User'),
    new.phone,
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger trg_on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_auth_user();

-- ----------------------------------------------------------------------------
-- Farms: a farmer may register multiple farm plots.
-- ----------------------------------------------------------------------------
create table farms (
  id uuid primary key default gen_random_uuid(),
  farmer_id uuid not null references profiles (id) on delete cascade,
  name text not null,
  area_acres numeric(10, 2) check (area_acres > 0),
  soil_type text,
  irrigation_type text,
  village text,
  district text,
  state text,
  pincode text,
  location geography(point, 4326),
  is_organic_certified boolean not null default false,
  organic_certificate_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_farms_farmer_id on farms (farmer_id) where deleted_at is null;
create index idx_farms_location on farms using gist (location);

create trigger trg_farms_updated_at
  before update on farms
  for each row execute function set_updated_at();

create trigger trg_farms_audit
  after insert or update or delete on farms
  for each row execute function audit_log_trigger();

-- ----------------------------------------------------------------------------
-- Row Level Security
-- ----------------------------------------------------------------------------
alter table profiles enable row level security;
alter table farms enable row level security;

create policy "profiles_select_all_active"
  on profiles for select
  using (deleted_at is null);

create policy "profiles_update_own"
  on profiles for update
  using (id = auth.uid())
  with check (id = auth.uid());

create policy "profiles_admin_full_access"
  on profiles for all
  using (is_admin())
  with check (is_admin());

create policy "farms_select_active"
  on farms for select
  using (deleted_at is null);

create policy "farms_manage_own"
  on farms for all
  using (farmer_id = auth.uid())
  with check (farmer_id = auth.uid());

create policy "farms_admin_full_access"
  on farms for all
  using (is_admin())
  with check (is_admin());
