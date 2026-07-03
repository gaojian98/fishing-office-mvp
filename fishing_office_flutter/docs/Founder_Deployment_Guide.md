# Founder Deployment Guide

## 目标

让 Founder 在 Railway 上完成最终发布与手机测试。

## 第一步：打开 Railway 项目

1. 打开 Railway 控制台。
2. 进入当前项目。
3. 选择 `production` 环境。

## 第二步：确认服务

需要确认两个服务状态：

- `web`
- `postgres`

其中：

- `web` 负责展示 Flutter Web 页面
- `postgres` 负责数据库（当前 MVP 不依赖它做前端测试，但项目可能已连接）

## 第三步：确认部署配置

检查 `web` 服务：

- Build Command：`flutter build web --release --base-href /office-fishing/`
- Start Command：`node server.js`
- Output Directory：`public/office-fishing/` 或等效静态输出目录

## 第四步：等待部署完成

1. 点击部署。
2. 等待 build 完成。
3. 查看日志中是否出现构建成功。
4. 确认服务状态为 `Online`。

## 第五步：获取 URL

从 Railway 服务卡片里复制 Web URL。

当前测试入口应为：

- `https://p3.up.railway.app/`
- 备用：`https://p3.up.railway.app/office-fishing/`
- 备用：`https://p3.up.railway.app/office-fishing.html`

## 第六步：手机测试

用手机浏览器打开 URL 后检查：

- Home 能否打开
- 抛线 / 收线能否操作
- Store / Wallet / Inventory 能否打开
- 返回和刷新是否正常

## 第七步：查看日志

如果打不开，检查 Railway 日志里是否有：

- Flutter 构建错误
- 静态文件 404
- base href 路径错误
- Node 启动错误

## 第八步：记录问题

如果出现 Bug，请使用 Founder Bug Template 填写：

- 页面
- 操作步骤
- 实际结果
- 期望结果
- 截图
- 严重程度
