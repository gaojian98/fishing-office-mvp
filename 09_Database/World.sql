create extension if not exists pgcrypto;

create table if not exists world (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  state text not null default '',
  clock_json jsonb not null default '{}'::jsonb,
  news_json jsonb not null default '{}'::jsonb,
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_world_code on world(code);
