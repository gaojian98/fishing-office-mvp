create extension if not exists pgcrypto;

create table if not exists wallet (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references player(id) on delete cascade,
  unit_code text not null default 'moyu_coin',
  currency_code text not null default 'MYB',
  balance numeric not null default 0,
  frozen numeric not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (player_id, unit_code, currency_code)
);

create index if not exists idx_wallet_player_id on wallet(player_id);
create index if not exists idx_wallet_unit_code on wallet(unit_code);
