create extension if not exists pgcrypto;

create table if not exists today (
  id uuid primary key default gen_random_uuid(),
  world_id uuid not null references world(id) on delete cascade,
  story_json jsonb not null default '{}'::jsonb,
  mood_json jsonb not null default '{}'::jsonb,
  news_json jsonb not null default '{}'::jsonb,
  recommendation_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_today_world_id on today(world_id);
