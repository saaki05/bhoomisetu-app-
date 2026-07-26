-- ============================================================================
-- 0007_role_selection.sql
-- Distinguishes "user explicitly chose an account type" from "we defaulted
-- them to buyer". Google/OTP signup carries no role, so without this flag a
-- new user silently lands as a buyer with no way to say they're a farmer.
-- The app gates entry to the main shell on this being true.
-- ============================================================================

alter table profiles
  add column if not exists role_selected boolean not null default false;

-- Existing rows predate the role picker. Anyone who already has a non-buyer
-- role must have chosen it explicitly (only email signup could set that),
-- so preserve their choice rather than re-prompting them.
update profiles set role_selected = true where role <> 'buyer';

-- The auth trigger seeds new rows from signup metadata; mark the role as
-- explicitly chosen only when the client actually supplied one (email
-- registration does; Google/OTP do not).
create or replace function handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, role, full_name, phone, email, role_selected)
  values (
    new.id,
    coalesce((new.raw_user_meta_data ->> 'role')::user_role, 'buyer'),
    coalesce(new.raw_user_meta_data ->> 'full_name', 'BhoomiSetu User'),
    new.phone,
    new.email,
    (new.raw_user_meta_data ->> 'role') is not null
  )
  on conflict (id) do nothing;
  return new;
end;
$$;
