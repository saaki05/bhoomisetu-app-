-- ============================================================================
-- 0006_chat.sql
-- Direct (1:1) conversations between any two users — buyer/farmer today,
-- expert consultations later reuse the same shape.
-- ============================================================================

create type message_type as enum ('text', 'image', 'document');

create table conversations (
  id uuid primary key default gen_random_uuid(),
  participant_one_id uuid not null references profiles (id) on delete cascade,
  participant_two_id uuid not null references profiles (id) on delete cascade,
  listing_id uuid references crop_listings (id) on delete set null,
  last_message_preview text,
  last_message_at timestamptz,
  created_at timestamptz not null default now(),
  constraint chk_distinct_participants check (participant_one_id <> participant_two_id),
  constraint uq_conversation_pair unique (participant_one_id, participant_two_id, listing_id)
);

create index idx_conversations_participant_one on conversations (participant_one_id, last_message_at desc);
create index idx_conversations_participant_two on conversations (participant_two_id, last_message_at desc);

create table messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references conversations (id) on delete cascade,
  sender_id uuid not null references profiles (id) on delete cascade,
  type message_type not null default 'text',
  content text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index idx_messages_conversation on messages (conversation_id, created_at);

create or replace function touch_conversation_on_message()
returns trigger
language plpgsql
as $$
begin
  update conversations
  set
    last_message_at = new.created_at,
    last_message_preview = case
      when new.type = 'text' then left(new.content, 140)
      else initcap(new.type::text) || ' attachment'
    end
  where id = new.conversation_id;
  return new;
end;
$$;

create trigger trg_messages_touch_conversation
  after insert on messages
  for each row execute function touch_conversation_on_message();

-- ----------------------------------------------------------------------------
-- Row Level Security
-- ----------------------------------------------------------------------------
alter table conversations enable row level security;
alter table messages enable row level security;

create policy "conversations_participants_read" on conversations
  for select using (participant_one_id = auth.uid() or participant_two_id = auth.uid());
create policy "conversations_participants_create" on conversations
  for insert with check (participant_one_id = auth.uid() or participant_two_id = auth.uid());

create policy "messages_participants_read" on messages
  for select using (
    exists (
      select 1 from conversations c
      where c.id = conversation_id and (c.participant_one_id = auth.uid() or c.participant_two_id = auth.uid())
    )
  );
create policy "messages_participants_send" on messages
  for insert with check (
    sender_id = auth.uid()
    and exists (
      select 1 from conversations c
      where c.id = conversation_id and (c.participant_one_id = auth.uid() or c.participant_two_id = auth.uid())
    )
  );
