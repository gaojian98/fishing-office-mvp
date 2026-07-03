# Fish Chain MVP Report

## 1. 本次实现了哪些功能
- 建立 `FishChainProvider`。
- 建立基础鱼链闭环：
  - 基础鱼饵
  - 小鱼
  - 巴沙鱼
  - 罗非鱼
  - 鲭鱼
  - 石斑鱼
  - 金枪鱼
  - 传奇鱼
- `useAsBait()` 后会设置 `nextBaitId`。
- 下一次 `throwLine()` 会使用 `nextBaitId` 作为鱼饵。
- 下一次结果鱼会提升一阶。
- Home 页面展示当前鱼饵、链路、状态、等待事件、结果鱼。
- 保留失败接口：
  - `baitEaten`
  - `fishEscaped`
  - `chainFailed`

## 2. 涉及哪些文件
- `fishing_office_flutter/lib/core/managers/app_managers.dart`
- `fishing_office_flutter/lib/core/providers/app_providers.dart`
- `fishing_office_flutter/lib/core/dialog/dialog_manager.dart`
- `fishing_office_flutter/lib/core/interaction/interaction_manager.dart`
- `fishing_office_flutter/lib/pages/home/home_page.dart`
- `fishing_office_flutter/docs/Fish_Chain_MVP_Report.md`
- `fishing_office_flutter/docs/Fish_Chain_MVP_Todo.md`

## 3. Fish Chain 当前链路
1. `FishResultDialog` 点击“作为鱼饵”。
2. `FishingProvider.useAsBait()` 把当前 `fishId` 写入 `nextBaitId`。
3. `FishingProvider` 进入 `preparing`。
4. 下一次 `throwLine()` 使用 `nextBaitId` 作为 `baitId`。
5. `FishChainProvider` 读取链路并生成下一阶 mock 鱼获。
6. 结果在收线后由 `FishResultDialog` 展示。

## 4. nextBaitId 如何工作
- `nextBaitId` 由 `useAsBait()` 设置。
- 下一次 `throwLine()` 会优先使用该值。
- 使用完成后会自动清空。
- Home 会显示当前选择的鱼饵名称和链路文案。

## 5. 当前仍是 mock 的部分
- 鱼链数据仍是内置 V1 映射。
- 不读取 `FishChain.xlsx`。
- 不接数据库。
- 不接真实 API。
- 失败分支只保留接口，没有复杂概率。

## 6. 后续需要接 API / Database 的位置
- `FishChainProvider` 后续可以替换为 Excel / 配置驱动。
- `useAsBait()` 后续可以接更完整的鱼链规则。
- `baitEaten` / `fishEscaped` / `chainFailed` 后续可以接真实概率分支。

