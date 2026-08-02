# Resident Detail Interaction Performance Report

## Strategy
- Resident list uses `ListView.builder`.
- Detail uses a single selected `ResidentDetailViewModel`.
- Snapshot builds resident projections from existing shared runtime state.
- Provider invalidation after resident action is limited to office snapshot and selected resident detail providers.
- No full World Tick is triggered after a resident interaction.

## Local Measurements
- Targeted smoke test including default 100 resident snapshot: PASS.
- Dedicated resident detail widget test: PASS.
- Full `flutter test`: PASS.
- `flutter build web --release`: PASS.
- No additional full tick was introduced by resident detail interaction.
- Share-fish selector uses current detail ViewModel options and does not trigger a full World Tick.
- `flutter analyze`: PASS.

## Performance Notes
- 100 resident detail projection is acceptable for current smoke coverage but can be cached if product adds heavier resident art or long memory lists.
- Recent memory defaults to 10 items.
- Detail page does not load full history.

## Risks
- Runtime debug printing in smoke tests remains noisy and can make timing noisy.
- Widget-level timing is still approximate; current tests verify interaction stability rather than exact frame timing.
