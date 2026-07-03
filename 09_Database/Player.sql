create extension if not exists pgcrypto;

create table if not exists player (
  id uuid primary key default gen_random_uuid(),
  username text not null unique,
  password_hash text not null,
  display_name text not null default '',
  phone text not null default '',
  telegram_id text unique,
  telegram_username text not null default '',
  referral_code text not null unique,
  referred_by uuid references player(id) on delete set null,
  role text not null default 'player',
  status text not null default 'active',
  admin_status text not null default 'approved',
  admin_permissions jsonb not null default '[]'::jsonb,
  staff_name text not null default '',
  staff_reason text not null default '',
  user_no bigint unique,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_player_referral_code on player(referral_code);
create index if not exists idx_player_referred_by on player(referred_by);
create index if not exists idx_player_telegram_id on player(telegram_id);
