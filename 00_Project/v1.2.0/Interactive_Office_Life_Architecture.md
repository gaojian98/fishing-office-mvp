# Interactive Office Life Architecture

## Entry
Profile Center opens `office_hub` through `DialogManager`.

## Flow
`Profile Center`
-> `DialogManager`
-> `OfficeHubDialog`
-> Providers
-> `SecondWorldEngine`
-> existing runtimes and save state.

## Runtime Boundary
No UI calls resident, relationship, event, dialogue, story, career, skill, or save runtimes directly. UI reads `InteractiveOfficeSnapshot` and submits `PlayerActionRequest`.

## Snapshot Content
- Current office state
- Player influence and reputation
- Career and skills
- Nearby and available residents
- Active groups
- Available/current events
- Story and rumor hints
- Recent office history
- Safe daily summary fallback

## Action Content
- Resident actions
- Group actions
- Event actions
- Promotion action
- Duplicate action protection
- Safe blocked results

## Compatibility
The feature adds a facade and models over existing runtime state. It does not create new persistence format requirements beyond already compatible save fields.
