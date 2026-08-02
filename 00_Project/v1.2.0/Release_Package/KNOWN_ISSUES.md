# Known Issues

## P0

None known.

## P1

None known.

## P2

- Exact mobile browser viewport automation is not available in the current Chrome bridge. Widget tests cover target sizes, but staging requires manual mobile browser validation.

## P3

- Some fish wait dialogue content has near-duplicate editorial text.
- Existing debug logs are verbose during tests and should be reduced in a future hardening pass.
- Existing historical documentation contains local machine paths as records; these are not production code or secrets.
