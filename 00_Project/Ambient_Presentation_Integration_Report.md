# Ambient Presentation Integration Report

## Scope

Phase 5 Pack 27 only integrates ambient presentation with existing runtime data. It does not add gameplay, pages, JSON types, top-level Manager, Engine, Repository, or Railway/Git deployment.

## 已接入环境表现

- Home ambient state now reads from existing `AppRuntime` and `UiRuntimeSnapshot`.
- Runtime-derived presentation fields include `timeOfDay`, `weatherType`, `windLevel`, `festivalTags`, `residentActivity`, and `fishingState`.
- Home adds a non-interactive `AmbientPresentationLayer` above the background and below buttons/hotspots.
- Ambient layer adds soft brightness/weather overlays for morning, dusk, night, rain, and mist states.
- Sea shimmer, cloud drift, bird drift, festival glow, resident hint, waiting atmosphere hints, and float pulse are all `IgnorePointer` overlays.
- Fishing waiting hints reuse existing waiting events, fish dialogue, daily summary, and resident dialogue with de-duplication.

## 音频接口状态

- Existing `AudioManager` remains the only audio interface.
- Ambient layer calls existing audio methods with reserved cue IDs.
- Missing audio assets are safe because `AudioManager` is currently a debug/no-op interface.
- Supported reserved cues:
  - `ambient_office_sea`
  - `ambient_sea_wind`
  - `ambient_rain_window`
  - `ambient_rain_thunder_safe`
  - `ambient_festival_soft`
  - `sfx_float_dip_reserved`
  - `sfx_waiting_water_reserved`

## 动画调整

- Ambient animation uses a single local presentation controller inside the Home layer.
- Motion is slow and soft: sea, cloud, bird, festival glow, and fish float pulse.
- Animations are non-blocking and do not alter layout or hotspot coordinates.
- Dialog, button, result, and page UI designs were not redesigned.

## 性能策略

- Existing Settings `quality` controls ambient complexity.
- Low quality disables nonessential moving sea/cloud/bird effects.
- Audio fades when the app moves out of the foreground.
- Ambient overlays are lightweight `DecoratedBox`, `AnimatedContainer`, and text effects.
- Hotspots remain above ambient presentation and are not blocked by the ambient layer.

## 测试结果

- Added smoke coverage for ambient state derivation, low-quality behavior, festival cue selection, rain overlay, fishing waiting state, and waiting hint de-duplication.
- Full verification must pass:
  - `flutter analyze`
  - `flutter test`
  - `flutter build web --release`

## 缺失资源

- No real audio files are connected yet.
- No separate weather particle image assets are connected yet.
- No dedicated cloud, bird, or festival decoration assets are connected yet.

## 已知限制

- Ambient visual effects are intentionally subtle and use existing UI primitives.
- Waiting atmosphere is presentation-only and does not change fishing probability or economy.
- Audio remains a safe no-op until real assets are provided.
- No new settings options were added; existing music, sound, and quality settings are reused.
