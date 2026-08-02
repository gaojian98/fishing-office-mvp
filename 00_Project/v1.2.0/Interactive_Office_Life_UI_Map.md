# Interactive Office Life UI Map

## Entry Point
- Profile Center: `今日办公室`

## Dialog
- `OfficeHubDialog`

## Sections
- 状态: office mood, activity, player reputation, daily summary.
- 居民: resident list, filters, sorting, selected resident detail, current state, profile visibility, relationship, memory, story, rumor, cooldown, available actions, blocked reasons, and interaction result.
- 群体: active office groups, members, activity, topic, possible impact.
- 事件: dynamic event hints and available player actions.
- 职业: career title, level, salary, performance, skills, promotion entry.
- 历史: recent office world history.

## No Changes
- Homepage layout unchanged.
- Homepage background unchanged.
- Hotspot coordinates unchanged.
- No new page route.
- No new JSON content.

## Safe States
- Runtime loading uses provider loading state.
- Runtime error shows a safe fallback message.
- Empty sections show readable empty copy.
- Duplicate action taps are locally guarded by pending action ids and engine duplicate checks.
- Resident detail keeps close/back controls inside the existing dialog and does not create new homepage overlay layers.

## Module 05 Visual Polish Notes

- Office Hub uses bounded SafeArea sizing.
- Overview metrics include readable descriptions.
- Resident detail prioritizes interactions near the top.
- Result panels hide empty categories.
- Share fish confirmation is kept reachable in compact layouts.
