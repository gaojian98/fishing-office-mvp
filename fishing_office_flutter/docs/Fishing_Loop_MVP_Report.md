# Fishing Loop MVP Report

## 1. 本次实现了哪些功能
- 建立最小 `FishingProvider` 状态。
- 支持 `throwLine` 抛线进入等待。
- 生成 mock `FishingSession`。
- 生成 mock `WaitingEvent`。
- 支持 `pullLine` 收线并生成 mock `FishResult`。
- 支持 `sellFish`、`keepFish`、`useAsBait` 接口。
- Home 页面展示最小钓鱼状态文案。

## 2. 涉及哪些文件
- `fishing_office_flutter/lib/core/managers/app_managers.dart`
- `fishing_office_flutter/lib/core/providers/app_providers.dart`
- `fishing_office_flutter/lib/core/interaction/interaction_manager.dart`
- `fishing_office_flutter/lib/pages/home/home_page.dart`
- `fishing_office_flutter/docs/Fishing_Loop_MVP_Report.md`
- `fishing_office_flutter/docs/Fishing_Loop_MVP_Todo.md`

## 3. Fishing 当前状态链路
1. Home 的 `mouse_top` / `btn_start_fishing` 触发抛线。
2. `InteractionManager` 调用 `FishingProvider.throwLine()`。
3. `FishingProvider` 进入 `waiting` 并生成 mock `FishingSession`。
4. 同时生成 1~3 个 mock `WaitingEvent`。
5. Home 读取 `FishingProvider.stateLabel` 展示状态文案。
6. `mouse_bottom` 触发收线。
7. `FishingProvider.pullLine()` 生成 mock `FishResult` 并进入 `finished`。

## 4. WaitingEvent 如何生成
- 抛线后，`FishingProvider` 直接创建三条 mock 等待事件。
- 当前不做真实概率。
- 事件文案为：
  - 鱼漂刚才动了一下
  - 好像有鱼靠近
  - 鱼饵被轻轻试探

## 5. FishResult 如何生成
- 收线后生成 mock `FishingResult`。
- 字段包括：
  - `fishId`
  - `fishName`
  - `tier`
  - `baseCoin`
  - `points`
  - `canSell`
  - `canKeep`
- 当前结果是固定 mock，不做真实概率判断。

## 6. sellFish / keepFish / useAsBait
- `sellFish()`：
  - 增加 `WalletManagerView.fishCoin`
  - 写入 `TransactionRecord`
- `keepFish()`：
  - 通过 `InventoryManagerView.addItem()` 增加库存
- `useAsBait()`：
  - 仅保留接口，暂不实现完整食物链

## 7. 当前仍是 mock 数据的部分
- 钓鱼结果。
- 等待事件。
- session 生成。
- 鱼价与积分。
- 结果处理逻辑。
- 交易记录仍为本地内存。

## 8. 后续需要接 API / Database 的位置
- `FishingProvider` 后续可对接真实 Fishing Engine。
- `sellFish()` 后续接 Transaction API / Database。
- `keepFish()` 后续接 Inventory API / Database。
- 等待与结果生成后续接真实概率与规则。

