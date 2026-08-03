-- Public read media buckets. Uploads are performed only by the trusted API
-- using the Supabase service key; the policies expose images for app/web use.
insert into storage.buckets (id, name, public)
values
  ('crop-listing-images', 'crop-listing-images', true),
  ('profile-images', 'profile-images', true)
on conflict (id) do update set public = excluded.public;

create policy "public_read_crop_listing_images"
  on storage.objects for select
  using (bucket_id = 'crop-listing-images');

create policy "public_read_profile_images"
  on storage.objects for select
  using (bucket_id = 'profile-images');
