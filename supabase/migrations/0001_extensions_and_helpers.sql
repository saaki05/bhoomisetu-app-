-- ============================================================================
-- 0001_extensions_and_helpers.sql
-- Extensions, enum types, and reusable trigger functions shared by every
-- other migration (updated_at maintenance, audit logging, soft delete).
-- ============================================================================

create extension if not exists "pgcrypto";   -- gen_random_uuid()
create extension if not exists "pg_trgm";    -- fuzzy/ILIKE search indexes
create extension if not exists "postgis";    -- geo queries for nearby farmers/buyers

-- ----------------------------------------------------------------------------
-- Enum types
-- ----------------------------------------------------------------------------
create type user_role as enum ('farmer', 'buyer', 'expert', 'admin');

create type order_status as enum (
  'pending', 'accepted', 'rejected', 'preparing', 'out_for_delivery',
  'delivered', 'cancelled', 'refunded'
);

create type crop_listing_status as enum ('draft', 'active', 'out_of_stock', 'archived');

create type notification_channel as enum ('push', 'sms', 'email', 'in_app');

-- ----------------------------------------------------------------------------
-- Generic audit log: append-only record of who changed what and when.
-- Populated by the audit_log_trigger() function attached to sensitive tables.
-- ----------------------------------------------------------------------------
create table audit_logs (
  id uuid primary key default gen_random_uuid(),
  table_name text not null,
  record_id uuid not null,
  action text not null check (action in ('INSERT', 'UPDATE', 'DELETE')),
  changed_by uuid,
  old_data jsonb,
  new_data jsonb,
  created_at timestamptz not null default now()
);

create index idx_audit_logs_table_record on audit_logs (table_name, record_id);
create index idx_audit_logs_changed_by on audit_logs (changed_by);

create or replace function audit_log_trigger()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  actor uuid;
begin
  begin
    actor := nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
  exception when others then
    actor := null;
  end;

  if (tg_op = 'DELETE') then
    insert into audit_logs (table_name, record_id, action, changed_by, old_data)
    values (tg_table_name, old.id, tg_op, actor, to_jsonb(old));
    return old;
  elsif (tg_op = 'UPDATE') then
    insert into audit_logs (table_name, record_id, action, changed_by, old_data, new_data)
    values (tg_table_name, new.id, tg_op, actor, to_jsonb(old), to_jsonb(new));
    return new;
  elsif (tg_op = 'INSERT') then
    insert into audit_logs (table_name, record_id, action, changed_by, new_data)
    values (tg_table_name, new.id, tg_op, actor, to_jsonb(new));
    return new;
  end if;
  return null;
end;
$$;

-- ----------------------------------------------------------------------------
-- updated_at maintenance, attached per-table as `before update`.
-- ----------------------------------------------------------------------------
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ----------------------------------------------------------------------------
-- Helper predicates used throughout RLS policies.
-- ----------------------------------------------------------------------------
-- `plpgsql` rather than `sql`: a SQL-language function body is validated
-- against the catalog at CREATE time, which would fail here since
-- `profiles` isn't created until migration 0002. plpgsql only checks
-- syntax at creation and resolves table references at first call.
create or replace function auth_user_role()
returns user_role
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  return (select role from profiles where id = auth.uid());
end;
$$;

create or replace function is_admin()
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  return coalesce((select role = 'admin' from profiles where id = auth.uid()), false);
end;
$$;
