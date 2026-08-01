# Fishing Office v1.0.0 Known Issues

## Blocking Issues

- P0: 0
- P1: 0 open after production `GM-RV-001` verification
- P2: 1 open

## Open Hotfix Revalidation Issues

- P1 `GM-RV-001`: Fixed and verified in production. Collection / 图鉴 popup now renders content and no longer opens as an empty panel.
- P2 `GM-RV-002`: Game Guide popup opens, but close control is not reliably visible/reachable at 390 x 844 automated validation.

## Deferred P3 Items

- Some historical documentation still references older local test URLs. These are documentation-only and do not affect runtime.
- Debug logs are verbose in local test output. They remain useful for release-candidate diagnosis and are non-blocking.
- Audio resource hooks use safe no-op behavior until final sound assets are produced.
- Real long-wait tuning is preserved as a future productization item; MVP test waits remain shortened.
- High-frequency 30-day economy simulations show accumulation risk that should be reviewed before adding monetization or long-term live operations.

## Notes

All P0/P1/P2 issues identified before Gold Master were fixed or confirmed non-blocking.

Hotfix revalidation on 2026-08-02 found one new P1 and one new P2. `GM-RV-001` has been fixed and verified in production. `GM-RV-002` remains a P2 automated mobile guide-close reachability issue for product-owner review.
