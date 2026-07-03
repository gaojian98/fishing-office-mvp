# Deployment Entry Fix Report

## 问题现象

线上 `https://p3.up.railway.app/fishing-office.html` 命中了旧静态首页，热区不可点击。

## 已确认的入口映射

### ` / `

- 当前由 `fishing_office_flutter/build/web/index.html` 提供
- 这是最新 Flutter Web 主入口

### ` /office-fishing/ `

- 当前由 `fishing_office_flutter/build/web/index.html` 提供
- 这是保留的备用入口

### ` /fishing-office.html `

- 已改为重定向到 `/`
- 不再作为主入口

## 旧静态文件处理

已将 `public/fishing-office.html` 替换为跳转页。
已将 `public/office-fishing.html` 替换为跳转页。

这两个文件不再承载旧 UI。

## Railway 服务目录

当前应以 Flutter Web 输出目录为主：

- `fishing_office_flutter/build/web`

Node 服务 `server.js` 会优先读取该目录，并在不存在时回退到 `public/`。

## Build

```bash
flutter build web --release
```

## Start

```bash
node server.js
```

## 静态目录

- 主目录：`fishing_office_flutter/build/web`
- 旧静态目录：`public/`，仅保留重定向和旧兼容资源

## 当前实际主入口 URL

- `https://p3.up.railway.app/`

## 结果

最新 Flutter Web 现在是主入口，旧 `fishing-office.html` 已不再作为首页承载页。
