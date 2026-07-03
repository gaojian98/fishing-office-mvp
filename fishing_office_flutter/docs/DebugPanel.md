# Debug Panel

## 说明

Debug Panel 只在 `kDebugMode` 下显示，用于整合阶段快速查看 Runtime 状态。

## 展示内容

- Wallet
- Current Bait
- Current Fish
- Fishing State
- Current Session
- Waiting Events
- Inventory Count
- Transaction Count
- Current Weather
- Current Today

## 目的

1. 快速验证 Home 运行时数据是否正确聚合。
2. 快速确认 Fishing / Wallet / Inventory / Transaction 链路是否同步。
3. 快速排查等待事件、天气和 Today 是否接入成功。

## 规则

- 仅 Debug 模式可见
- 不参与正式 UI 设计
- 不改变玩法
- 不改变经济规则
