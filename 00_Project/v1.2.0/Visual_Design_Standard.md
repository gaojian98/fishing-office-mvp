# Visual Design Standard

## Scope

v1.2.0 Module 05 defines a lightweight visual standard for the existing Office Hub and resident interaction surfaces. It does not introduce a new design system or new gameplay.

## Color Use

- Primary blue: headers, selected tabs, primary status.
- Gold/wood: dialog shell, neutral tags, card borders.
- Paper surface: content cards and result panels.
- Success green: completed interactions and positive state.
- Warning brown: important events, cooldowns, blocked-but-safe states.
- Danger red: reserved for true destructive or error states only.

## Typography

- Dialog title: one line, high contrast, large weight.
- Card title: 17px, bold, single-line ellipsis.
- Subtitle: 13px, clear status summary.
- Body: 12.5px, controlled line count, natural Chinese copy.
- Tags: short labels, not raw IDs.

## Spacing And Radius

- Card radius: 18.
- Dialog radius: 28.
- Main gap: 10.
- Action minimum height: 44.

## Cards

Each major card should expose title, subtitle, body, optional tags, and actions. Empty action groups are not rendered.

## Interaction Result

Player action results are grouped as: resident response, positive change, neutral state, blocked reason, next suggestion. Empty groups are hidden.

## Accessibility

Critical controls use Semantics labels. State is represented by text tags as well as color.
