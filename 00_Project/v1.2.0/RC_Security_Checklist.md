# v1.2.0 RC Security Checklist

## Automated Scans

- Secret/token/password pattern scan: PASS.
- Local absolute path / localhost production scan in `lib`, `pubspec.yaml`, and v1.2.0 docs: PASS.
- `git diff --check`: PASS.
- Build artifacts in git status: none.
- Temp/log files in git status: none.

## Notes

- Existing `debugPrint` calls remain in Flutter code. They are development diagnostics already present in the runtime path and not treated as P0/P1 blockers for this RC.
- No Railway config was modified.
- No v1.0.0 release directory was modified.
