# Resident Detail Interaction UI Map

## Entry
- Existing `OfficeHubDialog`.
- No homepage layout change.
- No new homepage button.

## Resident Section
- Filter chips:
  - 全部
  - 附近
  - 同地点
  - 可互动
  - 朋友
  - 有故事
  - 有事件
  - 有传闻
- Sort chips:
  - 可互动优先
  - 姓名
  - 友情
  - 最近互动
  - 地点

## Resident List
- Uses `ListView.builder`.
- Displays:
  - name
  - current location
  - mood
  - friendship stage

## Resident Detail
- Basic profile
- Current status
- Personality
- Friendship and relationship
- Visible profile fields
- Private locked fields
- Recent memories
- Recent interactions
- Stories and rumors
- Interaction cooldowns
- Available and blocked interactions

## Interaction Result
- Shows dialogue
- Shows friendship changes
- Shows memory changes
- Shows skill changes
- Shows career, quest, achievement, reputation, office influence, and cooldown changes when present.

## Overlay Safety
- Uses existing dialog frame.
- No custom `OverlayEntry`.
- No `AbsorbPointer`.
- Disabled buttons only disable their own action.
- Closing Office Hub returns to the previous dialog/home state.

## Module 05 Visual Polish Notes

- Office Hub uses bounded SafeArea sizing.
- Overview metrics include readable descriptions.
- Resident detail prioritizes interactions near the top.
- Result panels hide empty categories.
- Share fish confirmation is kept reachable in compact layouts.
