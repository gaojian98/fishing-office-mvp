# Fishing Office v1.0.0 Known Issues

## Blocking Issues

- P0: 0
- P1: 0
- P2: 0 open

## Deferred P3 Items

- Some historical documentation still references older local test URLs. These are documentation-only and do not affect runtime.
- Debug logs are verbose in local test output. They remain useful for release-candidate diagnosis and are non-blocking.
- Audio resource hooks use safe no-op behavior until final sound assets are produced.
- Real long-wait tuning is preserved as a future productization item; MVP test waits remain shortened.
- High-frequency 30-day economy simulations show accumulation risk that should be reviewed before adding monetization or long-term live operations.

## Notes

All P0/P1/P2 issues identified before Gold Master were fixed or confirmed non-blocking.
