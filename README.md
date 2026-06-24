# 摸鱼 Railway 部署版

这是一个独立 Node 项目，包含：

- 玩家注册、登录
- 推荐码绑定
- 服务端摸鱼开局、开缸、结算
- 钱包积分与流水
- 充值申请与后台审核
- 提现申请与后台审核
- Telegram 机器人入口、自动注册登录、分享推荐
- 后台用户、订单、流水、游戏记录查询

## 本地运行

不连接数据库时，可以直接用本地 JSON 文件测试：

```bash
node server.js
```

默认地址：

```text
http://localhost:3000
```

本地没有 `DATABASE_URL` 时，会自动生成 `data.json` 存储测试数据。这个文件不要提交到 GitHub。

如果你要在本地连接 PostgreSQL，先安装依赖并设置 `DATABASE_URL`：

```bash
npm install
npm run dev
```

## Railway 部署

1. 新建 GitHub 仓库，把本目录内容提交进去。
2. Railway 新建项目，选择 GitHub 仓库部署。
3. 添加 PostgreSQL 插件。
4. Railway 会自动注入 `DATABASE_URL`。
5. 设置环境变量：

```text
ADMIN_USERNAME=admin
ADMIN_PASSWORD=请换成强密码
APP_URL=https://你的Railway域名
TELEGRAM_BOT_TOKEN=从BotFather获取
TELEGRAM_BOT_USERNAME=你的机器人用户名，不带@
REFERRAL_REWARD=0
```

6. 部署成功后访问 Railway 域名，或绑定你的域名。

## Telegram 机器人

1. 在 Telegram 找 `@BotFather` 创建机器人，拿到 `TELEGRAM_BOT_TOKEN` 和机器人用户名。
2. Railway 环境变量里设置：

```text
APP_URL=https://你的Railway域名
TELEGRAM_BOT_TOKEN=机器人token
TELEGRAM_BOT_USERNAME=机器人用户名
REFERRAL_REWARD=推荐奖励积分，例如 5
```

3. 部署完成后设置 webhook：

```bash
curl -X POST "https://api.telegram.org/bot你的TOKEN/setWebhook" \
  -H "content-type: application/json" \
  -d '{"url":"https://你的Railway域名/api/telegram/webhook"}'
```

4. 用户打开机器人并点击开始后，会自动注册或登录。机器人会返回：

- 🐟 进入游戏
- 🔗 我的邀请链接
- 👥 邀请好友
- 📖 玩法说明
- 🏆 排行榜
- 💰 钱包
- 🎲 开奖结果

分享链接会带上会员自己的推荐码，别人通过这个链接进入机器人并注册后，会绑定推荐关系。`REFERRAL_REWARD` 大于 0 时，推荐人获得对应积分奖励。

## 默认后台

后台入口：

```text
/admin.html
```

首次启动会自动创建后台管理员：

```text
用户名：ADMIN_USERNAME 或 admin
密码：ADMIN_PASSWORD 或 admin123456
```

上线前必须修改默认密码。
