# Relationship API

## Responsibilities

- Read and update relationship state
- Expose relationship memory summaries

## Current contract

Relationship logic is owned by the core engine and stored in its own database table.
API exposure is reserved for future pages and future AI flows.

## Reserved endpoint categories

- Relationship profile list
- Relationship detail
- Relationship memory list
- Relationship level summary
- Emotion state snapshot

## Rules

- Relationship score is internal state.
- UI should consume levels or summaries, not raw score unless explicitly approved.

