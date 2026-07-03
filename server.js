import http from "node:http";
import { readFile, writeFile, mkdir } from "node:fs/promises";
import { existsSync, createReadStream, readFileSync } from "node:fs";
import { extname, join, normalize } from "node:path";
import { randomBytes, pbkdf2Sync, timingSafeEqual } from "node:crypto";
import { fileURLToPath } from "node:url";

const __dirname = fileURLToPath(new URL(".", import.meta.url));
const publicDir = join(__dirname, "public");
const flutterWebDir = join(__dirname, "fishing_office_flutter", "build", "web");
const dataFile = join(__dirname, "data.json");
loadDotEnv();

const PORT = Number(process.env.PORT || 3000);
const DATABASE_URL = process.env.DATABASE_URL || "";
const ADMIN_USERNAME = process.env.ADMIN_USERNAME || "admin";
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || "admin123456";
const RESET_ADMIN_PASSWORD = process.env.RESET_ADMIN_PASSWORD || "";
const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN || "";
const TELEGRAM_BOT_USERNAME = process.env.TELEGRAM_BOT_USERNAME || "";
const APP_URL = (process.env.APP_URL || `http://localhost:${PORT}`).replace(/\/$/, "");
const REFERRAL_REWARD = Number(process.env.REFERRAL_REWARD || 0);

function loadDotEnv() {
  const envPath = join(__dirname, ".env");
  if (!existsSync(envPath)) return;
  const lines = readFileSync(envPath, "utf8").split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const index = trimmed.indexOf("=");
    if (index < 1) continue;
    const key = trimmed.slice(0, index).trim();
    const value = trimmed.slice(index + 1).trim().replace(/^["']|["']$/g, "");
    if (!process.env[key]) process.env[key] = value;
  }
}

let pool = null;
if (DATABASE_URL) {
  const pg = await import("pg");
  const { Pool } = pg.default || pg;
  pool = new Pool({ connectionString: DATABASE_URL, ssl: process.env.PGSSLMODE === "disable" ? false : { rejectUnauthorized: false } });
}

const fishTypes = ["yellow", "grouper", "eel"];
const fishLabels = { yellow: "黄鱼", grouper: "石斑鱼", eel: "鳗鱼" };
const payouts = {
  "840": 100,
  "750": 20,
  "660": 20,
  "831": 20,
  "822": 20,
  "741": 20,
  "732": 20,
  "651": 20,
  "642": 1,
  "633": 1,
  "552": 1,
  "444": 1,
  "543": -10
};
const defaultPaymentChannels = [
  { id: "bank", name: "银行卡", account_name: "", account_no: "", network: "", instructions: "", supports_recharge: true, supports_withdraw: true, enabled: true, sort_order: 1 },
  { id: "cold_wallet", name: "冷钱包", account_name: "USDT", account_no: "", network: "TRC20", instructions: "请确认网络一致后再转账。", supports_recharge: true, supports_withdraw: true, enabled: true, sort_order: 2 },
  { id: "zalopay", name: "ZaloPay", account_name: "", account_no: "", network: "", instructions: "", supports_recharge: true, supports_withdraw: true, enabled: true, sort_order: 3 }
];
const defaultFinanceSettings = { point_vnd_rate: 1000, usdt_vnd_rate: 25000 };
const defaultMarketingSettings = {
  referral: {
    enabled: true,
    tiers: [
      { effective_members: 1, reward_points: 0, enabled: true },
      { effective_members: 3, reward_points: 0, enabled: true },
      { effective_members: 5, reward_points: 0, enabled: true }
    ]
  },
  checkin: { enabled: true, consecutive_days: 7, reward_points: 0 },
  recharge: {
    enabled: true,
    tiers: [
      { recharge_points: 100, reward_points: 0, enabled: true },
      { recharge_points: 300, reward_points: 0, enabled: true },
      { recharge_points: 500, reward_points: 0, enabled: true },
      { recharge_points: 1000, reward_points: 0, enabled: true },
      { recharge_points: 3000, reward_points: 0, enabled: true }
    ]
  }
};
const fishingOutcomeIds = ["grouper", "yellow", "eel", "empty"];
const fishingLabels = { grouper: "石斑鱼", yellow: "黄鱼", eel: "鳗鱼", empty: "空竿" };
const defaultFishingSettings = {
  enabled: true,
  entry_cost: 20,
  attempts: 5,
  outcomes: [
    { id: "grouper", name: "石斑鱼", probability: 10, price: 20 },
    { id: "yellow", name: "黄鱼", probability: 40, price: 3 },
    { id: "eel", name: "鳗鱼", probability: 30, price: 1 },
    { id: "empty", name: "空竿", probability: 20, price: 0 }
  ]
};
const defaultPlatformConfig = {
  platform: {
    id: "moyu",
    name: "摸鱼",
    title: "摸鱼游戏平台",
    description: "多款轻量小游戏共用账号、钱包、资源、积分和运营后台。"
  },
  valueUnits: [
    { id: "cash", name: "现金", codes: ["USDT", "VND"], scope: "external", description: "平台外部结算资金，用于充值、提现和财务对账。" },
    { id: "moyu_coin", name: "摸鱼币", codes: ["MYB"], scope: "platform_wallet", description: "与现金兑换的平台开户币，现有 users.balance 兼容为摸鱼币余额。" },
    { id: "game_resource", name: "游戏资源", codes: ["RESOURCE"], scope: "game_inventory", description: "鱼饵、渔具、鱼获、道具等跨游戏资源资产。" },
    { id: "game_point", name: "游戏积分", codes: ["POINT"], scope: "game_score", description: "等级、榜单、成就和局内成长分数，不直接等同现金。" }
  ],
  games: [
    { id: "tank", name: "稻田摸鱼", unit: "game_point", walletUnit: "moyu_coin" },
    { id: "fishing", name: "湖畔钓鱼", unit: "game_point", walletUnit: "moyu_coin" },
    { id: "office_fishing", name: "上班摸鱼", unit: "game_resource", walletUnit: "moyu_coin" }
  ]
};
const gameCatalog = [
  {
    id: "tank",
    name: "稻田摸鱼",
    category: "draw",
    status: "online",
    entry: "/",
    guide: "/guide.html",
    adminTabs: ["rounds", "odds", "fish-config", "result-stats"],
    walletMode: "moyu_coin",
    description: "24 个鱼缸随机开 12 个，按三种鱼数量组合结算游戏积分。"
  },
  {
    id: "fishing",
    name: "湖畔钓鱼",
    category: "cast",
    status: "online",
    entry: "/fishing.html",
    guide: "/fishing-guide.html",
    adminTabs: ["fishing-config", "fishing-rounds"],
    walletMode: "moyu_coin",
    description: "每局扣入场摸鱼币，多次抛竿后按鱼获回收摸鱼币。"
  },
  {
    id: "office_fishing",
    name: "上班摸鱼",
    category: "casual",
    status: "prototype",
    entry: "/fishing-office.html",
    guide: "/fishing-office.html",
    adminTabs: ["catalog", "integration"],
    walletMode: "moyu_coin",
    description: "面向年轻上班族的轻量钓鱼原型，后续接入统一摸鱼币、资源和积分。"
  }
];
const defaultMessageTemplates = [
  { id: "tpl_welcome", title: "欢迎语", body: "🐟 欢迎来到摸鱼！\n\n点击机器人菜单进入游戏、查看钱包、邀请好友。", button_text: "进入游戏", button_url: APP_URL },
  { id: "tpl_guide", title: "玩法说明", body: "📖 玩法说明\n\n每局 24 个密封鱼缸，黄鱼、石斑鱼、鳗鱼各 8 条。每局摸 12 次，按三种鱼数量组合结算积分。", button_text: "开始摸鱼", button_url: APP_URL },
  { id: "tpl_promo", title: "优惠活动", body: "🎁 优惠活动已开启！\n\n推荐好友、连续签到、单笔充值都有机会获得额外积分奖励。具体以机器人优惠活动菜单为准。", button_text: "查看活动", button_url: APP_URL },
  { id: "tpl_recharge", title: "充值提醒", body: "💰 充值提醒\n\n提交充值后请填写转账说明或凭证，客服审核通过后积分自动到账。", button_text: "打开钱包", button_url: `${APP_URL}/wallet.html` }
];
const staffRoleLabels = {
  admin: "超级管理员",
  customer_service: "客服",
  finance: "财务",
  risk: "风控",
  operations: "运营"
};
const moduleIds = ["dashboard", "members", "funds", "games", "marketing", "referrals", "bot", "risk", "settings"];
const defaultStaffPermissions = {
  admin: moduleIds,
  customer_service: ["dashboard", "members", "funds", "bot"],
  finance: ["dashboard", "funds", "members"],
  risk: ["dashboard", "members", "games", "risk"],
  operations: ["dashboard", "games", "marketing", "referrals", "bot"]
};

let memory = null;

function now() {
  return new Date().toISOString();
}

function cloneJson(value) {
  return JSON.parse(JSON.stringify(value));
}

function id(prefix) {
  return `${prefix}_${randomBytes(10).toString("hex")}`;
}

function hashPassword(password) {
  const salt = randomBytes(16).toString("hex");
  const hash = pbkdf2Sync(password, salt, 120000, 32, "sha256").toString("hex");
  return `${salt}:${hash}`;
}

function verifyPassword(password, stored) {
  const [salt, hash] = String(stored || "").split(":");
  if (!salt || !hash) return false;
  const test = pbkdf2Sync(password, salt, 120000, 32, "sha256");
  const saved = Buffer.from(hash, "hex");
  return saved.length === test.length && timingSafeEqual(saved, test);
}

function publicUser(user) {
  return {
    id: user.id,
    systemId: user.user_no || String(user.id || "").slice(-6).toUpperCase(),
    username: user.username,
    displayName: user.display_name || user.username,
    role: user.role,
    roleLabel: staffRoleLabels[user.role] || "会员",
    adminStatus: user.admin_status || (user.role === "player" ? "" : "approved"),
    adminPermissions: normalizePermissions(user.admin_permissions, user.role),
    referralCode: user.referral_code,
    referredBy: user.referred_by,
    balance: user.balance,
    frozen: user.frozen,
    phone: user.phone || "",
    staffName: user.staff_name || "",
    staffReason: user.staff_reason || "",
    telegramId: user.telegram_id,
    createdAt: user.created_at
  };
}

function normalizePermissions(value, role = "player") {
  if (role === "player") return [];
  let source = value;
  if (typeof source === "string") {
    try { source = JSON.parse(source); } catch { source = source.split(","); }
  }
  if (!Array.isArray(source) || !source.length) source = defaultStaffPermissions[role] || [];
  const allowed = new Set(moduleIds);
  return [...new Set(source.filter((item) => allowed.has(item)))];
}

function isStaffRole(role) {
  return role && role !== "player";
}

async function loadMemory() {
  if (memory) return memory;
  if (existsSync(dataFile)) {
    memory = JSON.parse(await readFile(dataFile, "utf8"));
  } else {
    memory = { users: [], sessions: [], rounds: [], fishingRounds: [], transactions: [], recharges: [], withdrawals: [], paymentChannels: [], financeSettings: null, marketingSettings: null, fishingSettings: null, platformSettings: null, valueLedger: [], botGroups: [], messageTemplates: [], botSendLogs: [], operationLogs: [] };
  }
  if (!memory.fishingRounds) memory.fishingRounds = [];
  if (!memory.paymentChannels) memory.paymentChannels = [];
  if (!memory.botGroups) memory.botGroups = [];
  if (!memory.messageTemplates) memory.messageTemplates = [];
  if (!memory.botSendLogs) memory.botSendLogs = [];
  if (!memory.operationLogs) memory.operationLogs = [];
  if (!memory.valueLedger) memory.valueLedger = [];
  if (!memory.platformSettings) memory.platformSettings = { ...cloneJson(defaultPlatformConfig), updated_at: now() };
  if (!memory.financeSettings) memory.financeSettings = { ...defaultFinanceSettings, updated_at: now() };
  if (!memory.marketingSettings) memory.marketingSettings = { ...defaultMarketingSettings, updated_at: now() };
  if (!memory.fishingSettings) memory.fishingSettings = { ...cloneJson(defaultFishingSettings), updated_at: now() };
  return memory;
}

async function saveMemory() {
  if (!memory) return;
  await writeFile(dataFile, JSON.stringify(memory, null, 2));
}

async function initDb() {
  if (pool) {
    await pool.query(`
      create table if not exists users (
        id text primary key,
        username text unique not null,
        password_hash text not null,
        role text not null default 'player',
        referral_code text unique not null,
        referred_by text,
        user_no integer unique,
        balance integer not null default 0,
        frozen integer not null default 0,
        phone text,
        telegram_id text unique,
        telegram_username text,
        display_name text not null default '',
        admin_status text not null default 'approved',
        admin_permissions jsonb not null default '[]'::jsonb,
        staff_name text not null default '',
        staff_reason text not null default '',
        status text not null default 'active',
        created_at timestamptz not null,
        last_login_at timestamptz
      );
      create table if not exists sessions (
        token text primary key,
        user_id text not null references users(id),
        created_at timestamptz not null,
        expires_at timestamptz not null
      );
      create table if not exists rounds (
        id text primary key,
        user_id text not null references users(id),
        deck jsonb not null,
        opened jsonb not null,
        counts jsonb not null,
        status text not null,
        combo text,
        score integer,
        balance_before integer,
        balance_after integer,
        created_at timestamptz not null,
        ended_at timestamptz
      );
      create table if not exists fishing_settings (
        id text primary key,
        config jsonb not null,
        updated_at timestamptz not null,
        updated_by text
      );
      create table if not exists fishing_rounds (
        id text primary key,
        user_id text not null references users(id),
        entry_cost integer not null,
        attempts integer not null,
        casts jsonb not null,
        counts jsonb not null,
        recovery integer not null default 0,
        score integer,
        balance_before integer,
        balance_after integer,
        status text not null,
        settings_snapshot jsonb not null,
        created_at timestamptz not null,
        ended_at timestamptz
      );
      create table if not exists wallet_transactions (
        id text primary key,
        user_id text not null references users(id),
        type text not null,
        amount integer not null,
        balance_before integer not null,
        balance_after integer not null,
        unit_type text not null default 'moyu_coin',
        currency text not null default 'MYB',
        game_id text not null default '',
        meta jsonb not null default '{}'::jsonb,
        ref_id text,
        note text,
        created_at timestamptz not null
      );
      create table if not exists recharge_orders (
        id text primary key,
        user_id text not null references users(id),
        amount integer not null,
        channel text,
        status text not null,
        proof text,
        note text,
        created_at timestamptz not null,
        reviewed_at timestamptz,
        reviewed_by text
      );
      create table if not exists withdraw_orders (
        id text primary key,
        user_id text not null references users(id),
        amount integer not null,
        account text not null,
        method text,
        status text not null,
        note text,
        created_at timestamptz not null,
        reviewed_at timestamptz,
        reviewed_by text
      );
      create table if not exists platform_settings (
        id text primary key,
        config jsonb not null,
        updated_at timestamptz not null,
        updated_by text
      );
      create table if not exists value_ledger (
        id text primary key,
        user_id text references users(id),
        unit_type text not null,
        currency text not null default '',
        game_id text not null default '',
        resource_id text not null default '',
        amount numeric not null,
        balance_before numeric,
        balance_after numeric,
        ref_type text not null default '',
        ref_id text,
        note text,
        meta jsonb not null default '{}'::jsonb,
        created_at timestamptz not null
      );
      create table if not exists operation_logs (
        id text primary key,
        admin_id text,
        action text not null,
        detail jsonb not null,
        created_at timestamptz not null
      );
      create table if not exists payment_channels (
        id text primary key,
        name text not null,
        supports_recharge boolean not null default true,
        supports_withdraw boolean not null default true,
        enabled boolean not null default true,
        sort_order integer not null default 100,
        account_name text not null default '',
        account_no text not null default '',
        network text not null default '',
        instructions text not null default '',
        updated_at timestamptz not null
      );
      create table if not exists finance_settings (
        id text primary key,
        point_vnd_rate integer not null default 1000,
        usdt_vnd_rate integer not null default 25000,
        updated_at timestamptz not null,
        updated_by text
      );
      create table if not exists marketing_settings (
        id text primary key,
        config jsonb not null,
        updated_at timestamptz not null,
        updated_by text
      );
      create table if not exists bot_groups (
        id text primary key,
        name text not null,
        chat_id text not null,
        enabled boolean not null default true,
        created_at timestamptz not null,
        updated_at timestamptz not null
      );
      create table if not exists message_templates (
        id text primary key,
        title text not null,
        body text not null,
        image_url text not null default '',
        video_url text not null default '',
        button_text text not null default '',
        button_url text not null default '',
        enabled boolean not null default true,
        created_at timestamptz not null,
        updated_at timestamptz not null
      );
      create table if not exists bot_send_logs (
        id text primary key,
        target_type text not null,
        target_count integer not null,
        template_id text,
        text text not null,
        sent integer not null,
        failed integer not null,
        detail jsonb not null,
        admin_id text,
        created_at timestamptz not null
      );
      alter table users add column if not exists telegram_id text unique;
      alter table users add column if not exists telegram_username text;
      alter table users add column if not exists user_no integer unique;
      alter table users add column if not exists phone text;
      alter table users add column if not exists display_name text not null default '';
      alter table users add column if not exists admin_status text not null default 'approved';
      alter table users add column if not exists admin_permissions jsonb not null default '[]'::jsonb;
      alter table users add column if not exists staff_name text not null default '';
      alter table users add column if not exists staff_reason text not null default '';
      alter table wallet_transactions add column if not exists unit_type text not null default 'moyu_coin';
      alter table wallet_transactions add column if not exists currency text not null default 'MYB';
      alter table wallet_transactions add column if not exists game_id text not null default '';
      alter table wallet_transactions add column if not exists meta jsonb not null default '{}'::jsonb;
      alter table recharge_orders add column if not exists channel text;
      alter table recharge_orders add column if not exists review_note text not null default '';
      alter table recharge_orders add column if not exists cash_currency text not null default '';
      alter table recharge_orders add column if not exists cash_amount numeric;
      alter table recharge_orders add column if not exists coin_amount integer;
      alter table recharge_orders add column if not exists exchange_rate numeric;
      alter table withdraw_orders add column if not exists method text;
      alter table withdraw_orders add column if not exists review_note text not null default '';
      alter table withdraw_orders add column if not exists cash_currency text not null default '';
      alter table withdraw_orders add column if not exists cash_amount numeric;
      alter table withdraw_orders add column if not exists coin_amount integer;
      alter table withdraw_orders add column if not exists exchange_rate numeric;
      alter table payment_channels add column if not exists account_name text not null default '';
      alter table payment_channels add column if not exists account_no text not null default '';
      alter table payment_channels add column if not exists network text not null default '';
      alter table payment_channels add column if not exists instructions text not null default '';
    `);
    for (const channel of defaultPaymentChannels) {
      await pool.query(
        `insert into payment_channels (id,name,supports_recharge,supports_withdraw,enabled,sort_order,account_name,account_no,network,instructions,updated_at)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
         on conflict (id) do nothing`,
        [channel.id, channel.name, channel.supports_recharge, channel.supports_withdraw, channel.enabled, channel.sort_order, channel.account_name, channel.account_no, channel.network, channel.instructions, now()]
      );
    }
    await pool.query(
      "update payment_channels set account_no=name, name='冷钱包', account_name=coalesce(nullif(account_name,''),'USDT'), network=coalesce(nullif(network,''),'TRC20'), instructions=coalesce(nullif(instructions,''),'请确认网络一致后再转账。'), updated_at=$1 where id='cold_wallet' and name <> '冷钱包' and account_no=''",
      [now()]
    );
    await pool.query(
      `insert into finance_settings (id,point_vnd_rate,usdt_vnd_rate,updated_at)
       values ('default',$1,$2,$3)
       on conflict (id) do nothing`,
      [defaultFinanceSettings.point_vnd_rate, defaultFinanceSettings.usdt_vnd_rate, now()]
    );
    await pool.query(
      `insert into marketing_settings (id,config,updated_at)
       values ('default',$1,$2)
       on conflict (id) do nothing`,
      [JSON.stringify(defaultMarketingSettings), now()]
    );
    await pool.query(
      `insert into fishing_settings (id,config,updated_at)
       values ('default',$1,$2)
       on conflict (id) do nothing`,
      [JSON.stringify(defaultFishingSettings), now()]
    );
    await pool.query(
      `insert into platform_settings (id,config,updated_at)
       values ('default',$1,$2)
       on conflict (id) do nothing`,
      [JSON.stringify(defaultPlatformConfig), now()]
    );
    for (const template of defaultMessageTemplates) {
      await pool.query(
        `insert into message_templates (id,title,body,image_url,video_url,button_text,button_url,enabled,created_at,updated_at)
         values ($1,$2,$3,'','',$4,$5,true,$6,$6)
         on conflict (id) do nothing`,
        [template.id, template.title, template.body, template.button_text, template.button_url, now()]
      );
    }
    const exists = await pool.query("select id from users where username=$1", [ADMIN_USERNAME]);
    if (!exists.rowCount) {
      await pool.query(
        "insert into users (id, username, password_hash, role, referral_code, balance, frozen, admin_status, admin_permissions, created_at) values ($1,$2,$3,'admin',$4,0,0,'approved',$5,$6)",
        [id("usr"), ADMIN_USERNAME, hashPassword(ADMIN_PASSWORD), makeReferralCode(), JSON.stringify(defaultStaffPermissions.admin), now()]
      );
    } else {
      await pool.query("update users set admin_status='approved', admin_permissions=$1 where username=$2 and role='admin'", [JSON.stringify(defaultStaffPermissions.admin), ADMIN_USERNAME]);
    }
    if (RESET_ADMIN_PASSWORD) {
      await pool.query(
        "update users set password_hash=$1, role='admin', status='active', admin_status='approved', admin_permissions=$2 where username=$3",
        [hashPassword(RESET_ADMIN_PASSWORD), JSON.stringify(defaultStaffPermissions.admin), ADMIN_USERNAME]
      );
    }
  } else {
    const db = await loadMemory();
    for (const channel of defaultPaymentChannels) {
      if (!db.paymentChannels.some((item) => item.id === channel.id)) {
        db.paymentChannels.push({ ...channel, updated_at: now() });
      }
    }
    const coldWallet = db.paymentChannels.find((item) => item.id === "cold_wallet");
    if (coldWallet && coldWallet.name !== "冷钱包" && !coldWallet.account_no) {
      coldWallet.account_no = coldWallet.name;
      coldWallet.name = "冷钱包";
      coldWallet.account_name = coldWallet.account_name || "USDT";
      coldWallet.network = coldWallet.network || "TRC20";
      coldWallet.instructions = coldWallet.instructions || "请确认网络一致后再转账。";
      coldWallet.updated_at = now();
    }
    if (!db.financeSettings) db.financeSettings = { ...defaultFinanceSettings, updated_at: now() };
    if (!db.marketingSettings) db.marketingSettings = { ...defaultMarketingSettings, updated_at: now() };
    if (!db.fishingSettings) db.fishingSettings = { ...cloneJson(defaultFishingSettings), updated_at: now() };
    if (!db.platformSettings) db.platformSettings = { ...cloneJson(defaultPlatformConfig), updated_at: now() };
    for (const template of defaultMessageTemplates) {
      if (!db.messageTemplates.some((item) => item.id === template.id)) {
        db.messageTemplates.push({ ...template, image_url: "", video_url: "", enabled: true, created_at: now(), updated_at: now() });
      }
    }
    if (!db.users.some((u) => u.username === ADMIN_USERNAME)) {
      db.users.push({
        id: id("usr"),
        username: ADMIN_USERNAME,
        password_hash: hashPassword(ADMIN_PASSWORD),
        role: "admin",
        referral_code: makeReferralCode(),
        referred_by: null,
        user_no: await nextUserNo(),
        balance: 0,
        frozen: 0,
        phone: "",
        display_name: "",
        telegram_id: null,
        telegram_username: null,
        admin_status: "approved",
        admin_permissions: defaultStaffPermissions.admin,
        staff_name: "",
        staff_reason: "",
        status: "active",
        created_at: now(),
        last_login_at: null
      });
    } else {
      const admin = db.users.find((u) => u.username === ADMIN_USERNAME);
      if (admin) {
        admin.admin_status = "approved";
        admin.admin_permissions = defaultStaffPermissions.admin;
        if (RESET_ADMIN_PASSWORD) {
          admin.password_hash = hashPassword(RESET_ADMIN_PASSWORD);
          admin.role = "admin";
          admin.status = "active";
        }
      }
    }
    await saveMemory();
  }
}

function makeReferralCode() {
  return randomBytes(4).toString("hex").toUpperCase();
}

async function findUserByUsername(username) {
  if (pool) {
    const res = await pool.query("select * from users where lower(username)=lower($1)", [username]);
    return res.rows[0] || null;
  }
  const db = await loadMemory();
  return db.users.find((u) => u.username.toLowerCase() === username.toLowerCase()) || null;
}

async function findUserById(userId) {
  if (pool) {
    const res = await pool.query("select * from users where id=$1", [userId]);
    return res.rows[0] || null;
  }
  const db = await loadMemory();
  return db.users.find((u) => u.id === userId) || null;
}

async function findUserByReferral(code) {
  if (!code) return null;
  if (pool) {
    const res = await pool.query("select * from users where referral_code=$1", [code]);
    return res.rows[0] || null;
  }
  const db = await loadMemory();
  return db.users.find((u) => u.referral_code === code) || null;
}

async function findUserByTelegramId(telegramId) {
  if (!telegramId) return null;
  if (pool) {
    const res = await pool.query("select * from users where telegram_id=$1", [String(telegramId)]);
    return res.rows[0] || null;
  }
  const db = await loadMemory();
  return db.users.find((u) => String(u.telegram_id || "") === String(telegramId)) || null;
}

async function nextUserNo() {
  if (pool) {
    const res = await pool.query("select coalesce(max(user_no), 100000) + 1 as next_no from users");
    return Number(res.rows[0].next_no);
  }
  const db = await loadMemory();
  return Math.max(100000, ...db.users.map((u) => Number(u.user_no || 0))) + 1;
}

async function updateUserProfile(userId, { phone, displayName }) {
  const cleanPhone = String(phone || "").trim();
  const cleanDisplayName = String(displayName || "").trim();
  if (cleanPhone && !/^[0-9+\-\s()]{6,24}$/.test(cleanPhone)) throw httpError(400, "手机号码格式不正确");
  if (cleanDisplayName && (cleanDisplayName.length < 2 || cleanDisplayName.length > 18)) throw httpError(400, "账号名称需为 2 到 18 个字符");
  if (pool) {
    await pool.query("update users set phone=$1, display_name=$2 where id=$3", [cleanPhone, cleanDisplayName, userId]);
    return await findUserById(userId);
  }
  const db = await loadMemory();
  const user = db.users.find((u) => u.id === userId);
  if (!user) throw httpError(404, "用户不存在");
  user.phone = cleanPhone;
  user.display_name = cleanDisplayName;
  await saveMemory();
  return user;
}

async function createUser({ username, password, referralCode, telegramId = null, telegramUsername = null }) {
  const existing = await findUserByUsername(username);
  if (existing) throw httpError(409, "用户名已存在");
  const referrer = await findUserByReferral(referralCode);
  const user = {
    id: id("usr"),
    username,
    password_hash: hashPassword(password),
    role: "player",
    referral_code: makeReferralCode(),
    referred_by: referrer?.id || null,
    user_no: await nextUserNo(),
    balance: 0,
    frozen: 0,
    phone: "",
    display_name: "",
    telegram_id: telegramId ? String(telegramId) : null,
    telegram_username: telegramUsername || null,
    status: "active",
    created_at: now(),
    last_login_at: null
  };
  if (pool) {
    await pool.query(
      "insert into users (id, username, password_hash, role, referral_code, referred_by, user_no, balance, frozen, phone, display_name, telegram_id, telegram_username, status, created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)",
      [user.id, user.username, user.password_hash, user.role, user.referral_code, user.referred_by, user.user_no, user.balance, user.frozen, user.phone, user.display_name, user.telegram_id, user.telegram_username, user.status, user.created_at]
    );
  } else {
    const db = await loadMemory();
    db.users.push(user);
    await saveMemory();
  }
  if (referrer && REFERRAL_REWARD > 0) {
    await adjustBalance(referrer.id, REFERRAL_REWARD, "referral_reward", user.id, `推荐 ${user.username}`);
  }
  return user;
}

async function createStaffApplication({ username, password, phone = "", role = "customer_service", staffName = "", reason = "" }) {
  const cleanUsername = String(username || "").trim();
  if (!cleanUsername || !password) throw httpError(400, "请输入账号和密码");
  if (String(password).length < 6) throw httpError(400, "密码至少 6 位");
  if (!["customer_service", "finance", "risk", "operations"].includes(role)) throw httpError(400, "申请角色不正确");
  const existing = await findUserByUsername(cleanUsername);
  if (existing) throw httpError(409, "账号已存在");
  const user = {
    id: id("usr"),
    username: cleanUsername,
    password_hash: hashPassword(password),
    role,
    referral_code: makeReferralCode(),
    referred_by: null,
    user_no: await nextUserNo(),
    balance: 0,
    frozen: 0,
    phone: String(phone || "").trim(),
    display_name: "",
    telegram_id: null,
    telegram_username: null,
    admin_status: "pending",
    admin_permissions: normalizePermissions([], role),
    staff_name: String(staffName || "").trim(),
    staff_reason: String(reason || "").trim(),
    status: "active",
    created_at: now(),
    last_login_at: null
  };
  if (pool) {
    await pool.query(
      `insert into users (id, username, password_hash, role, referral_code, referred_by, user_no, balance, frozen, phone, display_name, telegram_id, telegram_username, admin_status, admin_permissions, staff_name, staff_reason, status, created_at)
       values ($1,$2,$3,$4,$5,$6,$7,0,0,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)`,
      [user.id, user.username, user.password_hash, user.role, user.referral_code, user.referred_by, user.user_no, user.phone, user.display_name, user.telegram_id, user.telegram_username, user.admin_status, JSON.stringify(user.admin_permissions), user.staff_name, user.staff_reason, user.status, user.created_at]
    );
  } else {
    const db = await loadMemory();
    db.users.push(user);
    await saveMemory();
  }
  return user;
}

async function updateStaffAccount(staffId, values, admin) {
  const staff = await findUserById(staffId);
  if (!staff || !isStaffRole(staff.role)) throw httpError(404, "后台账号不存在");
  if (staff.role === "admin" && admin.id !== staff.id) throw httpError(403, "不能修改超级管理员");
  const role = ["customer_service", "finance", "risk", "operations"].includes(values.role) ? values.role : staff.role;
  const adminStatus = ["pending", "approved", "rejected"].includes(values.admin_status) ? values.admin_status : (staff.admin_status || "approved");
  const status = ["active", "disabled"].includes(values.status) ? values.status : (staff.status || "active");
  const permissions = normalizePermissions(values.admin_permissions, role);
  const phone = String(values.phone ?? staff.phone ?? "").trim();
  const staffName = String(values.staff_name ?? staff.staff_name ?? "").trim();
  if (pool) {
    await pool.query(
      "update users set role=$1, admin_status=$2, admin_permissions=$3, status=$4, phone=$5, staff_name=$6 where id=$7",
      [role, adminStatus, JSON.stringify(permissions), status, phone, staffName, staffId]
    );
  } else {
    const db = await loadMemory();
    const row = db.users.find((u) => u.id === staffId);
    Object.assign(row, { role, admin_status: adminStatus, admin_permissions: permissions, status, phone, staff_name: staffName });
    await saveMemory();
  }
  await logOperation(admin.id, "update_staff_account", { staffId, role, adminStatus, status, permissions });
  return await findUserById(staffId);
}

async function reviewStaffAccount(staffId, status, admin) {
  if (!["approved", "rejected"].includes(status)) throw httpError(400, "审批状态错误");
  return await updateStaffAccount(staffId, { admin_status: status, status: status === "approved" ? "active" : "disabled" }, admin);
}

async function getOrCreateTelegramUser(tgUser, referralCode) {
  const telegramId = String(tgUser.id);
  const existing = await findUserByTelegramId(telegramId);
  if (existing) return existing;
  const username = `tg_${telegramId}`;
  const password = randomBytes(10).toString("hex");
  return await createUser({
    username,
    password,
    referralCode,
    telegramId,
    telegramUsername: tgUser.username || null
  });
}

async function createSession(userId) {
  const token = randomBytes(32).toString("hex");
  const row = { token, user_id: userId, created_at: now(), expires_at: new Date(Date.now() + 7 * 86400000).toISOString() };
  if (pool) {
    await pool.query("insert into sessions (token,user_id,created_at,expires_at) values ($1,$2,$3,$4)", [row.token, row.user_id, row.created_at, row.expires_at]);
    await pool.query("update users set last_login_at=$1 where id=$2", [now(), userId]);
  } else {
    const db = await loadMemory();
    db.sessions.push(row);
    const user = db.users.find((u) => u.id === userId);
    if (user) user.last_login_at = now();
    await saveMemory();
  }
  return token;
}

async function updatePassword(userId, passwordHash) {
  if (pool) {
    await pool.query("update users set password_hash=$1 where id=$2", [passwordHash, userId]);
  } else {
    const db = await loadMemory();
    const user = db.users.find((u) => u.id === userId);
    if (!user) throw httpError(404, "用户不存在");
    user.password_hash = passwordHash;
    await saveMemory();
  }
}

async function authUser(req) {
  const token = req.headers.authorization?.replace(/^Bearer\s+/i, "") || "";
  if (!token) return null;
  if (pool) {
    const res = await pool.query("select u.* from sessions s join users u on u.id=s.user_id where s.token=$1 and s.expires_at > now()", [token]);
    return res.rows[0] || null;
  }
  const db = await loadMemory();
  const session = db.sessions.find((s) => s.token === token && new Date(s.expires_at) > new Date());
  return session ? db.users.find((u) => u.id === session.user_id) || null : null;
}

function requireRole(user, role) {
  if (!user) throw httpError(401, "请先登录");
  if (role === "admin") {
    if (!isStaffRole(user.role)) throw httpError(403, "无权限");
    if ((user.admin_status || "approved") !== "approved") throw httpError(403, "后台账号未审批");
    return;
  }
  if (role && user.role !== role && user.role !== "admin") throw httpError(403, "无权限");
}

function requireAdminModule(user, moduleId) {
  requireRole(user, "admin");
  if (user.role === "admin") return;
  const permissions = normalizePermissions(user.admin_permissions, user.role);
  if (!permissions.includes(moduleId)) throw httpError(403, "当前角色无此模块权限");
}

function requireAnyAdminModule(user, moduleIdsForAccess) {
  requireRole(user, "admin");
  if (user.role === "admin") return;
  const permissions = normalizePermissions(user.admin_permissions, user.role);
  if (!moduleIdsForAccess.some((moduleId) => permissions.includes(moduleId))) throw httpError(403, "当前角色无此模块权限");
}

function shuffle(list) {
  const copy = [...list];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function createDeck() {
  return shuffle(fishTypes.flatMap((fish) => Array.from({ length: 8 }, () => fish)));
}

function sortedCombo(counts) {
  return [counts.yellow, counts.grouper, counts.eel].sort((a, b) => b - a).join("");
}

function jsonValue(value, fallback) {
  if (value == null) return cloneJson(fallback);
  if (typeof value === "string") {
    try { return JSON.parse(value); } catch { return cloneJson(fallback); }
  }
  return value;
}

function normalizePlatformConfig(value = {}) {
  const source = jsonValue(value, defaultPlatformConfig);
  const byUnit = new Map((Array.isArray(source.valueUnits) ? source.valueUnits : []).map((unit) => [unit.id, unit]));
  const byGame = new Map((Array.isArray(source.games) ? source.games : []).map((game) => [game.id, game]));
  return {
    platform: { ...defaultPlatformConfig.platform, ...(source.platform || {}) },
    valueUnits: defaultPlatformConfig.valueUnits.map((unit) => ({ ...unit, ...(byUnit.get(unit.id) || {}) })),
    games: defaultPlatformConfig.games.map((game) => ({ ...game, ...(byGame.get(game.id) || {}) }))
  };
}

async function getPlatformConfig() {
  if (pool) {
    const res = await pool.query("select * from platform_settings where id='default'");
    const row = res.rows[0];
    return row ? { ...normalizePlatformConfig(row.config), updated_at: row.updated_at, updated_by: row.updated_by } : { ...normalizePlatformConfig(defaultPlatformConfig), updated_at: now() };
  }
  const db = await loadMemory();
  return { ...normalizePlatformConfig(db.platformSettings || defaultPlatformConfig), updated_at: db.platformSettings?.updated_at || now(), updated_by: db.platformSettings?.updated_by };
}

function walletMeta(options = {}, txId) {
  return {
    ...(options.meta || {}),
    wallet_transaction_id: txId
  };
}

async function adjustBalance(userId, amount, type, refId, note, options = {}) {
  if (pool) {
    const client = await pool.connect();
    try {
      await client.query("begin");
      const res = await client.query("select * from users where id=$1 for update", [userId]);
      const user = res.rows[0];
      if (!user) throw httpError(404, "用户不存在");
      const before = user.balance;
      const after = before + amount;
      if (after < 0 && !options.allowNegative) throw httpError(400, "摸鱼币不足");
      await client.query("update users set balance=$1 where id=$2", [after, userId]);
      const txId = id("tx");
      await client.query(
        "insert into wallet_transactions (id,user_id,type,amount,balance_before,balance_after,unit_type,currency,game_id,meta,ref_id,note,created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)",
        [txId, userId, type, amount, before, after, "moyu_coin", "MYB", options.gameId || "", JSON.stringify(walletMeta(options, txId)), refId, note, now()]
      );
      await client.query(
        `insert into value_ledger (id,user_id,unit_type,currency,game_id,resource_id,amount,balance_before,balance_after,ref_type,ref_id,note,meta,created_at)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
        [id("vlg"), userId, "moyu_coin", "MYB", options.gameId || "", options.resourceId || "", amount, before, after, type, refId, note, JSON.stringify(walletMeta(options, txId)), now()]
      );
      await client.query("commit");
      return after;
    } catch (error) {
      await client.query("rollback");
      throw error;
    } finally {
      client.release();
    }
  }
  const db = await loadMemory();
  const user = db.users.find((u) => u.id === userId);
  if (!user) throw httpError(404, "用户不存在");
  const before = user.balance;
  const after = before + amount;
  if (after < 0 && !options.allowNegative) throw httpError(400, "摸鱼币不足");
  user.balance = after;
  const txId = id("tx");
  const meta = walletMeta(options, txId);
  db.transactions.push({ id: txId, user_id: userId, type, amount, balance_before: before, balance_after: after, unit_type: "moyu_coin", currency: "MYB", game_id: options.gameId || "", meta, ref_id: refId, note, created_at: now() });
  db.valueLedger.push({ id: id("vlg"), user_id: userId, unit_type: "moyu_coin", currency: "MYB", game_id: options.gameId || "", resource_id: options.resourceId || "", amount, balance_before: before, balance_after: after, ref_type: type, ref_id: refId, note, meta, created_at: now() });
  await saveMemory();
  return after;
}

async function findUserByLookup(lookup) {
  const key = String(lookup || "").trim();
  if (!key) throw httpError(400, "请输入会员账号、系统ID、用户ID或手机号");
  if (pool) {
    const res = await pool.query(
      `select * from users
       where id=$1
          or username=$1
          or phone=$1
          or telegram_id=$1
          or telegram_username=$1
          or referral_code=$1
          or user_no::text=$1
       limit 1`,
      [key]
    );
    return res.rows[0] || null;
  }
  const db = await loadMemory();
  return db.users.find((user) => [user.id, user.username, user.phone, user.telegram_id, user.telegram_username, user.referral_code, user.user_no].some((value) => String(value || "") === key)) || null;
}

async function adminAdjustUserBalance(values, admin) {
  const target = await findUserByLookup(values.user_lookup || values.userId || values.username);
  if (!target) throw httpError(404, "会员不存在");
  if (target.role !== "player") throw httpError(400, "只能调整普通会员积分");
  const mode = String(values.mode || "add");
  const rawAmount = Number(values.amount);
  if (!Number.isFinite(rawAmount)) throw httpError(400, "请输入有效摸鱼币数量");
  const before = Number(target.balance || 0);
  let delta = 0;
  let type = "admin_add";
  if (mode === "add") {
    if (rawAmount <= 0) throw httpError(400, "加分数量必须大于 0");
    delta = Math.trunc(rawAmount);
    type = "admin_add";
  } else if (mode === "deduct") {
    if (rawAmount <= 0) throw httpError(400, "扣分数量必须大于 0");
    delta = -Math.trunc(rawAmount);
    type = "admin_deduct";
  } else if (mode === "set") {
    delta = Math.trunc(rawAmount) - before;
    type = "admin_set_balance";
  } else {
    throw httpError(400, "调整方式不正确");
  }
  if (delta === 0) throw httpError(400, "摸鱼币没有变化");
  const reason = String(values.reason || "").trim();
  if (!reason) throw httpError(400, "请填写调整原因");
  const refId = id("adj");
  const after = await adjustBalance(target.id, delta, type, refId, `后台摸鱼币调整：${reason}；管理员：${admin.username}`, { allowNegative: true });
  await logOperation(admin.id, "admin_adjust_balance", { refId, userId: target.id, username: target.username, mode, amount: rawAmount, delta, before, after, reason });
  return { refId, userId: target.id, username: target.username, before, after, delta };
}

async function updateMemberStatus(values, admin) {
  const target = await findUserByLookup(values.user_lookup || values.userId || values.username);
  if (!target) throw httpError(404, "会员不存在");
  if (target.role !== "player") throw httpError(400, "只能修改普通会员状态");
  const status = String(values.status || "").trim();
  if (!["active", "disabled", "blacklisted"].includes(status)) throw httpError(400, "账号状态不正确");
  const reason = String(values.reason || "").trim() || "后台状态调整";
  if (pool) {
    await pool.query("update users set status=$1 where id=$2", [status, target.id]);
  } else {
    const db = await loadMemory();
    const row = db.users.find((u) => u.id === target.id);
    if (!row) throw httpError(404, "会员不存在");
    row.status = status;
    await saveMemory();
  }
  await logOperation(admin.id, "update_member_status", { userId: target.id, username: target.username, status, reason });
  return { userId: target.id, username: target.username, status, reason };
}

async function reserveWithdrawal(userId, amount, refId) {
  if (pool) {
    const client = await pool.connect();
    try {
      await client.query("begin");
      const res = await client.query("select * from users where id=$1 for update", [userId]);
      const user = res.rows[0];
      if (!user) throw httpError(404, "用户不存在");
      const before = Number(user.balance);
      const after = before - amount;
      if (after < 0) throw httpError(400, "摸鱼币不足");
      await client.query("update users set balance=$1, frozen=frozen+$2 where id=$3", [after, amount, userId]);
      const txId = id("tx");
      await client.query(
        "insert into wallet_transactions (id,user_id,type,amount,balance_before,balance_after,unit_type,currency,game_id,meta,ref_id,note,created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)",
        [txId, userId, "withdraw_freeze", -amount, before, after, "moyu_coin", "MYB", "", JSON.stringify(walletMeta({}, txId)), refId, "提现申请冻结", now()]
      );
      await client.query(
        `insert into value_ledger (id,user_id,unit_type,currency,game_id,resource_id,amount,balance_before,balance_after,ref_type,ref_id,note,meta,created_at)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
        [id("vlg"), userId, "moyu_coin", "MYB", "", "", -amount, before, after, "withdraw_freeze", refId, "提现申请冻结", JSON.stringify(walletMeta({}, txId)), now()]
      );
      await client.query("commit");
      return after;
    } catch (error) {
      await client.query("rollback");
      throw error;
    } finally {
      client.release();
    }
  }
  const db = await loadMemory();
  const user = db.users.find((u) => u.id === userId);
  if (!user) throw httpError(404, "用户不存在");
  const before = Number(user.balance);
  const after = before - amount;
  if (after < 0) throw httpError(400, "摸鱼币不足");
  user.balance = after;
  user.frozen = Number(user.frozen || 0) + amount;
  const txId = id("tx");
  const meta = walletMeta({}, txId);
  db.transactions.push({ id: txId, user_id: userId, type: "withdraw_freeze", amount: -amount, balance_before: before, balance_after: after, unit_type: "moyu_coin", currency: "MYB", game_id: "", meta, ref_id: refId, note: "提现申请冻结", created_at: now() });
  db.valueLedger.push({ id: id("vlg"), user_id: userId, unit_type: "moyu_coin", currency: "MYB", game_id: "", resource_id: "", amount: -amount, balance_before: before, balance_after: after, ref_type: "withdraw_freeze", ref_id: refId, note: "提现申请冻结", meta, created_at: now() });
  await saveMemory();
  return after;
}

async function settleWithdrawal(order, status) {
  const amount = Number(order.amount);
  if (pool) {
    const client = await pool.connect();
    try {
      await client.query("begin");
      const res = await client.query("select * from users where id=$1 for update", [order.user_id]);
      const user = res.rows[0];
      if (!user) throw httpError(404, "用户不存在");
      const before = Number(user.balance);
      const after = status === "approved" ? before : before + amount;
      const frozen = Math.max(0, Number(user.frozen) - amount);
      await client.query("update users set balance=$1, frozen=$2 where id=$3", [after, frozen, order.user_id]);
      const txId = id("tx");
      const txType = status === "approved" ? "withdraw_approved" : "withdraw_rejected";
      const txAmount = status === "approved" ? 0 : amount;
      const txNote = status === "approved" ? "提现审核通过" : "提现驳回返还";
      await client.query(
        "insert into wallet_transactions (id,user_id,type,amount,balance_before,balance_after,unit_type,currency,game_id,meta,ref_id,note,created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)",
        [txId, order.user_id, txType, txAmount, before, after, "moyu_coin", "MYB", "", JSON.stringify(walletMeta({}, txId)), order.id, txNote, now()]
      );
      await client.query(
        `insert into value_ledger (id,user_id,unit_type,currency,game_id,resource_id,amount,balance_before,balance_after,ref_type,ref_id,note,meta,created_at)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
        [id("vlg"), order.user_id, "moyu_coin", "MYB", "", "", txAmount, before, after, txType, order.id, txNote, JSON.stringify(walletMeta({}, txId)), now()]
      );
      await client.query("commit");
      return after;
    } catch (error) {
      await client.query("rollback");
      throw error;
    } finally {
      client.release();
    }
  }
  const db = await loadMemory();
  const user = db.users.find((u) => u.id === order.user_id);
  if (!user) throw httpError(404, "用户不存在");
  const before = Number(user.balance);
  const after = status === "approved" ? before : before + amount;
  user.balance = after;
  user.frozen = Math.max(0, Number(user.frozen || 0) - amount);
  const txId = id("tx");
  const txType = status === "approved" ? "withdraw_approved" : "withdraw_rejected";
  const txAmount = status === "approved" ? 0 : amount;
  const txNote = status === "approved" ? "提现审核通过" : "提现驳回返还";
  const meta = walletMeta({}, txId);
  db.transactions.push({ id: txId, user_id: order.user_id, type: txType, amount: txAmount, balance_before: before, balance_after: after, unit_type: "moyu_coin", currency: "MYB", game_id: "", meta, ref_id: order.id, note: txNote, created_at: now() });
  db.valueLedger.push({ id: id("vlg"), user_id: order.user_id, unit_type: "moyu_coin", currency: "MYB", game_id: "", resource_id: "", amount: txAmount, balance_before: before, balance_after: after, ref_type: txType, ref_id: order.id, note: txNote, meta, created_at: now() });
  await saveMemory();
  return after;
}

async function createRound(userId) {
  const round = {
    id: id("rnd"),
    user_id: userId,
    deck: createDeck(),
    opened: [],
    counts: { yellow: 0, grouper: 0, eel: 0 },
    status: "open",
    combo: null,
    score: null,
    balance_before: null,
    balance_after: null,
    created_at: now(),
    ended_at: null
  };
  if (pool) {
    await pool.query(
      "insert into rounds (id,user_id,deck,opened,counts,status,created_at) values ($1,$2,$3,$4,$5,$6,$7)",
      [round.id, round.user_id, JSON.stringify(round.deck), JSON.stringify(round.opened), JSON.stringify(round.counts), round.status, round.created_at]
    );
  } else {
    const db = await loadMemory();
    db.rounds.push(round);
    await saveMemory();
  }
  return round;
}

async function getRound(roundId, userId) {
  if (pool) {
    const res = await pool.query("select * from rounds where id=$1 and user_id=$2", [roundId, userId]);
    return res.rows[0] || null;
  }
  const db = await loadMemory();
  return db.rounds.find((r) => r.id === roundId && r.user_id === userId) || null;
}

async function saveRound(round) {
  if (pool) {
    await pool.query(
      "update rounds set opened=$1, counts=$2, status=$3, combo=$4, score=$5, balance_before=$6, balance_after=$7, ended_at=$8 where id=$9",
      [JSON.stringify(round.opened), JSON.stringify(round.counts), round.status, round.combo, round.score, round.balance_before, round.balance_after, round.ended_at, round.id]
    );
  } else {
    await saveMemory();
  }
}

async function finishRound(round, user) {
  const combo = sortedCombo(round.counts);
  const score = payouts[combo] ?? 0;
  const before = Number(user.balance);
  const after = await adjustBalance(user.id, score, "game", round.id, `摸鱼 ${combo}`, { allowNegative: true });
  round.status = "finished";
  round.combo = combo;
  round.score = score;
  round.balance_before = before;
  round.balance_after = after;
  round.ended_at = now();
  await saveRound(round);
  return { combo, score, balance: after, allFish: round.deck };
}

function normalizeFishingSettings(values = {}) {
  const current = values && typeof values === "object" ? values : {};
  const entryCost = Number(current.entry_cost ?? current.entryCost ?? defaultFishingSettings.entry_cost);
  const attempts = Number(current.attempts ?? defaultFishingSettings.attempts);
  if (!Number.isInteger(entryCost) || entryCost <= 0) throw httpError(400, "每局费用必须是正整数");
  if (!Number.isInteger(attempts) || attempts <= 0 || attempts > 20) throw httpError(400, "每局次数必须是 1 到 20 的整数");
  const sourceOutcomes = Array.isArray(current.outcomes) ? current.outcomes : [];
  const outcomes = fishingOutcomeIds.map((outcomeId) => {
    const base = defaultFishingSettings.outcomes.find((item) => item.id === outcomeId);
    const source = sourceOutcomes.find((item) => item.id === outcomeId) || {};
    const probability = Number(source.probability ?? base.probability);
    const price = Number(source.price ?? base.price);
    if (!Number.isFinite(probability) || probability < 0 || probability > 100) throw httpError(400, `${fishingLabels[outcomeId]}概率必须在 0 到 100 之间`);
    if (!Number.isInteger(price) || price < 0) throw httpError(400, `${fishingLabels[outcomeId]}回收价必须是非负整数`);
    return { id: outcomeId, name: fishingLabels[outcomeId], probability, price };
  });
  const totalProbability = outcomes.reduce((total, item) => total + Number(item.probability), 0);
  if (Math.abs(totalProbability - 100) > 0.0001) throw httpError(400, "钓鱼概率合计必须等于 100%");
  return {
    enabled: current.enabled !== false && current.enabled !== "false",
    entry_cost: entryCost,
    attempts,
    outcomes
  };
}

function fishingEstimate(settings) {
  const expectedPerCast = settings.outcomes.reduce((total, item) => total + (Number(item.probability) / 100) * Number(item.price), 0);
  const expectedRecovery = expectedPerCast * Number(settings.attempts);
  const playerEv = expectedRecovery - Number(settings.entry_cost);
  return {
    expected_per_cast: Number(expectedPerCast.toFixed(4)),
    expected_recovery: Number(expectedRecovery.toFixed(4)),
    player_ev: Number(playerEv.toFixed(4)),
    owner_ev: Number((-playerEv).toFixed(4)),
    rtp: Number(((expectedRecovery / Number(settings.entry_cost)) * 100).toFixed(2))
  };
}

async function getFishingSettings() {
  let row = null;
  if (pool) {
    const res = await pool.query("select * from fishing_settings where id='default'");
    row = res.rows[0] || null;
  } else {
    const db = await loadMemory();
    row = db.fishingSettings || null;
  }
  const config = normalizeFishingSettings(jsonValue(row?.config || row, defaultFishingSettings));
  return { ...config, stats: fishingEstimate(config), updated_at: row?.updated_at || null, updated_by: row?.updated_by || null };
}

async function updateFishingSettings(values, admin) {
  const config = normalizeFishingSettings(values);
  const updatedAt = now();
  if (pool) {
    await pool.query(
      `insert into fishing_settings (id,config,updated_at,updated_by)
       values ('default',$1,$2,$3)
       on conflict (id) do update set config=$1,updated_at=$2,updated_by=$3`,
      [JSON.stringify(config), updatedAt, admin.id]
    );
  } else {
    const db = await loadMemory();
    db.fishingSettings = { ...config, updated_at: updatedAt, updated_by: admin.id };
    await saveMemory();
  }
  await logOperation(admin.id, "update_fishing_settings", config);
  return await getFishingSettings();
}

function drawFishingOutcome(settings) {
  const roll = Math.random() * 100;
  let cursor = 0;
  for (const outcome of settings.outcomes) {
    cursor += Number(outcome.probability);
    if (roll < cursor) return outcome;
  }
  return settings.outcomes[settings.outcomes.length - 1];
}

function publicFishingRound(round) {
  const casts = jsonValue(round.casts, []);
  const counts = jsonValue(round.counts, { grouper: 0, yellow: 0, eel: 0, empty: 0 });
  const settings = normalizeFishingSettings(jsonValue(round.settings_snapshot, defaultFishingSettings));
  return {
    roundId: round.id,
    status: round.status,
    entryCost: Number(round.entry_cost),
    attempts: Number(round.attempts),
    casts,
    counts,
    recovery: Number(round.recovery || 0),
    score: round.score == null ? null : Number(round.score),
    balance: round.balance_after == null ? null : Number(round.balance_after),
    settings
  };
}

async function createFishingRound(userId) {
  const settings = await getFishingSettings();
  if (!settings.enabled) throw httpError(400, "钓鱼游戏暂未开放");
  const user = await findUserById(userId);
  if (!user) throw httpError(404, "用户不存在");
  const before = Number(user.balance || 0);
  if (before < Number(settings.entry_cost)) throw httpError(400, "摸鱼币不足");
  const round = {
    id: id("fishrnd"),
    user_id: userId,
    entry_cost: Number(settings.entry_cost),
    attempts: Number(settings.attempts),
    casts: [],
    counts: { grouper: 0, yellow: 0, eel: 0, empty: 0 },
    recovery: 0,
    score: null,
    balance_before: before,
    balance_after: null,
    status: "open",
    settings_snapshot: normalizeFishingSettings(settings),
    created_at: now(),
    ended_at: null
  };
  const after = await adjustBalance(userId, -round.entry_cost, "fishing_entry", round.id, "钓鱼开局扣费");
  round.balance_after = after;
  if (pool) {
    await pool.query(
      `insert into fishing_rounds (id,user_id,entry_cost,attempts,casts,counts,recovery,score,balance_before,balance_after,status,settings_snapshot,created_at,ended_at)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
      [round.id, round.user_id, round.entry_cost, round.attempts, JSON.stringify(round.casts), JSON.stringify(round.counts), round.recovery, round.score, round.balance_before, round.balance_after, round.status, JSON.stringify(round.settings_snapshot), round.created_at, round.ended_at]
    );
  } else {
    const db = await loadMemory();
    db.fishingRounds.push(round);
    await saveMemory();
  }
  return round;
}

async function getFishingRound(roundId, userId) {
  if (pool) {
    const res = await pool.query("select * from fishing_rounds where id=$1 and user_id=$2", [roundId, userId]);
    return res.rows[0] || null;
  }
  const db = await loadMemory();
  return db.fishingRounds.find((r) => r.id === roundId && r.user_id === userId) || null;
}

async function saveFishingRound(round) {
  if (pool) {
    await pool.query(
      "update fishing_rounds set casts=$1, counts=$2, recovery=$3, score=$4, balance_after=$5, status=$6, ended_at=$7 where id=$8",
      [JSON.stringify(round.casts), JSON.stringify(round.counts), round.recovery, round.score, round.balance_after, round.status, round.ended_at, round.id]
    );
  } else {
    await saveMemory();
  }
}

async function castFishingRound(round, user) {
  if (round.status !== "open") throw httpError(400, "本局钓鱼已结束");
  const settings = normalizeFishingSettings(jsonValue(round.settings_snapshot, defaultFishingSettings));
  round.casts = jsonValue(round.casts, []);
  round.counts = jsonValue(round.counts, { grouper: 0, yellow: 0, eel: 0, empty: 0 });
  if (round.casts.length >= Number(round.attempts)) throw httpError(400, "本局钓鱼次数已用完");
  const outcome = drawFishingOutcome(settings);
  const cast = {
    index: round.casts.length + 1,
    outcome_id: outcome.id,
    name: outcome.name,
    price: Number(outcome.price),
    created_at: now()
  };
  round.casts.push(cast);
  round.counts[outcome.id] = Number(round.counts[outcome.id] || 0) + 1;
  round.recovery = Number(round.recovery || 0) + Number(outcome.price);
  let result = null;
  if (round.casts.length >= Number(round.attempts)) {
    const freshUser = await findUserById(user.id);
    const after = round.recovery > 0
      ? await adjustBalance(user.id, round.recovery, "fishing_recovery", round.id, "钓鱼回收结算")
      : Number(freshUser?.balance || 0);
    round.status = "finished";
    round.score = Number(round.recovery) - Number(round.entry_cost);
    round.balance_after = after;
    round.ended_at = now();
    result = { recovery: round.recovery, score: round.score, balance: after };
  }
  await saveFishingRound(round);
  return { cast, round: publicFishingRound(round), finished: !!result, result };
}

async function getLatestRoundForUser(userId) {
  if (pool) {
    const res = await pool.query("select * from rounds where user_id=$1 and status='finished' order by ended_at desc limit 1", [userId]);
    return res.rows[0] || null;
  }
  const db = await loadMemory();
  return [...db.rounds]
    .filter((r) => r.user_id === userId && r.status === "finished")
    .sort((a, b) => String(b.ended_at).localeCompare(String(a.ended_at)))[0] || null;
}

async function getLeaderboard(limit = 10) {
  if (pool) {
    const res = await pool.query("select username,balance from users where role='player' order by balance desc, created_at asc limit $1", [limit]);
    return res.rows;
  }
  const db = await loadMemory();
  return [...db.users]
    .filter((u) => u.role === "player")
    .sort((a, b) => Number(b.balance) - Number(a.balance) || String(a.created_at).localeCompare(String(b.created_at)))
    .slice(0, limit)
    .map((u) => ({ username: u.username, balance: u.balance }));
}

async function listPaymentChannels() {
  if (pool) {
    const res = await pool.query("select * from payment_channels order by sort_order asc, name asc");
    return res.rows.map(normalizePaymentChannel);
  }
  const db = await loadMemory();
  return [...db.paymentChannels].map(normalizePaymentChannel).sort((a, b) => Number(a.sort_order || 100) - Number(b.sort_order || 100) || String(a.name).localeCompare(String(b.name)));
}

function normalizePaymentChannel(channel) {
  const defaults = defaultPaymentChannels.find((item) => item.id === channel.id) || {};
  return {
    account_name: "",
    account_no: "",
    network: "",
    instructions: "",
    ...defaults,
    ...channel
  };
}

async function updatePaymentChannel(channelId, values, admin) {
  const allowedIds = new Set(defaultPaymentChannels.map((channel) => channel.id));
  if (!allowedIds.has(channelId)) throw httpError(400, "支付通道不存在");
  const clean = {
    name: String(values.name || "").trim(),
    account_name: String(values.account_name || "").trim(),
    account_no: String(values.account_no || "").trim(),
    network: String(values.network || "").trim(),
    instructions: String(values.instructions || "").trim(),
    supports_recharge: !!values.supports_recharge,
    supports_withdraw: !!values.supports_withdraw,
    enabled: !!values.enabled,
    sort_order: Number(values.sort_order || 100)
  };
  if (!clean.name) throw httpError(400, "请输入通道名称");
  if (!Number.isInteger(clean.sort_order)) clean.sort_order = 100;
  if (pool) {
    await pool.query(
      "update payment_channels set name=$1,supports_recharge=$2,supports_withdraw=$3,enabled=$4,sort_order=$5,account_name=$6,account_no=$7,network=$8,instructions=$9,updated_at=$10 where id=$11",
      [clean.name, clean.supports_recharge, clean.supports_withdraw, clean.enabled, clean.sort_order, clean.account_name, clean.account_no, clean.network, clean.instructions, now(), channelId]
    );
  } else {
    const db = await loadMemory();
    const channel = db.paymentChannels.find((item) => item.id === channelId);
    if (!channel) throw httpError(404, "支付通道不存在");
    Object.assign(channel, clean, { updated_at: now() });
    await saveMemory();
  }
  await logOperation(admin.id, "update_payment_channel", { channelId, values: clean });
  return (await listPaymentChannels()).find((item) => item.id === channelId);
}

async function validatePaymentChannel(channelId, purpose) {
  const channels = await listPaymentChannels();
  const channel = channels.find((item) => item.id === channelId);
  const supportKey = purpose === "recharge" ? "supports_recharge" : "supports_withdraw";
  if (!channel || !channel.enabled || !channel[supportKey]) throw httpError(400, "请选择有效的支付通道");
  return channel;
}

async function getFinanceSettings() {
  if (pool) {
    const res = await pool.query("select * from finance_settings where id='default'");
    return res.rows[0] || { id: "default", ...defaultFinanceSettings, updated_at: now() };
  }
  const db = await loadMemory();
  return { id: "default", ...defaultFinanceSettings, ...(db.financeSettings || {}) };
}

async function updateFinanceSettings(values, admin) {
  const usdtRate = Number(values.usdt_vnd_rate);
  if (!Number.isInteger(usdtRate) || usdtRate <= 0) throw httpError(400, "USDT 汇率必须是正整数");
  const row = {
    point_vnd_rate: defaultFinanceSettings.point_vnd_rate,
    usdt_vnd_rate: usdtRate,
    updated_at: now(),
    updated_by: admin.id
  };
  if (pool) {
    await pool.query(
      `insert into finance_settings (id,point_vnd_rate,usdt_vnd_rate,updated_at,updated_by)
       values ('default',$1,$2,$3,$4)
       on conflict (id) do update set point_vnd_rate=$1,usdt_vnd_rate=$2,updated_at=$3,updated_by=$4`,
      [row.point_vnd_rate, row.usdt_vnd_rate, row.updated_at, row.updated_by]
    );
  } else {
    const db = await loadMemory();
    db.financeSettings = row;
    await saveMemory();
  }
  await logOperation(admin.id, "update_finance_settings", { usdt_vnd_rate: usdtRate });
  return await getFinanceSettings();
}

function cleanTier(value, conditionKey) {
  const condition = Number(value?.[conditionKey] || 0);
  const reward = Number(value?.reward_points || 0);
  if (!Number.isInteger(condition) || condition < 0) throw httpError(400, "活动条件必须是非负整数");
  if (!Number.isInteger(reward) || reward < 0) throw httpError(400, "奖励积分必须是非负整数");
  return { [conditionKey]: condition, reward_points: reward, enabled: !!value?.enabled };
}

function normalizeMarketingSettings(values = {}) {
  const referralTiers = Array.from({ length: 3 }, (_, index) => cleanTier(values.referral?.tiers?.[index] || defaultMarketingSettings.referral.tiers[index], "effective_members"));
  const rechargeTiers = Array.from({ length: 5 }, (_, index) => cleanTier(values.recharge?.tiers?.[index] || defaultMarketingSettings.recharge.tiers[index], "recharge_points"));
  const consecutiveDays = Number(values.checkin?.consecutive_days || defaultMarketingSettings.checkin.consecutive_days);
  const checkinReward = Number(values.checkin?.reward_points || 0);
  if (!Number.isInteger(consecutiveDays) || consecutiveDays <= 0) throw httpError(400, "签到天数必须是正整数");
  if (!Number.isInteger(checkinReward) || checkinReward < 0) throw httpError(400, "签到奖励必须是非负整数");
  return {
    referral: { enabled: !!values.referral?.enabled, tiers: referralTiers },
    checkin: { enabled: !!values.checkin?.enabled, consecutive_days: consecutiveDays, reward_points: checkinReward },
    recharge: { enabled: !!values.recharge?.enabled, tiers: rechargeTiers }
  };
}

async function getMarketingSettings() {
  if (pool) {
    const res = await pool.query("select * from marketing_settings where id='default'");
    const row = res.rows[0];
    return row ? { ...normalizeMarketingSettings(row.config), updated_at: row.updated_at, updated_by: row.updated_by } : { ...defaultMarketingSettings, updated_at: now() };
  }
  const db = await loadMemory();
  return { ...normalizeMarketingSettings(db.marketingSettings || defaultMarketingSettings), updated_at: db.marketingSettings?.updated_at, updated_by: db.marketingSettings?.updated_by };
}

async function updateMarketingSettings(values, admin) {
  const config = normalizeMarketingSettings(values);
  const updatedAt = now();
  if (pool) {
    await pool.query(
      `insert into marketing_settings (id,config,updated_at,updated_by)
       values ('default',$1,$2,$3)
       on conflict (id) do update set config=$1,updated_at=$2,updated_by=$3`,
      [JSON.stringify(config), updatedAt, admin.id]
    );
  } else {
    const db = await loadMemory();
    db.marketingSettings = { ...config, updated_at: updatedAt, updated_by: admin.id };
    await saveMemory();
  }
  await logOperation(admin.id, "update_marketing_settings", config);
  return await getMarketingSettings();
}

async function listRows(table, limit = 100) {
  if (table === "payment_channels") return await listPaymentChannels();
  if (pool) {
    const allowed = new Set(["users", "wallet_transactions", "recharge_orders", "withdraw_orders", "rounds", "fishing_rounds", "operation_logs", "value_ledger"]);
    if (!allowed.has(table)) throw httpError(400, "非法查询");
    const res = await pool.query(`select * from ${table} order by created_at desc limit $1`, [limit]);
    return res.rows;
  }
  const db = await loadMemory();
  const map = { users: db.users, wallet_transactions: db.transactions, recharge_orders: db.recharges, withdraw_orders: db.withdrawals, rounds: db.rounds, fishing_rounds: db.fishingRounds, payment_channels: db.paymentChannels, operation_logs: db.operationLogs, value_ledger: db.valueLedger };
  return [...(map[table] || [])].sort((a, b) => String(b.created_at).localeCompare(String(a.created_at))).slice(0, limit);
}

function publicGame(game) {
  return {
    id: game.id,
    name: game.name,
    category: game.category,
    status: game.status,
    entry: game.entry,
    guide: game.guide,
    walletMode: game.walletMode,
    description: game.description
  };
}

async function getGamePlatformOverview() {
  const [users, tankRounds, fishingRounds, valueLedger, platformConfig] = await Promise.all([
    listRows("users", 10000),
    listRows("rounds", 10000),
    listRows("fishing_rounds", 10000),
    listRows("value_ledger", 10000),
    getPlatformConfig()
  ]);
  const players = users.filter((user) => user.role === "player");
  const userById = new Map(users.map((user) => [user.id, user]));
  const normalizeRound = (game, row) => ({
    game_id: game.id,
    game_name: game.name,
    round_id: row.id,
    user_id: row.user_id,
    username: userById.get(row.user_id)?.username || row.user_id,
    status: row.status,
    stake: game.id === "fishing" ? Number(row.entry_cost || 0) : 0,
    recovery: game.id === "fishing" ? Number(row.recovery || 0) : 0,
    score: Number(row.score || 0),
    platform_profit: -Number(row.score || 0),
    created_at: row.created_at,
    ended_at: row.ended_at || null
  });
  const games = gameCatalog.map((game) => {
    const sourceRows = game.id === "tank" ? tankRounds : game.id === "fishing" ? fishingRounds : [];
    const finished = sourceRows.filter((row) => row.status === "finished");
    const today = new Date().toISOString().slice(0, 10);
    const todayRows = sourceRows.filter((row) => String(row.created_at || "").slice(0, 10) === today);
    return {
      ...publicGame(game),
      rounds: sourceRows.length,
      finishedRounds: finished.length,
      todayRounds: todayRows.length,
      activePlayers: new Set(sourceRows.map((row) => row.user_id)).size,
      platformProfit: finished.reduce((sum, row) => sum - Number(row.score || 0), 0),
      todayPlatformProfit: todayRows.reduce((sum, row) => sum - Number(row.score || 0), 0)
    };
  });
  const recentRounds = [
    ...tankRounds.map((row) => normalizeRound(gameCatalog.find((game) => game.id === "tank"), row)),
    ...fishingRounds.map((row) => normalizeRound(gameCatalog.find((game) => game.id === "fishing"), row))
  ].sort((a, b) => String(b.created_at).localeCompare(String(a.created_at))).slice(0, 200);
  return {
    platform: platformConfig.platform,
    valueUnits: platformConfig.valueUnits,
    games,
    recentRounds,
    valueLedger: valueLedger.slice(0, 200),
    shared: {
      wallet: "moyu_coin",
      walletLabel: "摸鱼币",
      players: players.length,
      gameCount: gameCatalog.length,
      totalRounds: games.reduce((sum, game) => sum + Number(game.rounds || 0), 0),
      totalPlatformProfit: games.reduce((sum, game) => sum + Number(game.platformProfit || 0), 0),
      valueLedgerCount: valueLedger.length
    }
  };
}

async function createOrder(kind, row) {
  if (pool) {
    if (kind === "recharge") {
      await pool.query(
        "insert into recharge_orders (id,user_id,amount,channel,status,proof,note,cash_currency,cash_amount,coin_amount,exchange_rate,created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)",
        [row.id, row.user_id, row.amount, row.channel, row.status, row.proof, row.note, row.cash_currency || "", row.cash_amount ?? null, row.coin_amount ?? row.amount, row.exchange_rate ?? null, row.created_at]
      );
    } else {
      await pool.query(
        "insert into withdraw_orders (id,user_id,amount,account,method,status,note,cash_currency,cash_amount,coin_amount,exchange_rate,created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)",
        [row.id, row.user_id, row.amount, row.account, row.method, row.status, row.note, row.cash_currency || "", row.cash_amount ?? null, row.coin_amount ?? row.amount, row.exchange_rate ?? null, row.created_at]
      );
    }
  } else {
    const db = await loadMemory();
    (kind === "recharge" ? db.recharges : db.withdrawals).push(row);
    await saveMemory();
  }
  return row;
}

async function reviewOrder(kind, orderId, status, admin, note = "") {
  if (!["recharge", "withdraw"].includes(kind)) throw httpError(400, "订单类型错误");
  if (!["approved", "rejected"].includes(status)) throw httpError(400, "审核状态错误");
  const table = kind === "recharge" ? "recharge_orders" : "withdraw_orders";
  const reviewNote = String(note || "").trim().slice(0, 500);
  let order;
  if (pool) {
    const res = await pool.query(`select * from ${table} where id=$1`, [orderId]);
    order = res.rows[0];
  } else {
    const db = await loadMemory();
    order = (kind === "recharge" ? db.recharges : db.withdrawals).find((o) => o.id === orderId);
  }
  if (!order) throw httpError(404, "订单不存在");
  if (order.status !== "pending") throw httpError(400, "订单已审核");
  if (kind === "recharge" && status === "approved") {
    await adjustBalance(order.user_id, Number(order.amount), "recharge", order.id, "充值审核通过");
  }
  if (kind === "withdraw") {
    await settleWithdrawal(order, status);
  }
  order.status = status;
  order.reviewed_at = now();
  order.reviewed_by = admin.id;
  order.review_note = reviewNote;
  if (pool) {
    await pool.query(`update ${table} set status=$1, reviewed_at=$2, reviewed_by=$3, review_note=$4 where id=$5`, [order.status, order.reviewed_at, order.reviewed_by, order.review_note, order.id]);
  } else {
    await saveMemory();
  }
  await logOperation(admin.id, `review_${kind}`, { orderId, status, note: reviewNote });
  return order;
}

async function getAdminSystemStatus() {
  const [users, recharges, withdrawals, paymentChannels, fishingSettings, botGroups, templates, logs] = await Promise.all([
    listRows("users", 10000),
    listRows("recharge_orders", 10000),
    listRows("withdraw_orders", 10000),
    listPaymentChannels(),
    getFishingSettings(),
    listBotGroups(),
    listMessageTemplates(),
    listBotSendLogs(20)
  ]);
  const staff = users.filter((item) => isStaffRole(item.role));
  const pendingRecharges = recharges.filter((item) => item.status === "pending").length;
  const pendingWithdrawals = withdrawals.filter((item) => item.status === "pending").length;
  const enabledPaymentChannels = paymentChannels.filter((item) => item.enabled && (item.supports_recharge || item.supports_withdraw)).length;
  const checks = [
    { id: "database", label: "数据存储", ok: !!(pool || existsSync(dataFile)), detail: pool ? "PostgreSQL 已连接" : "本地 JSON 存储" },
    { id: "admin_password", label: "后台默认密码", ok: ADMIN_PASSWORD !== "admin123456" || !!RESET_ADMIN_PASSWORD, detail: ADMIN_PASSWORD === "admin123456" && !RESET_ADMIN_PASSWORD ? "仍在使用默认密码" : "已设置自定义密码" },
    { id: "app_url", label: "APP_URL", ok: !!APP_URL && !APP_URL.includes("localhost"), detail: APP_URL },
    { id: "payment_channels", label: "支付通道", ok: enabledPaymentChannels > 0, detail: `启用 ${enabledPaymentChannels} 个通道` },
    { id: "fishing", label: "钓鱼游戏", ok: fishingSettings.enabled !== false, detail: `入场 ${fishingSettings.entry_cost}，次数 ${fishingSettings.attempts}` },
    { id: "telegram", label: "Telegram Bot", ok: !!TELEGRAM_BOT_TOKEN && !!TELEGRAM_BOT_USERNAME, detail: TELEGRAM_BOT_USERNAME ? `@${TELEGRAM_BOT_USERNAME.replace(/^@/, "")}` : "未配置机器人用户名" }
  ];
  return {
    runtime: {
      appUrl: APP_URL,
      port: PORT,
      nodeEnv: process.env.NODE_ENV || "development",
      storage: pool ? "postgres" : "json",
      databaseConnected: !!pool
    },
    security: {
      adminUsername: ADMIN_USERNAME,
      defaultAdminPassword: ADMIN_PASSWORD === "admin123456" && !RESET_ADMIN_PASSWORD,
      staffCount: staff.length,
      pendingStaffApplications: staff.filter((item) => (item.admin_status || "approved") === "pending").length
    },
    bot: {
      tokenConfigured: !!TELEGRAM_BOT_TOKEN,
      username: TELEGRAM_BOT_USERNAME || "",
      webhookUrl: `${APP_URL}/api/telegram/webhook`,
      enabledGroups: botGroups.filter((item) => item.enabled).length,
      templates: templates.length,
      recentSends: logs.length
    },
    operations: {
      players: users.filter((item) => item.role === "player").length,
      pendingRecharges,
      pendingWithdrawals,
      enabledPaymentChannels,
      fishingEnabled: fishingSettings.enabled !== false
    },
    checks
  };
}

async function logOperation(adminId, action, detail) {
  const row = { id: id("op"), admin_id: adminId, action, detail, created_at: now() };
  if (pool) {
    await pool.query("insert into operation_logs (id,admin_id,action,detail,created_at) values ($1,$2,$3,$4,$5)", [row.id, row.admin_id, row.action, JSON.stringify(row.detail), row.created_at]);
  } else {
    const db = await loadMemory();
    db.operationLogs.push(row);
    await saveMemory();
  }
}

async function listBotGroups() {
  if (pool) {
    const res = await pool.query("select * from bot_groups order by created_at desc");
    return res.rows;
  }
  const db = await loadMemory();
  return [...db.botGroups].sort((a, b) => String(b.created_at).localeCompare(String(a.created_at)));
}

async function saveBotGroup(values, admin) {
  const row = {
    id: values.id || id("grp"),
    name: String(values.name || "").trim(),
    chat_id: String(values.chat_id || "").trim(),
    enabled: values.enabled !== false,
    created_at: now(),
    updated_at: now()
  };
  if (!row.name) throw httpError(400, "请输入群名称");
  if (!row.chat_id) throw httpError(400, "请输入群 ID");
  if (pool) {
    await pool.query(
      `insert into bot_groups (id,name,chat_id,enabled,created_at,updated_at)
       values ($1,$2,$3,$4,$5,$6)
       on conflict (id) do update set name=$2,chat_id=$3,enabled=$4,updated_at=$6`,
      [row.id, row.name, row.chat_id, row.enabled, row.created_at, row.updated_at]
    );
  } else {
    const db = await loadMemory();
    const existing = db.botGroups.find((item) => item.id === row.id);
    if (existing) Object.assign(existing, { name: row.name, chat_id: row.chat_id, enabled: row.enabled, updated_at: row.updated_at });
    else db.botGroups.push(row);
    await saveMemory();
  }
  await logOperation(admin.id, "save_bot_group", { id: row.id, name: row.name, chat_id: row.chat_id, enabled: row.enabled });
  return (await listBotGroups()).find((item) => item.id === row.id);
}

async function listMessageTemplates() {
  if (pool) {
    const res = await pool.query("select * from message_templates order by created_at desc");
    return res.rows;
  }
  const db = await loadMemory();
  return [...db.messageTemplates].sort((a, b) => String(b.created_at).localeCompare(String(a.created_at)));
}

async function saveMessageTemplate(values, admin) {
  const row = {
    id: values.id || id("tpl"),
    title: String(values.title || "").trim(),
    body: String(values.body || "").trim(),
    image_url: String(values.image_url || "").trim(),
    video_url: String(values.video_url || "").trim(),
    button_text: String(values.button_text || "").trim(),
    button_url: normalizeTelegramLink(values.button_url || ""),
    enabled: values.enabled !== false,
    created_at: now(),
    updated_at: now()
  };
  if (!row.title) throw httpError(400, "请输入模板标题");
  if (!row.body) throw httpError(400, "请输入模板正文");
  if (pool) {
    await pool.query(
      `insert into message_templates (id,title,body,image_url,video_url,button_text,button_url,enabled,created_at,updated_at)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
       on conflict (id) do update set title=$2,body=$3,image_url=$4,video_url=$5,button_text=$6,button_url=$7,enabled=$8,updated_at=$10`,
      [row.id, row.title, row.body, row.image_url, row.video_url, row.button_text, row.button_url, row.enabled, row.created_at, row.updated_at]
    );
  } else {
    const db = await loadMemory();
    const existing = db.messageTemplates.find((item) => item.id === row.id);
    if (existing) Object.assign(existing, { ...row, created_at: existing.created_at });
    else db.messageTemplates.push(row);
    await saveMemory();
  }
  await logOperation(admin.id, "save_message_template", { id: row.id, title: row.title });
  return (await listMessageTemplates()).find((item) => item.id === row.id);
}

function normalizeTelegramLink(value) {
  const raw = String(value || "").trim();
  if (!raw) return "";
  if (raw.startsWith("@")) return `https://t.me/${raw.slice(1)}`;
  if (/^t\.me\//i.test(raw)) return `https://${raw}`;
  if (/^https?:\/\//i.test(raw)) return raw;
  return raw;
}

async function sendTemplateToChat(chatId, template) {
  const reply_markup = template.button_text && template.button_url
    ? { inline_keyboard: [[{ text: template.button_text, url: template.button_url }]] }
    : undefined;
  const payload = { chat_id: chatId, caption: template.body, parse_mode: "HTML", reply_markup };
  if (template.video_url) return await telegramApi("sendVideo", { ...payload, video: template.video_url });
  if (template.image_url) return await telegramApi("sendPhoto", { ...payload, photo: template.image_url });
  return await telegramApi("sendMessage", { chat_id: chatId, text: template.body, parse_mode: "HTML", reply_markup });
}

async function logBotSend(row) {
  if (pool) {
    await pool.query(
      "insert into bot_send_logs (id,target_type,target_count,template_id,text,sent,failed,detail,admin_id,created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)",
      [row.id, row.target_type, row.target_count, row.template_id, row.text, row.sent, row.failed, JSON.stringify(row.detail), row.admin_id, row.created_at]
    );
  } else {
    const db = await loadMemory();
    db.botSendLogs.push(row);
    await saveMemory();
  }
}

async function listBotSendLogs(limit = 50) {
  if (pool) {
    const res = await pool.query("select * from bot_send_logs order by created_at desc limit $1", [limit]);
    return res.rows;
  }
  const db = await loadMemory();
  return [...db.botSendLogs].sort((a, b) => String(b.created_at).localeCompare(String(a.created_at))).slice(0, limit);
}

function appLoginUrl(token, path = "/") {
  return `${APP_URL}/telegram.html?token=${encodeURIComponent(token)}&next=${encodeURIComponent(path)}`;
}

function referralUrl(code) {
  if (!TELEGRAM_BOT_USERNAME) return `${APP_URL}/?ref=${encodeURIComponent(code)}`;
  return `https://t.me/${TELEGRAM_BOT_USERNAME.replace(/^@/, "")}?start=${encodeURIComponent(code)}`;
}

function telegramKeyboard(user, token) {
  const share = referralUrl(user.referral_code);
  return {
    inline_keyboard: [
      [{ text: "🐟 进入游戏", url: appLoginUrl(token, "/") }],
      [{ text: "🔗 我的邀请链接", callback_data: "invite_link" }],
      [{ text: "👥 邀请好友", url: `https://t.me/share/url?url=${encodeURIComponent(share)}&text=${encodeURIComponent("来玩摸鱼，打开链接自动绑定我的推荐。")}` }],
      [{ text: "📖 玩法说明", callback_data: "guide" }, { text: "🎁 优惠活动", callback_data: "promotions" }],
      [{ text: "💰 钱包", url: appLoginUrl(token, "/wallet.html") }, { text: "🎲 开奖结果", callback_data: "result" }]
    ]
  };
}

async function promotionText() {
  const settings = await getMarketingSettings();
  const lines = ["🎁 摸鱼优惠活动", ""];
  if (settings.referral?.enabled) {
    const tiers = (settings.referral.tiers || []).filter((tier) => tier.enabled && Number(tier.effective_members) > 0);
    lines.push("一、推荐奖励");
    if (tiers.length) {
      lines.push("邀请好友注册并成为有效会员，可按阶梯领取奖励：");
      for (const tier of tiers) lines.push(`· 推荐满 ${tier.effective_members} 个有效会员，奖励 ${tier.reward_points} 积分`);
    } else {
      lines.push("活动已开启，具体奖励以客服公布为准。");
    }
    lines.push("");
  }
  if (settings.checkin?.enabled) {
    lines.push("二、连续签到奖励");
    lines.push(`连续签到 ${settings.checkin.consecutive_days} 天，奖励 ${settings.checkin.reward_points} 积分。`);
    lines.push("");
  }
  if (settings.recharge?.enabled) {
    const tiers = (settings.recharge.tiers || []).filter((tier) => tier.enabled && Number(tier.recharge_points) > 0);
    lines.push("三、充值奖励");
    if (tiers.length) {
      lines.push("单笔充值达到对应积分，即可获得额外奖励：");
      for (const tier of tiers) lines.push(`· 单笔充值满 ${tier.recharge_points} 积分，奖励 ${tier.reward_points} 积分`);
    } else {
      lines.push("活动已开启，具体奖励以客服公布为准。");
    }
    lines.push("");
  }
  lines.push("活动奖励以后台当前设置为准；如有疑问，请联系客服。");
  return lines.join("\n");
}

async function telegramApi(method, payload) {
  if (!TELEGRAM_BOT_TOKEN) return null;
  const res = await fetch(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/${method}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(payload)
  });
  const data = await res.json();
  if (!res.ok || !data.ok) throw new Error(data.description || "Telegram API 请求失败");
  return data.result;
}

async function broadcastTelegramMessage({ audience, text, template_id }, admin) {
  const cleanText = String(text || "").trim();
  if (cleanText.length > 3500) throw httpError(400, "消息内容过长");
  const users = await listRows("users", 10000);
  const templates = await listMessageTemplates();
  const groups = await listBotGroups();
  const template = template_id ? templates.find((item) => item.id === template_id) : null;
  if (template_id && !template) throw httpError(404, "消息模板不存在");
  if (!template && !cleanText) throw httpError(400, "请选择模板或输入消息内容");
  const targets = audience === "enabled_groups"
    ? groups.filter((item) => item.enabled).map((item) => ({ id: item.id, username: item.name, telegram_id: item.chat_id }))
    : users.filter((item) => {
      if (!item.telegram_id) return false;
      if (audience === "active_tg") return item.status === "active";
      return true;
    });
  const messageText = template ? template.body : cleanText;
  const result = { total: targets.length, sent: 0, failed: 0, failures: [] };
  for (const target of targets) {
    try {
      if (template) await sendTemplateToChat(target.telegram_id, template);
      else await telegramApi("sendMessage", { chat_id: target.telegram_id, text: cleanText });
      result.sent += 1;
    } catch (error) {
      result.failed += 1;
      result.failures.push({ userId: target.id, username: target.username, error: error.message });
    }
  }
  await logBotSend({ id: id("blog"), target_type: audience || "all_tg", target_count: result.total, template_id: template?.id || null, text: messageText, sent: result.sent, failed: result.failed, detail: result.failures, admin_id: admin.id, created_at: now() });
  await logOperation(admin.id, "telegram_broadcast", { audience, templateId: template?.id || null, text: messageText, total: result.total, sent: result.sent, failed: result.failed });
  return result;
}

async function sendTelegramHome(chatId, tgUser, payload = "") {
  const user = await getOrCreateTelegramUser(tgUser, payload.trim());
  const token = await createSession(user.id);
  const rewardText = REFERRAL_REWARD > 0 ? `\n推荐奖励：每成功推荐 1 人，奖励 ${REFERRAL_REWARD} 积分。` : "";
  await telegramApi("sendMessage", {
    chat_id: chatId,
    text: `🐟 摸鱼\n稻田抓鱼 · 积分小游戏\n\n🌾 24 个密封鱼缸已藏进稻田。\n每局随机摸 12 次，按黄鱼、石斑鱼、鳗鱼的数量组合结算。\n\n· Telegram 一键进入游戏\n· 老会员分享链接即可推荐新人\n· 积分仅用于游戏记录与后台管理${rewardText}\n\n账号：${user.username}\n积分：${user.balance}\n推荐码：${user.referral_code}`,
    reply_markup: telegramKeyboard(user, token)
  });
}

async function answerTelegramCallback(callback) {
  const chatId = callback.message?.chat?.id;
  const tgUser = callback.from;
  const user = await findUserByTelegramId(tgUser.id);
  if (!user || !chatId) return;
  const token = await createSession(user.id);
  const keyboard = telegramKeyboard(user, token);
  if (callback.data === "account") {
    await telegramApi("sendMessage", {
      chat_id: chatId,
      text: `账号：${user.username}\n摸鱼币：${user.balance}\n冻结摸鱼币：${user.frozen}\n推荐码：${user.referral_code}\n分享链接：${referralUrl(user.referral_code)}`,
      reply_markup: keyboard
    });
  }
  if (callback.data === "invite_link") {
    await telegramApi("sendMessage", {
      chat_id: chatId,
      text: `你的邀请链接：\n${referralUrl(user.referral_code)}\n\n别人通过这个链接进入机器人并注册，就会绑定为你的推荐会员。`,
      reply_markup: keyboard
    });
  }
  if (callback.data === "guide") {
    await telegramApi("sendMessage", {
      chat_id: chatId,
      text: "玩法说明：\n\n1. 每局有 24 个密封鱼缸。\n2. 黄鱼、石斑鱼、鳗鱼各 8 条。\n3. 每局只能摸 12 次。\n4. 摸完后按三种鱼的数量组合结算。\n5. 5、4、3 输 10 分；其他指定组合按赔率表赢分。\n6. 通过钱包可提交充值、提现、修改密码。",
      reply_markup: keyboard
    });
  }
  if (callback.data === "promotions" || callback.data === "leaderboard") {
    await telegramApi("sendMessage", { chat_id: chatId, text: await promotionText(), reply_markup: keyboard });
  }
  if (callback.data === "result") {
    const round = await getLatestRoundForUser(user.id);
    const text = round
      ? `最近一局：\n数量组合：${String(round.combo).split("").join("、")}\n本局积分：${Number(round.score) >= 0 ? "赢" : "输"} ${Math.abs(Number(round.score))}\n结算后积分：${round.balance_after}`
      : "还没有已完成的游戏记录。";
    await telegramApi("sendMessage", { chat_id: chatId, text, reply_markup: keyboard });
  }
  await telegramApi("answerCallbackQuery", { callback_query_id: callback.id });
}

async function handleTelegramUpdate(update) {
  if (!TELEGRAM_BOT_TOKEN) throw httpError(400, "未配置 TELEGRAM_BOT_TOKEN");
  if (update.callback_query) {
    await answerTelegramCallback(update.callback_query);
    return { ok: true };
  }
  const message = update.message;
  if (!message?.chat?.id || !message.from) return { ok: true };
  const text = message.text || "";
  if (text.startsWith("/start")) {
    const payload = text.replace(/^\/start(@\w+)?\s*/i, "").trim();
    await sendTelegramHome(message.chat.id, message.from, payload);
  } else if (text.startsWith("/result")) {
    const user = await findUserByTelegramId(message.from.id);
    const round = user ? await getLatestRoundForUser(user.id) : null;
    await telegramApi("sendMessage", {
      chat_id: message.chat.id,
      text: round ? `最近一局：${String(round.combo).split("").join("、")}，${Number(round.score) >= 0 ? "赢" : "输"} ${Math.abs(Number(round.score))} 积分。` : "还没有已完成的游戏记录。"
    });
  } else {
    await sendTelegramHome(message.chat.id, message.from, "");
  }
  return { ok: true };
}

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

async function readJson(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  if (!chunks.length) return {};
  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

function sendJson(res, status, data) {
  res.writeHead(status, { "content-type": "application/json; charset=utf-8" });
  res.end(JSON.stringify(data));
}

async function api(req, res, path) {
  const user = await authUser(req);
  if (req.method === "POST" && path === "/api/telegram/webhook") {
    const body = await readJson(req);
    const result = await handleTelegramUpdate(body);
    return sendJson(res, 200, result);
  }
  if (req.method === "POST" && path === "/api/auth/register") {
    const body = await readJson(req);
    if (!body.username || !body.password) throw httpError(400, "请输入用户名和密码");
    const newUser = await createUser({ username: body.username.trim(), password: body.password, referralCode: body.referralCode?.trim() });
    const token = await createSession(newUser.id);
    return sendJson(res, 200, { token, user: publicUser(newUser) });
  }
  if (req.method === "POST" && path === "/api/admin/staff/apply") {
    const body = await readJson(req);
    const staff = await createStaffApplication({
      username: body.username,
      password: body.password,
      phone: body.phone,
      role: body.role,
      staffName: body.staff_name,
      reason: body.reason
    });
    return sendJson(res, 200, { ok: true, staff: publicUser(staff) });
  }
  if (req.method === "POST" && path === "/api/auth/login") {
    const body = await readJson(req);
    const loginUser = await findUserByUsername(body.username || "");
    if (!loginUser || !verifyPassword(body.password || "", loginUser.password_hash)) throw httpError(401, "用户名或密码错误");
    if (loginUser.status !== "active") throw httpError(403, "账号已被冻结");
    if (isStaffRole(loginUser.role) && (loginUser.admin_status || "approved") !== "approved") throw httpError(403, "后台账号等待审批或已被拒绝");
    const token = await createSession(loginUser.id);
    return sendJson(res, 200, { token, user: publicUser({ ...loginUser, last_login_at: now() }) });
  }
  if (req.method === "POST" && path === "/api/auth/change-password") {
    requireRole(user);
    const body = await readJson(req);
    if (!verifyPassword(body.oldPassword || "", user.password_hash)) throw httpError(400, "原密码错误");
    if (!body.newPassword || String(body.newPassword).length < 6) throw httpError(400, "新密码至少 6 位");
    await updatePassword(user.id, hashPassword(body.newPassword));
    return sendJson(res, 200, { ok: true });
  }
  if (req.method === "POST" && path === "/api/me/profile") {
    requireRole(user);
    const body = await readJson(req);
    const updated = await updateUserProfile(user.id, { phone: body.phone, displayName: body.displayName });
    return sendJson(res, 200, { user: publicUser(updated) });
  }
  if (req.method === "GET" && path === "/api/me") {
    requireRole(user);
    return sendJson(res, 200, { user: publicUser(user) });
  }
  if (req.method === "GET" && path === "/api/games") {
    return sendJson(res, 200, { games: gameCatalog.map(publicGame) });
  }
  if (req.method === "GET" && path === "/api/platform/config") {
    return sendJson(res, 200, { config: await getPlatformConfig(), games: gameCatalog.map(publicGame) });
  }
  if (req.method === "GET" && path === "/api/payment-channels") {
    requireRole(user);
    const channels = await listPaymentChannels();
    return sendJson(res, 200, { channels });
  }
  if (req.method === "GET" && path === "/api/finance-settings") {
    requireRole(user);
    return sendJson(res, 200, { settings: await getFinanceSettings() });
  }
  if (req.method === "GET" && path === "/api/fishing/settings") {
    requireRole(user);
    return sendJson(res, 200, { settings: await getFishingSettings() });
  }
  if (req.method === "GET" && path === "/api/marketing-settings") {
    requireRole(user, "admin");
    return sendJson(res, 200, { settings: await getMarketingSettings() });
  }
  if (req.method === "POST" && path === "/api/fishing/start") {
    requireRole(user);
    const round = await createFishingRound(user.id);
    return sendJson(res, 200, { round: publicFishingRound(round), settings: await getFishingSettings() });
  }
  if (req.method === "POST" && path === "/api/fishing/cast") {
    requireRole(user);
    const body = await readJson(req);
    const round = await getFishingRound(body.roundId, user.id);
    if (!round) throw httpError(404, "钓鱼局不存在");
    const result = await castFishingRound(round, user);
    return sendJson(res, 200, result);
  }
  if (req.method === "POST" && path === "/api/game/start") {
    requireRole(user);
    const round = await createRound(user.id);
    return sendJson(res, 200, { roundId: round.id, opened: [], counts: round.counts, maxOpen: 12 });
  }
  if (req.method === "POST" && path === "/api/game/open") {
    requireRole(user);
    const body = await readJson(req);
    const round = await getRound(body.roundId, user.id);
    if (!round) throw httpError(404, "游戏不存在");
    if (round.status !== "open") throw httpError(400, "本局已结束");
    const index = Number(body.index);
    if (!Number.isInteger(index) || index < 0 || index >= 24) throw httpError(400, "鱼缸编号错误");
    if (round.opened.includes(index)) throw httpError(400, "这个鱼缸已经打开");
    const fish = round.deck[index];
    round.opened.push(index);
    round.counts[fish] += 1;
    let result = null;
    if (round.opened.length === 12) result = await finishRound(round, user);
    else await saveRound(round);
    return sendJson(res, 200, { index, fish, label: fishLabels[fish], opened: round.opened, counts: round.counts, finished: !!result, result });
  }
  if (req.method === "POST" && path === "/api/recharge") {
    requireRole(user);
    const body = await readJson(req);
    const amount = Number(body.amount);
    if (!Number.isInteger(amount) || amount <= 0) throw httpError(400, "充值金额错误");
    const channel = body.channel || "bank";
    await validatePaymentChannel(channel, "recharge");
    const settings = await getFinanceSettings();
    const vndAmount = amount * Number(settings.point_vnd_rate);
    const usdtAmount = Number(settings.usdt_vnd_rate) > 0 ? vndAmount / Number(settings.usdt_vnd_rate) : 0;
    const note = [body.note || "", `换算：${amount}摸鱼币=${vndAmount}越南盾，USDT汇率=${settings.usdt_vnd_rate}，冷钱包约=${usdtAmount.toFixed(4)} USDT`].filter(Boolean).join("；");
    const order = await createOrder("recharge", { id: id("rec"), user_id: user.id, amount, channel, status: "pending", proof: body.proof || "", note, cash_currency: "VND", cash_amount: vndAmount, coin_amount: amount, exchange_rate: settings.point_vnd_rate, created_at: now() });
    return sendJson(res, 200, { order });
  }
  if (req.method === "POST" && path === "/api/withdraw") {
    requireRole(user);
    const body = await readJson(req);
    const amount = Number(body.amount);
    if (!Number.isInteger(amount) || amount <= 0) throw httpError(400, "提现金额错误");
    if (!body.account) throw httpError(400, "请输入提现账号");
    if (Number(user.balance) < amount) throw httpError(400, "摸鱼币不足");
    const method = body.method || "bank";
    await validatePaymentChannel(method, "withdraw");
    const settings = await getFinanceSettings();
    const vndAmount = amount * Number(settings.point_vnd_rate);
    const usdtAmount = Number(settings.usdt_vnd_rate) > 0 ? vndAmount / Number(settings.usdt_vnd_rate) : 0;
    const note = [body.note || "", `换算：${amount}摸鱼币=${vndAmount}越南盾，USDT汇率=${settings.usdt_vnd_rate}，冷钱包约=${usdtAmount.toFixed(4)} USDT`].filter(Boolean).join("；");
    const order = await createOrder("withdraw", { id: id("wd"), user_id: user.id, amount, account: body.account, method, status: "pending", note, cash_currency: "VND", cash_amount: vndAmount, coin_amount: amount, exchange_rate: settings.point_vnd_rate, created_at: now() });
    await reserveWithdrawal(user.id, amount, order.id);
    return sendJson(res, 200, { order });
  }
  if (req.method === "GET" && path === "/api/admin/summary") {
    requireAdminModule(user, "dashboard");
    const users = await listRows("users", 10000);
    const rounds = await listRows("rounds", 10000);
    const fishingRounds = await listRows("fishing_rounds", 10000);
    const recharges = await listRows("recharge_orders", 10000);
    const withdrawals = await listRows("withdraw_orders", 10000);
    const transactions = await listRows("wallet_transactions", 10000);
    const today = new Date().toISOString().slice(0, 10);
    const todayRows = (rows) => rows.filter((row) => String(row.created_at || "").slice(0, 10) === today);
    const sum = (rows, key = "amount") => rows.reduce((total, row) => total + Number(row[key] || 0), 0);
    const approvedRecharges = recharges.filter((o) => o.status === "approved");
    const approvedWithdrawals = withdrawals.filter((o) => o.status === "approved");
    const gameTx = transactions.filter((tx) => ["game", "fishing_entry", "fishing_recovery"].includes(tx.type));
    return sendJson(res, 200, {
      users: users.length,
      players: users.filter((u) => u.role === "player").length,
      rounds: rounds.length + fishingRounds.length,
      todayPlayers: todayRows(users).filter((u) => u.role === "player").length,
      todayRounds: todayRows(rounds).length + todayRows(fishingRounds).length,
      todayRechargeAmount: sum(todayRows(approvedRecharges)),
      todayWithdrawAmount: sum(todayRows(approvedWithdrawals)),
      platformProfit: -sum(gameTx),
      todayPlatformProfit: -sum(todayRows(gameTx)),
      totalBalance: sum(users, "balance"),
      totalFrozen: sum(users, "frozen"),
      pendingRecharges: recharges.filter((o) => o.status === "pending").length,
      pendingWithdrawals: withdrawals.filter((o) => o.status === "pending").length
    });
  }
  if (req.method === "GET" && path.startsWith("/api/admin/list/")) {
    const table = path.split("/").pop();
    const map = { users: "users", transactions: "wallet_transactions", recharges: "recharge_orders", withdrawals: "withdraw_orders", rounds: "rounds", fishingRounds: "fishing_rounds", paymentChannels: "payment_channels", operationLogs: "operation_logs", valueLedger: "value_ledger" };
    const moduleMap = { users: ["members"], transactions: ["funds"], recharges: ["funds"], withdrawals: ["funds"], rounds: ["games"], fishingRounds: ["games"], paymentChannels: ["funds"], operationLogs: ["settings", "risk"], valueLedger: ["funds", "games"] };
    if (!map[table]) throw httpError(404, "列表不存在");
    requireAnyAdminModule(user, moduleMap[table]);
    return sendJson(res, 200, { rows: await listRows(map[table], 200) });
  }
  if (req.method === "GET" && path === "/api/admin/system-status") {
    requireAdminModule(user, "settings");
    return sendJson(res, 200, { status: await getAdminSystemStatus() });
  }
  if (req.method === "GET" && path === "/api/admin/game-platform") {
    requireAdminModule(user, "games");
    return sendJson(res, 200, { platform: await getGamePlatformOverview() });
  }
  if (req.method === "POST" && path === "/api/admin/payment-channel") {
    requireAdminModule(user, "funds");
    const body = await readJson(req);
    const channel = await updatePaymentChannel(body.id, body, user);
    return sendJson(res, 200, { channel });
  }
  if (req.method === "POST" && path === "/api/admin/finance-settings") {
    requireAdminModule(user, "funds");
    const body = await readJson(req);
    const settings = await updateFinanceSettings(body, user);
    return sendJson(res, 200, { settings });
  }
  if (req.method === "POST" && path === "/api/admin/marketing-settings") {
    requireAdminModule(user, "marketing");
    const body = await readJson(req);
    const settings = await updateMarketingSettings(body, user);
    return sendJson(res, 200, { settings });
  }
  if (req.method === "POST" && path === "/api/admin/fishing-settings") {
    requireAdminModule(user, "games");
    const body = await readJson(req);
    const settings = await updateFishingSettings(body, user);
    return sendJson(res, 200, { settings });
  }
  if (req.method === "POST" && path === "/api/admin/member-adjust-balance") {
    requireAdminModule(user, "members");
    const body = await readJson(req);
    const adjustment = await adminAdjustUserBalance(body, user);
    return sendJson(res, 200, { adjustment });
  }
  if (req.method === "POST" && path === "/api/admin/member-status") {
    requireAdminModule(user, "members");
    const body = await readJson(req);
    const result = await updateMemberStatus(body, user);
    return sendJson(res, 200, { result });
  }
  if (req.method === "POST" && path === "/api/admin/telegram/broadcast") {
    requireAdminModule(user, "bot");
    const body = await readJson(req);
    const result = await broadcastTelegramMessage(body, user);
    return sendJson(res, 200, { result });
  }
  if (req.method === "GET" && path === "/api/admin/bot-center") {
    requireAdminModule(user, "bot");
    return sendJson(res, 200, { groups: await listBotGroups(), templates: await listMessageTemplates(), logs: await listBotSendLogs(50) });
  }
  if (req.method === "POST" && path === "/api/admin/bot-group") {
    requireAdminModule(user, "bot");
    const body = await readJson(req);
    const group = await saveBotGroup(body, user);
    return sendJson(res, 200, { group });
  }
  if (req.method === "POST" && path === "/api/admin/message-template") {
    requireAdminModule(user, "bot");
    const body = await readJson(req);
    const template = await saveMessageTemplate(body, user);
    return sendJson(res, 200, { template });
  }
  if (req.method === "POST" && path === "/api/admin/review") {
    requireAdminModule(user, "funds");
    const body = await readJson(req);
    const order = await reviewOrder(body.kind, body.orderId, body.status, user, body.note || body.reason || "");
    return sendJson(res, 200, { order });
  }
  if (req.method === "POST" && path === "/api/admin/staff/review") {
    requireAdminModule(user, "settings");
    const body = await readJson(req);
    const staff = await reviewStaffAccount(body.staff_id, body.status, user);
    return sendJson(res, 200, { staff });
  }
  if (req.method === "POST" && path === "/api/admin/staff/update") {
    requireAdminModule(user, "settings");
    const body = await readJson(req);
    const staff = await updateStaffAccount(body.staff_id, body, user);
    return sendJson(res, 200, { staff });
  }
  throw httpError(404, "接口不存在");
}

const mime = { ".html": "text/html; charset=utf-8", ".js": "text/javascript; charset=utf-8", ".css": "text/css; charset=utf-8", ".png": "image/png", ".svg": "image/svg+xml", ".ico": "image/x-icon" };

async function serveStatic(req, res, pathname) {
  const wantsFlutter = pathname === "/" || pathname === "/office-fishing" || pathname === "/office-fishing/" || pathname === "/office-fishing.html" || pathname.startsWith("/office-fishing/");
  if (pathname === "/fishing-office.html") {
    res.writeHead(302, { location: "/" });
    res.end();
    return;
  }
  const staticRoot = wantsFlutter && existsSync(join(flutterWebDir, "index.html")) ? flutterWebDir : publicDir;
  let safePath = normalize(pathname === "/" ? "/index.html" : pathname).replace(/^(\.\.[/\\])+/, "");
  if (wantsFlutter) {
    safePath = "/index.html";
  } else if (safePath === "/admin") {
    safePath = "/admin.html";
  }
  const filePath = join(staticRoot, safePath);
  if (!filePath.startsWith(staticRoot) || !existsSync(filePath)) {
    if (wantsFlutter && staticRoot !== publicDir) {
      const fallbackPath = join(publicDir, "office-fishing.html");
      if (existsSync(fallbackPath)) {
        res.writeHead(200, { "content-type": mime[".html"] });
        createReadStream(fallbackPath).pipe(res);
        return;
      }
    }
    res.writeHead(404);
    res.end("Not found");
    return;
  }
  res.writeHead(200, { "content-type": mime[extname(filePath)] || "application/octet-stream" });
  createReadStream(filePath).pipe(res);
}

await mkdir(publicDir, { recursive: true });
await initDb();

http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url, `http://${req.headers.host}`);
    if (url.pathname.startsWith("/api/")) return await api(req, res, url.pathname);
    return await serveStatic(req, res, url.pathname);
  } catch (error) {
    sendJson(res, error.status || 500, { error: error.message || "服务器错误" });
  }
}).listen(PORT, () => {
  console.log(`Moyu server listening on ${PORT}`);
});
