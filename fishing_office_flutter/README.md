# 上班摸鱼（Fishing Office）

Flutter project scaffold for the Designer + Developer workflow.

Current stage: foundation only. No business logic, no guessed hotspots, no inferred layout.

## Design Stage

The home page uses a fixed design canvas:

```text
390 x 844
```

The stage is centered on screen. Wider previews keep black side margins.

## Layer Order

```text
HomePage
 ├── Background
 ├── SeaLayer
 ├── OfficeLayer
 ├── DeskLayer
 ├── InteractiveLayer
 ├── TopBar
 ├── BottomBar
 └── DialogLayer
```

Each layer is an independent Flutter widget. Most layers are placeholders until design JSON files are supplied.

## Background

Background image:

```text
assets/images/Home.png
```

Rules:

- `BoxFit.contain`
- no crop
- no stretch
- replace `Home.png` directly without code changes

## Run

Flutter is not installed in this Codex environment, so compile/run was not executed here.

On a machine with Flutter installed:

```bash
cd fishing_office_flutter
flutter create .
flutter pub get
flutter run -d chrome
```

## Next Inputs Needed

The Developer should not guess layout. Please provide these files next:

```text
Layout.json
Interaction.json
Animation.json
Route.json
AssetManifest.json
```

Suggested order:

1. `Layout.json` - element ids, layer names, x/y/width/height based on 390 x 844.
2. `Interaction.json` - tap targets, click behavior, dialog/page/action bindings.
3. `Animation.json` - water, fish, bobber, cloud, button press and dialog transition specs.
4. `Route.json` - page ids and navigation mapping.
5. `AssetManifest.json` - replaceable image/audio asset ids and paths.

## Current JSON Hook

The scaffold now loads these files:

```text
assets/config/Layout.json
assets/config/Interaction.json
```

Web preview mirrors the same contract:

```text
public/fishing-office-layout.json
public/fishing-office-interaction.json
```

Minimal `Layout.json` shape:

```json
{
  "version": "1.0",
  "designSize": { "width": 390, "height": 844 },
  "elements": [
    {
      "id": "example_button",
      "label": "示例按钮",
      "layer": "InteractiveLayer",
      "action": "example.action",
      "enabled": true,
      "rect": { "x": 0, "y": 0, "width": 100, "height": 48 }
    }
  ]
}
```

Until Designer supplies real `elements`, no clickable regions are rendered.
