create extension if not exists pgcrypto;

create table if not exists weather (
  id uuid primary key default gen_random_uuid(),
  world_id uuid not null references world(id) on delete cascade,
  state text not null default '',
  effect_json jsonb not null default '{}'::jsonb,
  visual_json jsonb not null default '{}'::jsonb,
  dialogue_hint_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_weather_world_id on weather(world_id);
