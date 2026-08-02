# Browser Console Report

## Result

PASS for automated local browser console check.

## Environment

- URL: `http://127.0.0.1:3101/#/home`
- Browser: Codex in-app Chrome bridge
- Date: 2026-08-03 UTC+07

## Console Findings

- Home initial load: 0 errors.
- 9 home entry click checks: 0 errors.
- Dialog close and return checks: 0 errors.
- Fishing wait and result checks: 0 errors.
- Sell / put-into-bag checks: 0 errors.

## Non-error Logs

- Flutter bootstrap debug log was observed.
- No red Console errors were observed during the automated run.

## Limitation

The automation reads Chrome bridge dev logs. Product owner should still perform one visual manual pass in a normal browser before staging deployment.
