create extension if not exists pgcrypto;

create table if not exists inventory (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references player(id) on delete cascade,
  item_code text not null,
  item_type text not null default '',
  quantity numeric not null default 0,
  locked_quantity numeric not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (player_id, item_code, item_type)
);

create index if not exists idx_inventory_player_id on inventory(player_id);
create index if not exists idx_inventory_item_code on inventory(item_code);
