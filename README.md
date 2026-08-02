# Fishing Office MVP

Standalone project for `上班摸鱼`.

This project is separated from the old mixed `moyu-railway` project.
Use this folder as the only active project for `上班摸鱼`.

## Highest Product Specification

The only Product Bible is:

- [00_Project/SecondWorld_Product_Bible.md](00_Project/SecondWorld_Product_Bible.md)

All developers, Flutter work, JSON configuration, Roadmap, Milestone, UI, documentation, testing, and release work must reference this single file.
Do not copy or maintain another Product Bible.

## Project Structure

```text
fishing-office-mvp/
├── 00_Project/        产品规范与项目治理
├── 01_DesignSystem/   UI 规范
├── 02_Pages/          页面规范
├── 03_JSON/           JSON 配置规范与数据
├── 04_Flutter/        Flutter 工程说明
├── 05_API/            API 预留规范
├── 06_Test/           测试规范与验收清单
├── 07_Release/        发布规范与发布记录
└── fishing_office_flutter/  当前 Flutter 工程
```

## Local

```bash
cd fishing_office_flutter
flutter pub get
flutter analyze
flutter build web --release
PORT=3100 node server.js
```

Open:

- `http://127.0.0.1:3100/`
- `http://127.0.0.1:3100/#/home`

## Runtime Routes

- `/home`
- `/store`
- `/bag`
- `/honor`
- `/wallet`
- `/help`
- `/fishing`
- `/result`
- `/exit`


## Current Release Candidate

- Candidate: `v1.2.0-rc.1`
- Development branch: `feature/v1.1-office-life-schedule`
- Flutter project: `fishing_office_flutter/`
- Local test URL: `http://127.0.0.1:3101/#/home`
- Production version remains `v1.0.0` until explicit release approval.

## Local RC Validation

```bash
cd fishing_office_flutter
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
cd ..
PORT=3101 node server.js
```

Open `http://127.0.0.1:3101/#/home` for local browser acceptance.

## Release Safety

Do not commit, push, tag, merge, or deploy without explicit product owner authorization. Release handoff material lives in `00_Project/v1.2.0/Release_Package/`.
