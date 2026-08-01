# Fishing Office MVP Local Test Config

Status: Founder local test passed after fixing store currency parsing.

Active standalone project:

```text
/Users/pc/Documents/fishing-office-mvp
```

Validated source snapshot before separation:

```text
/Users/pc/Documents/Codex/2026-06-24/8-24-24-12-3-4/outputs/moyu-railway/fishing-office-mvp
```

Do not use the old mixed project for local testing:

```text
/Users/pc/Documents/Codex/2026-06-24/8-24-24-12-3-4/outputs/moyu-railway/fishing_office_flutter
```

Current verified local URL:

```text
http://127.0.0.1:8082/#/home
```

Recommended normal local commands:

```bash
cd /Users/pc/Documents/fishing-office-mvp/fishing_office_flutter
flutter analyze
flutter build web --release
PORT=3100 node server.js
```

Normal URL:

```text
http://127.0.0.1:3100/#/home
```

If browser cache or Flutter service worker causes an old page to appear, use a new port:

```bash
cd /Users/pc/Documents/fishing-office-mvp/fishing_office_flutter/build/web
python3 -m http.server 8082 --bind 127.0.0.1
```

Cache-bypass URL:

```text
http://127.0.0.1:8082/#/home
```

Separation rule:

- `moyu-railway` remains the old mixed platform project.
- `fishing-office-mvp` is the only active project for `上班摸鱼`.
- Do not copy new code back into `moyu-railway/fishing_office_flutter`.
- Do not test `上班摸鱼` from the old mixed project directory.
