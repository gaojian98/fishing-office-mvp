# v1.2.0 RC Known Issues

## P0

None found.

## P1

None found.

## P2

- Exact mobile browser viewport automation is blocked because the available Chrome bridge did not honor requested viewport sizes. Widget responsive tests cover target dimensions, but a manual mobile staging pass is still required.

## P3

- Some fish wait dialogue content is duplicated within individual fish records, for example repeated waiting lines. This is editorial polish, not a runtime blocker.
- Existing debug logs are verbose during tests. They do not fail analyze/test/build but should be reduced before a production hardening pass.
