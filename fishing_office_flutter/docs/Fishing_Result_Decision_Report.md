# Fishing Result Decision Report

## 1. 本次实现了哪些功能
- 新增 `FishResultDialog`。
- 收线后自动打开结果弹窗。
- 支持三种结果动作：
  - 出售
  - 留下
  - 作为鱼饵
- 出售会增加 `Wallet fish_coin` 和 `Wallet points`。
- 出售会新增本地 `Transaction` 的 `sell_fish` 记录。
- 留下会加入 `Inventory`。
- `tier >= 5` 时会写入 `Memory` 的 `companionPotential` 记录。
- 作为鱼饵会保留 `nextBaitId` 接口并回到 `preparing`。

## 2. 涉及哪些文件
- `fishing_office_flutter/lib/core/managers/app_managers.dart`
- `fishing_office_flutter/lib/core/dialog/dialog_manager.dart`
- `fishing_office_flutter/lib/core/interaction/interaction_manager.dart`
- `fishing_office_flutter/lib/core/providers/app_providers.dart`
- `fishing_office_flutter/docs/Fishing_Result_Decision_Report.md`
- `fishing_office_flutter/docs/Fishing_Result_Decision_Todo.md`

## 3. 结果闭环链路
1. `pullLine()` 生成 `FishingResult`。
2. `InteractionManager` 读取结果并打开 `FishResultDialog`。
3. 玩家点击：
   - 出售 -> `FishingProvider.sellFish()`
   - 留下 -> `FishingProvider.keepFish()`
   - 作为鱼饵 -> `FishingProvider.useAsBait()`
4. 页面层不直接修改钱包、库存、交易或结果对象。

## 4. sellFish 当前实现
- `WalletManagerView.add()` 增加 `fish_coin`。
- `WalletManagerView.addPoints()` 增加积分。
- `TransactionManagerView.addRecord()` 新增 `sell_fish` 记录。
- 结果清空，钓鱼状态回到 `idle`。

## 5. keepFish 当前实现
- `InventoryManagerView.addItem()` 增加鱼获。
- 若 `tier >= 5`，`MemoryManagerView.addRecord()` 写入 `companionPotential`。
- 结果清空，钓鱼状态回到 `idle`。

## 6. useAsBait 当前实现
- 仅保留接口，不做完整食物链。
- 将当前鱼设置为下一次抛线的 `nextBaitId`。
- 结果清空，钓鱼状态回到 `preparing`。

## 7. 当前仍是 mock 的部分
- `FishingResult` 仍是 mock。
- 结果判断仍是 mock。
- `Memory` 仅为本地内存记录。
- 不接数据库。
- 不接真实 API。

## 8. 后续需要接 API / Database 的位置
- `sellFish()` 后续接 Transaction API / Database。
- `keepFish()` 后续接 Inventory API / Database。
- `useAsBait()` 后续接 FishChain 与食物链规则。
- `FishResultDialog` 后续可由真实结果数据驱动。

