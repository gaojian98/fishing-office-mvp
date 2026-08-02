# Responsive Browser Report

## Browser Result

PARTIAL.

## Automated Browser Size

- Chrome bridge viewport observed: `1600 x 900`, DPR `1.6`.
- A `tabs.new({ viewport })` attempt was ignored by the bridge and returned `1280 x 720`, DPR `2`.

## Covered In Browser

- Home rendered centered with the 1080 x 1920 design frame.
- 9 home entry points were clickable in the active browser viewport.
- Dialogs opened and pointer capture was released after close or return.
- Core fishing flow worked in the active browser viewport.

## Covered By Widget Tests

Existing widget tests cover:

- `360 x 800`
- `390 x 844`
- `412 x 915`
- `768 x 1024`
- `1440 x 900`

## Limitation

The browser automation available in this environment cannot force exact mobile viewport sizes. Mobile real-browser acceptance remains a manual staging checklist item.
