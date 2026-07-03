create extension if not exists pgcrypto;

create table if not exists platform (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  title text not null,
  description text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists game (
  id uuid primary key default gen_random_uuid(),
  platform_id uuid not null references platform(id) on delete cascade,
  code text not null unique,
  name text not null,
  category text not null default '',
  status text not null default 'draft',
  route_path text not null default '',
  guide_path text not null default '',
  description text not null default '',
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists value_unit (
  id uuid primary key default gen_random_uuid(),
  platform_id uuid not null references platform(id) on delete cascade,
  code text not null unique,
  name text not null,
  codes text[] not null default '{}'::text[],
  scope text not null default '',
  description text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists user_account (
  id uuid primary key default gen_random_uuid(),
  platform_id uuid not null references platform(id) on delete cascade,
  username text not null unique,
  password_hash text not null,
  role text not null default 'player',
  referral_code text not null unique,
  referred_by uuid references user_account(id),
  user_no bigint unique,
  display_name text not null default '',
  phone text not null default '',
  telegram_id text unique,
  telegram_username text not null default '',
  admin_status text not null default 'approved',
  admin_permissions jsonb not null default '[]'::jsonb,
  staff_name text not null default '',
  staff_reason text not null default '',
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_login_at timestamptz
);

create table if not exists session_token (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references user_account(id) on delete cascade,
  token text not null unique,
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists wallet_account (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references user_account(id) on delete cascade,
  value_unit_id uuid not null references value_unit(id),
  balance numeric not null default 0,
  frozen numeric not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, value_unit_id)
);

create table if not exists wallet_transaction (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references user_account(id) on delete cascade,
  value_unit_id uuid not null references value_unit(id),
  tx_type text not null,
  amount numeric not null,
  balance_before numeric not null,
  balance_after numeric not null,
  game_id uuid references game(id),
  resource_id uuid,
  ref_type text not null default '',
  ref_id uuid,
  note text not null default '',
  meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists inventory_category (
  id uuid primary key default gen_random_uuid(),
  platform_id uuid not null references platform(id) on delete cascade,
  code text not null unique,
  name text not null,
  category_type text not null default '',
  description text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists resource_catalog (
  id uuid primary key default gen_random_uuid(),
  platform_id uuid not null references platform(id) on delete cascade,
  game_id uuid references game(id),
  category_id uuid references inventory_category(id),
  code text not null unique,
  name text not null,
  rarity text not null default '',
  asset_key text not null default '',
  sellable boolean not null default true,
  keepable boolean not null default true,
  companionable boolean not null default false,
  baitable boolean not null default false,
  description text not null default '',
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists inventory_item (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references user_account(id) on delete cascade,
  resource_id uuid not null references resource_catalog(id),
  quantity numeric not null default 0,
  locked_quantity numeric not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, resource_id)
);

create table if not exists game_session (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references user_account(id) on delete cascade,
  game_id uuid not null references game(id) on delete cascade,
  status text not null default 'active',
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists game_event (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references game(id) on delete cascade,
  session_id uuid references game_session(id) on delete cascade,
  event_type text not null,
  payload jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists fish_species (
  id uuid primary key default gen_random_uuid(),
  platform_id uuid not null references platform(id) on delete cascade,
  game_id uuid references game(id),
  code text not null unique,
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

create table if not exists relationship_profile (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references user_account(id) on delete cascade,
  target_id uuid references user_account(id) on delete cascade,
  relationship_type text not null default '',
  relationship_level text not null default 'Stranger',
  relationship_score integer not null default 0,
  emotion_state text not null default '',
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, target_id, relationship_type)
);

create table if not exists relationship_memory (
  id uuid primary key default gen_random_uuid(),
  relationship_profile_id uuid not null references relationship_profile(id) on delete cascade,
  memory_id uuid,
  event_type text not null,
  summary text not null default '',
  intensity integer not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists meaning_record (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references user_account(id) on delete cascade,
  choice_key text not null,
  choice_label text not null default '',
  story_id uuid,
  memory_id uuid,
  identity_key text not null default '',
  legacy_key text not null default '',
  impact jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists story_record (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references user_account(id) on delete cascade,
  meaning_record_id uuid references meaning_record(id) on delete set null,
  title text not null,
  summary text not null default '',
  body text not null default '',
  story_type text not null default '',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists memory_record (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references user_account(id) on delete cascade,
  game_id uuid references game(id),
  memory_type text not null,
  title text not null default '',
  content text not null default '',
  tags text[] not null default '{}'::text[],
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists balance_workbook (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  file_name text not null,
  title text not null,
  version text not null default 'V1.0',
  source_path text not null default '',
  imported_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists balance_sheet (
  id uuid primary key default gen_random_uuid(),
  workbook_id uuid not null references balance_workbook(id) on delete cascade,
  sheet_name text not null,
  sheet_index integer not null default 0,
  row_count integer not null default 0,
  column_count integer not null default 0,
  headers jsonb not null default '[]'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workbook_id, sheet_name)
);

create table if not exists balance_sheet_row (
  id uuid primary key default gen_random_uuid(),
  sheet_id uuid not null references balance_sheet(id) on delete cascade,
  row_number integer not null,
  payload jsonb not null default '{}'::jsonb,
  checksum text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (sheet_id, row_number)
);

create table if not exists balance_field_mapping (
  id uuid primary key default gen_random_uuid(),
  workbook_code text not null,
  sheet_name text not null,
  source_field text not null,
  target_domain text not null default '',
  target_table text not null default '',
  target_column text not null default '',
  mapping_status text not null default 'mapped',
  note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists balance_import_job (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references user_account(id) on delete set null,
  workbook_code text not null,
  source_path text not null default '',
  status text not null default 'pending',
  report jsonb not null default '{}'::jsonb,
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_wallet_transaction_user_created_at on wallet_transaction(user_id, created_at desc);
create index if not exists idx_inventory_item_user_resource on inventory_item(user_id, resource_id);
create index if not exists idx_relationship_profile_user on relationship_profile(user_id, target_id);
create index if not exists idx_memory_record_user_type on memory_record(user_id, memory_type);
create index if not exists idx_balance_sheet_workbook on balance_sheet(workbook_id, sheet_index);
create index if not exists idx_balance_sheet_row_sheet on balance_sheet_row(sheet_id, row_number);

