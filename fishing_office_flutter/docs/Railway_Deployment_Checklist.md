# Railway Deployment Checklist

## 配置文件检查

- `railway.json`：未发现
- `Dockerfile`：未发现
- `nixpacks.toml`：未发现
- `nixpacks.json`：未发现
- `Procfile`：未发现

## 当前部署方式

当前项目使用根目录 Node 服务 `server.js` 提供静态站点，并直接优先服务 Flutter Web 的 `build/web` 输出目录。

### Build Command

```bash
flutter build web --release
```

### Start Command

```bash
node server.js
```

### Output Directory

- Flutter 构建输出：`fishing_office_flutter/build/web`
- 静态部署目录：`fishing_office_flutter/build/web`

### Base Href

- `/`

### Static Directory

- `fishing_office_flutter/build/web`
- `public/` 仍保留旧静态页面，但不再作为 Flutter Web 主入口

### 环境变量

当前 Node 服务和 Railway 部署常见环境变量如下：

- `PORT`
- `DATABASE_URL`
- `ADMIN_USERNAME`
- `ADMIN_PASSWORD`
- `RESET_ADMIN_PASSWORD`
- `APP_URL`
- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_BOT_USERNAME`
- `REFERRAL_REWARD`

## 是否满足 Railway Web 部署

满足静态 Web 部署的基本条件：

1. Flutter Web 已可构建。
2. 构建产物直接位于 `build/web`。
3. 根路径 `/` 可直接访问 Flutter Web。
4. `server.js` 会把静态文件按 URL 提供出去。

## 风险点

1. 当前没有专门的 `railway.json` / `Dockerfile` / `nixpacks.toml`，Railway 需要靠默认 Node 构建方式识别。
2. 如果 Railway 不是从仓库根目录启动，需确保启动命令仍然是 `node server.js`。
3. Flutter Web 资源必须与 `base-href` 一致，否则刷新会出现资源路径错误。
