create table if not exists public.sync_entities (
  user_id uuid not null,
  entity_type text not null,
  entity_id text not null,
  payload jsonb,
  is_deleted boolean not null default false,
  last_modified_at timestamptz not null,
  last_modified_by_device_id text not null,
  primary key (user_id, entity_type, entity_id)
);

alter table public.sync_entities enable row level security;

create policy "users manage their own sync rows"
on public.sync_entities
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

