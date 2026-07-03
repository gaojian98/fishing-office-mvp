create extension if not exists pgcrypto;

create table if not exists meaning (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references player(id) on delete cascade,
  choice_key text not null,
  choice_label text not null default '',
  story_id uuid,
  memory_id uuid,
  identity_key text not null default '',
  legacy_key text not null default '',
  impact jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_meaning_player_id on meaning(player_id);
create index if not exists idx_meaning_choice_key on meaning(choice_key);
