# Online QA Fix Report

## 已修复

1. 首页调试信息默认隐藏，不再在线上直接显示。
2. 调试面板保留开发开关，仅在 `kDebugMode` 且带 `?debugPanel=1` 时显示。
3. 首页外层背景从纯黑调整为深色底，减轻浏览器边框的视觉冲击。
4. 首页壳子改为基于 `FittedBox(BoxFit.contain)` 的居中缩放，保持主画面完整展示。
5. 保持现有业务流程不变，没有新增玩法、数据库或 API 接入。

## 涉及文件

- `fishing_office_flutter/lib/pages/home/home_page.dart`

## 验证结果

- `flutter analyze` 通过
- `flutter build web --release` 通过

## 仍未解决的问题

1. Web 端在超宽桌面屏上仍然会保留左右留白，这是 `BoxFit.contain` 的正常结果，不做裁剪。
2. 调试面板仅在开发模式下可通过 `?debugPanel=1` 打开，线上版本默认关闭。
