create extension if not exists pgcrypto;

create table if not exists story (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references player(id) on delete cascade,
  meaning_id uuid references meaning(id) on delete set null,
  title text not null,
  summary text not null default '',
  body text not null default '',
  story_type text not null default '',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_story_player_id on story(player_id);
create index if not exists idx_story_meaning_id on story(meaning_id);
create index if not exists idx_story_type on story(story_type);
