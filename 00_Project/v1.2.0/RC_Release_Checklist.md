# v1.2.0 RC Release Checklist

- [x] Branch remains `feature/v1.1-office-life-schedule`
- [x] No Commit
- [x] No Push
- [x] No Tag
- [x] No Railway deployment
- [x] No v1.0.0 release directory modification
- [x] No new top-level Manager / Engine / Repository
- [x] `dart format lib test` PASS
- [x] `flutter analyze` PASS
- [x] `flutter test` PASS, 93 tests
- [x] `flutter build web --release` PASS
- [x] `git diff --check` PASS
- [x] Key JSON parsing PASS
- [x] Critical resource HTTP checks PASS
- [x] Missing static JSON returns 404 instead of SPA HTML fallback
- [x] Save compatibility automated checks PASS
- [x] Duplicate settlement guard automated checks PASS
- [x] Overlay / Pointer widget checks PASS
- [x] Responsive widget checks PASS
- [x] Automated browser Console check PASS, 0 errors
- [x] Automated browser 9-entry home click check PASS
- [x] Automated browser core fishing flow check PASS
- [ ] Manual mobile browser viewport check
- [ ] Product owner manual acceptance
- [x] Release Package prepared
- [x] Commit Plan prepared
- [x] Authorized Commands prepared but not executed

## Go / No-Go

GO for local RC technical review after final command validation.

NO-GO for Push / RC Tag / Railway staging until product owner explicitly authorizes those actions and a separate staging service is confirmed.
