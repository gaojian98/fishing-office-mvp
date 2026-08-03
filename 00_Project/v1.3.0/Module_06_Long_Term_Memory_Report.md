# Module 06 Long-Term Memory Report

## Status

IMPLEMENTED - WAITING FOR REVIEW

## Scope

Module 06 extends the existing Resident Memory ownership boundary with bounded long-term memories.

No new top-level Manager, Engine, Repository, Runtime, Provider, page, or JSON type is introduced.

## Implemented Model Changes

`ResidentMemoryRecord` now supports:

- `longTermMemories`

`LongTermResidentMemory` includes:

- `memoryId`
- `residentId`
- `type`
- `sourceId`
- `participants`
- `summary`
- `importance`
- `createdAt`
- `expiresAt`
- `effect`

`ResidentMemorySummary` includes:

- `residentId`
- `total`
- `importantCount`
- `recentSummaries`
- `tags`
- `byType`

## Runtime Behavior

`ResidentMemoryEngine` now provides:

- `recordLongTermMemory(...)`
- `compactLongTermMemories(...)`
- `getResidentMemorySummary(id)`

Long-term memory rules:

- duplicate `sourceId` for the same resident returns the existing memory
- low-importance expired memories can be removed
- low-importance older memories can decay
- important memories are retained ahead of low-importance memories
- each resident keeps at most 60 long-term memories
- summaries are provided for AI Decision and future consumers

## Runtime Integration

AI Decision reads `ResidentMemorySummary` through `ResidentMemoryEngine` when available.

Dialogue and Story continue to read the owning memory record and memory tags; they do not reimplement long-term memory rules.

## Save Compatibility

Long-term memory is stored inside existing `residentMemory` save data.

Old saves without `longTermMemories` load as empty collections.

No existing save key is renamed.

## Tests

Added coverage in `framework_smoke_test.dart` for:

- creating long-term memory
- duplicate `sourceId`
- expiration
- decay
- capacity limit
- important memory retention
- memory summary
- save/restore through `ResidentMemoryConfig`
- old-save fallback
- 100 resident memory summaries

## Performance

Long-term memory is accessed per resident through summary APIs. AI Decision does not scan all long-term histories.

## Known Limits

- No memory UI is included.
- Compression is currently represented by bounded retention, decay, and summary APIs; future modules may add richer summary text.
- Dedicated test files can be split later if framework smoke tests become too large.
