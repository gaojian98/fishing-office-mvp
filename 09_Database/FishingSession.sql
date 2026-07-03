create extension if not exists pgcrypto;

create table if not exists fishing_session (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references player(id) on delete cascade,
  game_code text not null default '',
  status text not null default 'active',
  entry_cost integer not null default 0,
  attempts integer not null default 0,
  casts jsonb not null default '[]'::jsonb,
  counts jsonb not null default '{}'::jsonb,
  recovery integer not null default 0,
  score integer not null default 0,
  balance_before integer not null default 0,
  balance_after integer not null default 0,
  settings_snapshot jsonb not null default '{}'::jsonb,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_fishing_session_player_id on fishing_session(player_id);
create index if not exists idx_fishing_session_game_code on fishing_session(game_code);
create index if not exists idx_fishing_session_status on fishing_session(status);
