import http from "node:http";
import { readFile, writeFile, mkdir } from "node:fs/promises";
import { existsSync, createReadStream, readFileSync } from "node:fs";
import { extname, join, normalize } from "node:path";
import { randomBytes, pbkdf2Sync, timingSafeEqual } from "node:crypto";
import { fileURLToPath } from "node:url";

const __dirname = fileURLToPath(new URL(".", import.meta.url));
const publicDir = join(__dirname, "public");
const dataFile = join(__dirname, "data.json");
loadDotEnv();

const PORT = Number(process.env.PORT || 3000);
const DATABASE_URL = process.env.DATABASE_URL || "";
const ADMIN_USERNAME = process.env.ADMIN_USERNAME || "admin";
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || "admin123456";
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

let memory = null;

function now() {
  return new Date().toISOString();
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
    username: user.username,
    role: user.role,
    referralCode: user.referral_code,
    referredBy: user.referred_by,
    balance: user.balance,
    frozen: user.frozen,
    telegramId: user.telegram_id,
    createdAt: user.created_at
  };
}

async function loadMemory() {
  if (memory) return memory;
  if (existsSync(dataFile)) {
    memory = JSON.parse(await readFile(dataFile, "utf8"));
  } else {
    memory = { users: [], sessions: [], rounds: [], transactions: [], recharges: [], withdrawals: [], operationLogs: [] };
  }
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
        balance integer not null default 0,
        frozen integer not null default 0,
        telegram_id text unique,
        telegram_username text,
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
      create table if not exists wallet_transactions (
        id text primary key,
        user_id text not null references users(id),
        type text not null,
        amount integer not null,
        balance_before integer not null,
        balance_after integer not null,
        ref_id text,
        note text,
        created_at timestamptz not null
      );
      create table if not exists recharge_orders (
        id text primary key,
        user_id text not null references users(id),
        amount integer not null,
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
        status text not null,
        note text,
        created_at timestamptz not null,
        reviewed_at timestamptz,
        reviewed_by text
      );
      create table if not exists operation_logs (
        id text primary key,
        admin_id text,
        action text not null,
        detail jsonb not null,
        created_at timestamptz not null
      );
      alter table users add column if not exists telegram_id text unique;
      alter table users add column if not exists telegram_username text;
    `);
    const exists = await pool.query("select id from users where username=$1", [ADMIN_USERNAME]);
    if (!exists.rowCount) {
      await pool.query(
        "insert into users (id, username, password_hash, role, referral_code, balance, frozen, created_at) values ($1,$2,$3,'admin',$4,0,0,$5)",
        [id("usr"), ADMIN_USERNAME, hashPassword(ADMIN_PASSWORD), makeReferralCode(), now()]
      );
    }
  } else {
    const db = await loadMemory();
    if (!db.users.some((u) => u.username === ADMIN_USERNAME)) {
      db.users.push({
        id: id("usr"),
        username: ADMIN_USERNAME,
        password_hash: hashPassword(ADMIN_PASSWORD),
        role: "admin",
        referral_code: makeReferralCode(),
        referred_by: null,
        balance: 0,
        frozen: 0,
        telegram_id: null,
        telegram_username: null,
        status: "active",
        created_at: now(),
        last_login_at: null
      });
      await saveMemory();
    }
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
    balance: 0,
    frozen: 0,
    telegram_id: telegramId ? String(telegramId) : null,
    telegram_username: telegramUsername || null,
    status: "active",
    created_at: now(),
    last_login_at: null
  };
  if (pool) {
    await pool.query(
      "insert into users (id, username, password_hash, role, referral_code, referred_by, balance, frozen, telegram_id, telegram_username, status, created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)",
      [user.id, user.username, user.password_hash, user.role, user.referral_code, user.referred_by, user.balance, user.frozen, user.telegram_id, user.telegram_username, user.status, user.created_at]
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
  if (role && user.role !== role && user.role !== "admin") throw httpError(403, "无权限");
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
      if (after < 0 && !options.allowNegative) throw httpError(400, "积分不足");
      await client.query("update users set balance=$1 where id=$2", [after, userId]);
      await client.query(
        "insert into wallet_transactions (id,user_id,type,amount,balance_before,balance_after,ref_id,note,created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9)",
        [id("tx"), userId, type, amount, before, after, refId, note, now()]
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
  if (after < 0 && !options.allowNegative) throw httpError(400, "积分不足");
  user.balance = after;
  db.transactions.push({ id: id("tx"), user_id: userId, type, amount, balance_before: before, balance_after: after, ref_id: refId, note, created_at: now() });
  await saveMemory();
  return after;
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
      if (after < 0) throw httpError(400, "积分不足");
      await client.query("update users set balance=$1, frozen=frozen+$2 where id=$3", [after, amount, userId]);
      await client.query(
        "insert into wallet_transactions (id,user_id,type,amount,balance_before,balance_after,ref_id,note,created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9)",
        [id("tx"), userId, "withdraw_freeze", -amount, before, after, refId, "提现申请冻结", now()]
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
  if (after < 0) throw httpError(400, "积分不足");
  user.balance = after;
  user.frozen = Number(user.frozen || 0) + amount;
  db.transactions.push({ id: id("tx"), user_id: userId, type: "withdraw_freeze", amount: -amount, balance_before: before, balance_after: after, ref_id: refId, note: "提现申请冻结", created_at: now() });
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
      await client.query(
        "insert into wallet_transactions (id,user_id,type,amount,balance_before,balance_after,ref_id,note,created_at) values ($1,$2,$3,$4,$5,$6,$7,$8,$9)",
        [id("tx"), order.user_id, status === "approved" ? "withdraw_approved" : "withdraw_rejected", status === "approved" ? 0 : amount, before, after, order.id, status === "approved" ? "提现审核通过" : "提现驳回返还", now()]
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
  db.transactions.push({ id: id("tx"), user_id: order.user_id, type: status === "approved" ? "withdraw_approved" : "withdraw_rejected", amount: status === "approved" ? 0 : amount, balance_before: before, balance_after: after, ref_id: order.id, note: status === "approved" ? "提现审核通过" : "提现驳回返还", created_at: now() });
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

async function listRows(table, limit = 100) {
  if (pool) {
    const allowed = new Set(["users", "wallet_transactions", "recharge_orders", "withdraw_orders", "rounds"]);
    if (!allowed.has(table)) throw httpError(400, "非法查询");
    const res = await pool.query(`select * from ${table} order by created_at desc limit $1`, [limit]);
    return res.rows;
  }
  const db = await loadMemory();
  const map = { users: db.users, wallet_transactions: db.transactions, recharge_orders: db.recharges, withdraw_orders: db.withdrawals, rounds: db.rounds };
  return [...(map[table] || [])].sort((a, b) => String(b.created_at).localeCompare(String(a.created_at))).slice(0, limit);
}

async function createOrder(kind, row) {
  if (pool) {
    const table = kind === "recharge" ? "recharge_orders" : "withdraw_orders";
    if (kind === "recharge") {
      await pool.query("insert into recharge_orders (id,user_id,amount,status,proof,note,created_at) values ($1,$2,$3,$4,$5,$6,$7)", [row.id, row.user_id, row.amount, row.status, row.proof, row.note, row.created_at]);
    } else {
      await pool.query("insert into withdraw_orders (id,user_id,amount,account,status,note,created_at) values ($1,$2,$3,$4,$5,$6,$7)", [row.id, row.user_id, row.amount, row.account, row.status, row.note, row.created_at]);
    }
  } else {
    const db = await loadMemory();
    (kind === "recharge" ? db.recharges : db.withdrawals).push(row);
    await saveMemory();
  }
  return row;
}

async function reviewOrder(kind, orderId, status, admin) {
  if (!["approved", "rejected"].includes(status)) throw httpError(400, "审核状态错误");
  const table = kind === "recharge" ? "recharge_orders" : "withdraw_orders";
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
  if (pool) {
    await pool.query(`update ${table} set status=$1, reviewed_at=$2, reviewed_by=$3 where id=$4`, [order.status, order.reviewed_at, order.reviewed_by, order.id]);
  } else {
    await saveMemory();
  }
  await logOperation(admin.id, `review_${kind}`, { orderId, status });
  return order;
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
      [{ text: "📖 玩法说明", callback_data: "guide" }, { text: "🏆 排行榜", callback_data: "leaderboard" }],
      [{ text: "💰 钱包", url: appLoginUrl(token, "/wallet.html") }, { text: "🎲 开奖结果", callback_data: "result" }]
    ]
  };
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
      text: `账号：${user.username}\n积分：${user.balance}\n冻结积分：${user.frozen}\n推荐码：${user.referral_code}\n分享链接：${referralUrl(user.referral_code)}`,
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
  if (callback.data === "leaderboard") {
    const rows = await getLeaderboard();
    const text = rows.length
      ? rows.map((row, index) => `${index + 1}. ${row.username}：${row.balance} 分`).join("\n")
      : "暂无排行榜数据。";
    await telegramApi("sendMessage", { chat_id: chatId, text: `🏆 摸鱼排行榜\n\n${text}`, reply_markup: keyboard });
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
  if (req.method === "POST" && path === "/api/auth/login") {
    const body = await readJson(req);
    const loginUser = await findUserByUsername(body.username || "");
    if (!loginUser || !verifyPassword(body.password || "", loginUser.password_hash)) throw httpError(401, "用户名或密码错误");
    if (loginUser.status !== "active") throw httpError(403, "账号已被冻结");
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
  if (req.method === "GET" && path === "/api/me") {
    requireRole(user);
    return sendJson(res, 200, { user: publicUser(user) });
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
    const order = await createOrder("recharge", { id: id("rec"), user_id: user.id, amount, status: "pending", proof: body.proof || "", note: body.note || "", created_at: now() });
    return sendJson(res, 200, { order });
  }
  if (req.method === "POST" && path === "/api/withdraw") {
    requireRole(user);
    const body = await readJson(req);
    const amount = Number(body.amount);
    if (!Number.isInteger(amount) || amount <= 0) throw httpError(400, "提现金额错误");
    if (!body.account) throw httpError(400, "请输入提现账号");
    if (Number(user.balance) < amount) throw httpError(400, "积分不足");
    const order = await createOrder("withdraw", { id: id("wd"), user_id: user.id, amount, account: body.account, status: "pending", note: body.note || "", created_at: now() });
    await reserveWithdrawal(user.id, amount, order.id);
    return sendJson(res, 200, { order });
  }
  if (req.method === "GET" && path === "/api/admin/summary") {
    requireRole(user, "admin");
    const users = await listRows("users", 10000);
    const rounds = await listRows("rounds", 10000);
    const recharges = await listRows("recharge_orders", 10000);
    const withdrawals = await listRows("withdraw_orders", 10000);
    return sendJson(res, 200, {
      users: users.length,
      players: users.filter((u) => u.role === "player").length,
      rounds: rounds.length,
      pendingRecharges: recharges.filter((o) => o.status === "pending").length,
      pendingWithdrawals: withdrawals.filter((o) => o.status === "pending").length
    });
  }
  if (req.method === "GET" && path.startsWith("/api/admin/list/")) {
    requireRole(user, "admin");
    const table = path.split("/").pop();
    const map = { users: "users", transactions: "wallet_transactions", recharges: "recharge_orders", withdrawals: "withdraw_orders", rounds: "rounds" };
    return sendJson(res, 200, { rows: await listRows(map[table], 200) });
  }
  if (req.method === "POST" && path === "/api/admin/review") {
    requireRole(user, "admin");
    const body = await readJson(req);
    const order = await reviewOrder(body.kind, body.orderId, body.status, user);
    return sendJson(res, 200, { order });
  }
  throw httpError(404, "接口不存在");
}

const mime = { ".html": "text/html; charset=utf-8", ".js": "text/javascript; charset=utf-8", ".css": "text/css; charset=utf-8", ".png": "image/png", ".svg": "image/svg+xml", ".ico": "image/x-icon" };

async function serveStatic(req, res, pathname) {
  let safePath = normalize(pathname === "/" ? "/index.html" : pathname).replace(/^(\.\.[/\\])+/, "");
  if (safePath === "/admin") safePath = "/admin.html";
  const filePath = join(publicDir, safePath);
  if (!filePath.startsWith(publicDir) || !existsSync(filePath)) {
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
