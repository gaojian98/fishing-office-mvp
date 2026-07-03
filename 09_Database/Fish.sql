create extension if not exists pgcrypto;

create table if not exists fish (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  game_code text not null default '',
  name_cn text not null,
  name_en text not null default '',
  tier integer not null default 1,
  bait_required text not null default '',
  wait_min_seconds integer not null default 0,
  wait_max_seconds integer not null default 0,
  base_coin integer not null default 0,
  points integer not null default 0,
  ai_potential text not null default '',
  can_sell boolean not null default true,
  can_keep boolean not null default true,
  can_become_companion boolean not null default false,
  notes text not null default '',
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_fish_game_code on fish(game_code);
create index if not exists idx_fish_tier on fish(tier);
