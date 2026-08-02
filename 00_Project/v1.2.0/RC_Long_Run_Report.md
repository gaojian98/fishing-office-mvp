# v1.2.0 RC Long Run Report

## Automated Result

PASS for simulated long-run safeguards.

## Covered

- Existing smoke test records office world history across days and enforces bounded history.
- Daily Simulation remains once-per-day.
- Duplicate Daily Summary does not append twice on same day.
- Salary and promotion duplicate guards are covered by existing career tests.
- Event cooldown and non-repeatable behavior are covered by dynamic event tests.
- RC save tests verify long-lived guard fields serialize and restore.

## Limits

- 7 / 30 / 90 day behavior is represented by automated smoke loops and serialization checks, not by real-time browser soak testing.
