# Deployment New Service Report

## 目标

将《上班摸鱼》从平台根站点拆成独立的 Railway Web Service，不影响现有游戏平台。

## 已完成的仓库准备

1. 新增独立静态服务启动器：`fishing_office_flutter/server.js`
2. 新增独立服务 `package.json`
3. Flutter Web 已构建为根路径版本，适合独立服务直接访问 `/`

## 新服务建议名称

- `fishing-office-mvp`

## 新服务应指向的目录

- `fishing_office_flutter/`

## Build Command

```bash
flutter build web --release
```

## Start Command

```bash
node server.js
```

## Static Directory

- `fishing_office_flutter/build/web`

## 入口

- 主入口：`https://<new-service>.up.railway.app/`

## 旧入口处理

- 不再使用 `/fishing-office.html` 作为主入口
- 现有游戏平台根站点暂不修改

## 当前限制

我无法直接在 Railway 控制台创建新 Web Service，也无法从这里生成真实的新服务域名。

你需要在 Railway 里新建一个服务，指向 `fishing_office_flutter/`，然后部署后 Railway 会给出实际 URL。

## 可用仓库状态

这个子项目现在已经具备独立启动所需的最小形态，适合挂到独立 Railway Web Service 上。
