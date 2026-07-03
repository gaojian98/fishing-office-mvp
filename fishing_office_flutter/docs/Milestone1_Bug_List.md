# Milestone 1 Bug List

## 已处理

1. Flutter web 平台缺失导致无法构建。
2. 默认 widget test 引用不存在的 `MyApp`。
3. Home 数据读取分散的问题。
4. Debug Panel 字段不完整的问题。

## 当前残留风险

1. 静态预览下无法直接模拟真实手机触摸与滚动边界。
2. 现阶段仍然是 mock 数据，没有真实 API / 数据库。
3. 部分日志仅在 Debug 模式下输出，线上不会显示。
4. Railway 真正线上域名需要由部署端完成触发。
