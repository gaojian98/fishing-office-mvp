# Waiting Events MVP Report

## 1. 本次实现了哪些功能
- 新增 `WaitingEventManager`。
- 抛线后生成等待事件。
- 等待事件由 `FishingProvider` / `WaitingEventManager` 生成，不由页面直接生成。
- Home 展示当前 session 的等待事件列表。
- 等待事件保留影响接口字段：
  - `effectType`
  - `effectValue`
  - `target`
- 如果存在 `nextBaitId`，等待文案会显示：
  - `你把某某作为鱼饵抛了出去。`

## 2. 涉及哪些文件
- `fishing_office_flutter/lib/core/managers/app_managers.dart`
- `fishing_office_flutter/lib/core/engine/waiting_event.dart`
- `fishing_office_flutter/lib/core/providers/app_providers.dart`
- `fishing_office_flutter/lib/pages/home/home_page.dart`
- `fishing_office_flutter/docs/Waiting_Events_MVP_Report.md`
- `fishing_office_flutter/docs/Waiting_Events_MVP_Todo.md`

## 3. Waiting Event 当前链路
1. 用户点击抛线。
2. `InteractionManager` 调用 `FishingProvider.throwLine()`。
3. `FishingProvider` 调用 `WaitingEventManagerView.buildForSession()`。
4. `WaitingEventManagerView` 生成 1~3 个等待事件。
5. 事件写入 `FishingProvider.waitingEvents`。
6. Home 页面只读这些事件并展示列表。

## 4. WaitingEvent 当前结构
- `eventId`
- `eventType`
- `message`
- `createdAt`
- `visibleToPlayer`
- 保留字段：
  - `effectType`
  - `effectValue`
  - `target`

## 5. 当前仍是 mock 的部分
- 事件生成规则仍是内置 mock。
- 不读取 Excel。
- 不接数据库。
- 不接真实 API。
- 不做真实时间等待。
- 不做复杂概率。

## 6. 后续需要接 API / Database 的位置
- `WaitingEventManagerView` 后续可替换为规则驱动或 Excel 驱动。
- `FishingProvider.throwLine()` 后续可接真实等待事件流。
- Home 继续只读 Provider，不直接计算事件。

