# Fishing Office v1.0.0-rc.1 Known Issues

## P0

None found.

## P1

None found.

## P2

None open.

Fixed in Pack 29:

- Store category icon paths now point to an existing placeholder asset, and resource-path validation is covered by smoke tests.

## P3

- Historical documentation still references old local test URLs such as `127.0.0.1:3100` and `8084`. Runtime validation for RC1 uses `http://127.0.0.1:3101`.
- Runtime debug logs are still verbose in test output. This is useful for diagnosis and not active as a release UI issue.
- Real audio files are not connected yet. Existing `AudioManager` safely no-ops when cues are triggered.
- Fishing wait duration still uses MVP rarity mapping rather than explicit per-fish long-wait fields.
- 高频玩家长期资产偏高，需要在后续长期消费/收藏内容接入后继续观察。
