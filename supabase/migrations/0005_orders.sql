-- ============================================================================
-- 0005_orders.sql
-- An order is a buyer purchasing a quantity from a single crop listing.
-- Status changes are recorded in order_status_history so both parties can
-- see a full timeline (Track Orders).
-- ============================================================================

create table orders (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references profiles (id) on delete restrict,
  farmer_id uuid not null references profiles (id) on delete restrict,
  listing_id uuid not null references crop_listings (id) on delete restrict,
  quantity numeric(10, 2) not null check (quantity > 0),
  unit_price numeric(10, 2) not null check (unit_price > 0),
  unit text not null,
  total_price numeric(10, 2) not null check (total_price > 0),
  status order_status not null default 'pending',
  delivery_address text,
  delivery_district text,
  delivery_state text,
  delivery_pincode text,
  contact_phone text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_orders_buyer on orders (buyer_id);
create index idx_orders_farmer on orders (farmer_id);
create index idx_orders_listing on orders (listing_id);
create index idx_orders_status on orders (status);
create index idx_orders_created_at on orders (created_at desc);

create trigger trg_orders_updated_at
  before update on orders
  for each row execute function set_updated_at();

create trigger trg_orders_audit
  after insert or update or delete on orders
  for each row execute function audit_log_trigger();

create table order_status_history (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders (id) on delete cascade,
  status order_status not null,
  changed_by uuid references profiles (id) on delete set null,
  note text,
  created_at timestamptz not null default now()
);

create index idx_order_status_history_order on order_status_history (order_id, created_at);

-- ----------------------------------------------------------------------------
-- Reviews: a buyer may review a farmer once an order is delivered.
-- ----------------------------------------------------------------------------
create table reviews (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null unique references orders (id) on delete cascade,
  reviewer_id uuid not null references profiles (id) on delete cascade,
  reviewee_id uuid not null references profiles (id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now()
);

create index idx_reviews_reviewee on reviews (reviewee_id);

-- Keeps profiles.avg_rating / total_reviews in sync whenever a review is added.
create or replace function refresh_reviewee_rating()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update profiles
  set
    total_reviews = (select count(*) from reviews where reviewee_id = new.reviewee_id),
    avg_rating = (select round(avg(rating)::numeric, 2) from reviews where reviewee_id = new.reviewee_id)
  where id = new.reviewee_id;
  return new;
end;
$$;

create trigger trg_reviews_refresh_rating
  after insert on reviews
  for each row execute function refresh_reviewee_rating();

-- ----------------------------------------------------------------------------
-- Row Level Security
-- ----------------------------------------------------------------------------
alter table orders enable row level security;
alter table order_status_history enable row level security;
alter table reviews enable row level security;

create policy "orders_read_own" on orders
  for select using (buyer_id = auth.uid() or farmer_id = auth.uid());
create policy "orders_buyer_create" on orders
  for insert with check (buyer_id = auth.uid());
create policy "orders_parties_update" on orders
  for update using (buyer_id = auth.uid() or farmer_id = auth.uid());
create policy "orders_admin_full_access" on orders
  for all using (is_admin()) with check (is_admin());

create policy "order_status_history_read_own" on order_status_history
  for select using (
    exists (select 1 from orders o where o.id = order_id and (o.buyer_id = auth.uid() or o.farmer_id = auth.uid()))
  );

create policy "reviews_public_read" on reviews for select using (true);
create policy "reviews_reviewer_create" on reviews for insert with check (reviewer_id = auth.uid());
