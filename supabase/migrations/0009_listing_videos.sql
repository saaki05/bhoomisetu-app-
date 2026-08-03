-- One optional product demonstration video per crop listing.
create table crop_listing_videos (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null unique references crop_listings (id) on delete cascade,
  video_url text not null,
  created_at timestamptz not null default now()
);

create index idx_listing_videos_listing on crop_listing_videos (listing_id);

alter table crop_listing_videos enable row level security;

create policy "listing_videos_public_read" on crop_listing_videos for select using (true);
create policy "listing_videos_manage_via_listing" on crop_listing_videos for all
  using (exists (select 1 from crop_listings l where l.id = listing_id and l.farmer_id = auth.uid()))
  with check (exists (select 1 from crop_listings l where l.id = listing_id and l.farmer_id = auth.uid()));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('crop-listing-videos', 'crop-listing-videos', true, 52428800,
  array['video/mp4', 'video/webm', 'video/quicktime'])
on conflict (id) do update set public = excluded.public;

create policy "listing_videos_storage_public_read" on storage.objects for select
  using (bucket_id = 'crop-listing-videos');
create policy "listing_videos_storage_farmer_write" on storage.objects for insert to authenticated
  with check (bucket_id = 'crop-listing-videos' and (storage.foldername(name))[1] = auth.uid()::text);
