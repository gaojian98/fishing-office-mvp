# 上班摸鱼（Fishing Office）Flutter

This is the active Flutter project for the standalone `上班摸鱼` MVP.

## Highest Product Specification

All Flutter development must follow the single Product Bible:

- [../00_Project/SecondWorld_Product_Bible.md](../00_Project/SecondWorld_Product_Bible.md)

Do not copy or maintain another Product Bible.

## Development Rule

Flutter implements confirmed specs only:

1. Product decision
2. UI design
3. JSON specification
4. Flutter implementation
5. Local test

Flutter must not change product direction, economy principles, world view, or unconfirmed gameplay.

## Design Coordinate System

```text
1080 x 1920
```

Rules:

- Background image uses contain-style scaling.
- Hotspots use JSON coordinates.
- Pages and dialogs follow confirmed JSON and DesignSystem rules.

## Config Source

Active JSON files:

- [assets/config](assets/config)

The app should load configuration through Repository / Provider / Manager layers, not direct page reads.

## Local Test

```bash
flutter pub get
flutter analyze
flutter build web --release
PORT=3100 node server.js
```

Open:

```text
http://127.0.0.1:3100/#/home
```

If browser cache shows an old build, use a fresh port from `build/web`:

```bash
cd build/web
python3 -m http.server 8084 --bind 127.0.0.1
```

Open:

```text
http://127.0.0.1:8084/#/home
```
