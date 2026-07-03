create extension if not exists pgcrypto;

create table if not exists wallet_transaction (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references player(id) on delete cascade,
  wallet_id uuid references wallet(id) on delete set null,
  game_code text not null default '',
  tx_type text not null,
  unit_code text not null default 'moyu_coin',
  currency_code text not null default 'MYB',
  amount numeric not null,
  balance_before numeric not null,
  balance_after numeric not null,
  ref_type text not null default '',
  ref_id uuid,
  note text not null default '',
  meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_wallet_transaction_player_id on wallet_transaction(player_id);
create index if not exists idx_wallet_transaction_wallet_id on wallet_transaction(wallet_id);
create index if not exists idx_wallet_transaction_game_code on wallet_transaction(game_code);
create index if not exists idx_wallet_transaction_created_at on wallet_transaction(created_at desc);
