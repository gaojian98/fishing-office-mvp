create extension if not exists pgcrypto;

create table if not exists relationship (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references player(id) on delete cascade,
  target_player_id uuid references player(id) on delete cascade,
  companion_id uuid references companion(id) on delete set null,
  relationship_type text not null default '',
  relationship_level text not null default 'Stranger',
  relationship_score integer not null default 0,
  emotion_state text not null default '',
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (player_id, target_player_id, relationship_type)
);

create index if not exists idx_relationship_player_id on relationship(player_id);
create index if not exists idx_relationship_target_player_id on relationship(target_player_id);
create index if not exists idx_relationship_companion_id on relationship(companion_id);
