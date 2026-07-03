create extension if not exists pgcrypto;

create table if not exists companion (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references player(id) on delete cascade,
  fish_id uuid references fish(id) on delete set null,
  name text not null default '',
  level integer not null default 0,
  status text not null default '',
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_companion_player_id on companion(player_id);
create index if not exists idx_companion_fish_id on companion(fish_id);
