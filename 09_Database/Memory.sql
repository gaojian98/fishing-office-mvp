create extension if not exists pgcrypto;

create table if not exists memory (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references player(id) on delete cascade,
  game_code text not null default '',
  memory_type text not null,
  title text not null default '',
  content text not null default '',
  tags text[] not null default '{}'::text[],
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_memory_player_id on memory(player_id);
create index if not exists idx_memory_game_code on memory(game_code);
create index if not exists idx_memory_type on memory(memory_type);
