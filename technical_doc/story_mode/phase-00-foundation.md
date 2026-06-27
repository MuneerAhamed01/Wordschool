# Phase 0 — Foundation & Data Model

> **Status:** Complete  
> **Last updated:** 2026-06-27  
> **Owner:** —  
> **Depends on:** —  
> **Blocks:** Phase 1, Phase 2  

## Goal

Define domain models, Firestore schema, security rules, and routing so Story Mode has a clear data contract before backend or UI work begins.

## Scope

### In scope

- Domain entities for cases, clues, progress, and outcomes
- Firestore collection design and security rules
- Game mode / route separation from daily Wordle

### Out of scope (deferred)

- Cloud Functions and AI generation (Phase 1)
- UI screens (Phase 3)
- Scoring logic implementation (Phase 5)

## Steps checklist

- [x] **Step 0.1** — Define domain models (`DetectiveCase`, `DetectiveClue`, `CaseOutcome`, `StoryModeProgress`)
- [x] **Step 0.2** — Design Firestore schema (`detectiveCases/{date}`, user progress docs)
- [x] **Step 0.3** — Write Firestore security rules (cases read-only; progress user-scoped)
- [x] **Step 0.4** — Add `GameMode.story` or dedicated story routes (separate from daily/archive)

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Case document ID | `yyyy-MM-dd` | Aligns with daily global case pattern | — |
| Clue types enum | `location`, `weapon`, `suspect` | Matches product spec in fulldoc.md | — |
| Feature module path | `lib/features/story_mode/` | Matches existing feature folder convention | — |
| Progress collection | `userStoryProgress/{userId}/cases/{date}` | Separate shape and rules from daily `userGameData` | 2026-06-18 |
| `clueGuesses` Firestore shape | Map keyed by clue index (`"0"`, `"1"`, `"2"`) | Firestore rejects nested arrays; Dart model stays `List<List<String>>` | 2026-06-27 |
| Case rollover timezone | UTC via `DateHelper.todayUtcDateId()` | Global same-day case; daily Wordle stays device-local | 2026-06-18 |
| Outcome Firestore values | snake_case (`case_closed`, etc.) | Consistent with security rule validation | 2026-06-18 |
| Story routing | Dedicated `/story` route + `GameMode.story` | Multi-screen flow separate from `/game` query params | 2026-06-18 |

## Domain model sketch

### `DetectiveCase`

| Field | Type | Notes |
| ----- | ---- | ----- |
| `id` | `String` | Date key, e.g. `2026-06-18` |
| `title` | `String` | Case headline |
| `introduction` | `String` | Opening narrative |
| `clues` | `List<DetectiveClue>` | Exactly 3, ordered |
| `resolution` | `String` | Final story when all clues done |
| `createdAt` | `DateTime` | Server timestamp |

### `DetectiveClue`

| Field | Type | Notes |
| ----- | ---- | ----- |
| `index` | `int` | 0, 1, or 2 |
| `type` | `ClueType` | location / weapon / suspect |
| `hint` | `String` | Pre-puzzle story hint |
| `answer` | `String` | 5-letter Wordle answer (uppercase) |
| `reaction` | `String` | Post-puzzle narrative |
| `investigatePrompt` | `String` | CTA copy before Wordle |

### `StoryModeProgress` (per user, per date)

| Field | Type | Notes |
| ----- | ---- | ----- |
| `userId` | `String` | Firebase Auth UID |
| `caseId` | `String` | Same as case date |
| `currentClueIndex` | `int` | 0–3 (3 = all clues processed) |
| `clueAttempts` | `List<int>` | Attempts used per clue (length 3) |
| `clueGuesses` | `List<List<String>>` (Dart) / `map<string, string[]>` (Firestore) | Guess history per clue; map keys `"0"`–`"2"` because Firestore forbids nested arrays |
| `clueSolved` | `List<bool>` | Whether each clue was solved |
| `totalScore` | `int` | 0–300 |
| `outcome` | `CaseOutcome?` | Set on completion |
| `completedAt` | `DateTime?` | Null until case finished |

### `CaseOutcome`

| Value | Requirement |
| ----- | ----------- |
| `caseClosed` | All 3 clues solved |
| `coldCase` | 2 clues solved |
| `unsolved` | 1 clue solved |
| `dismissed` | 0 clues solved |

## Firestore schema

```
detectiveCases/{yyyy-MM-dd}
  ├── title: string
  ├── introduction: string
  ├── resolution: string
  ├── clues: array[3]
  │     ├── index, type, hint, answer, reaction, investigatePrompt
  └── createdAt: timestamp

userStoryProgress/{userId}/cases/{yyyy-MM-dd}
  ├── currentClueIndex: number
  ├── clueAttempts: number[3]
  ├── clueGuesses: map          // keys "0" | "1" | "2" → string[] (NOT nested arrays)
  │     ├── "0": string[]
  │     ├── "1": string[]
  │     └── "2": string[]
  ├── clueSolved: boolean[3]
  ├── totalScore: number
  ├── outcome: string | null
  └── completedAt: timestamp | null
```

### Firestore constraint: no nested arrays

Firestore allows arrays of primitives but **not** arrays inside arrays. The Dart domain model uses `List<List<String>>` for ergonomics, but `StoryModeProgressModel.toJson()` converts to a map before any write:

```json
"clueGuesses": {
  "0": ["CRANE", "STUDY"],
  "1": [],
  "2": []
}
```

`fromJson()` accepts both the map format (current) and the legacy nested-array list (read-only compat). Writing nested arrays crashes the native SDK with `FIRInvalidArgumentException: Nested arrays are not supported`.

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/features/story_mode/domain/entities/` | New — case, clue, progress entities + validators |
| `lib/features/story_mode/data/models/` | New — Firestore/JSON serialization |
| `lib/features/story_mode/presentation/pages/story_home_page.dart` | New — `/story` placeholder |
| `lib/core/enums/game_mode.dart` | Extend with `story` |
| `lib/core/firebase/collections.dart` | Add `detectiveCases`, `userStoryProgress`, `storyCases` |
| `lib/core/utils/date_helper.dart` | Add `todayUtcDateId()`, `isFutureUtcDateId()` |
| `lib/core/routes/app_router.dart` | Register `/story` route |
| `firestore.rules` | New rules for story collections |
| `test/features/story_mode/data/models/` | Unit tests for model round-trips |
| `technical_doc/story_mode/seed-case.example.json` | Dev seed case example |

## Acceptance criteria

- [x] Entities are defined and serializable (JSON / Firestore)
- [x] Security rules prevent users from writing global cases
- [x] Story routes do not interfere with existing daily/archive game flow
- [x] Seed case document can be written manually for dev testing

## Testing notes

- Unit tests for entity serialization/deserialization — **done** (`test/features/story_mode/data/models/`)
- Firestore rules emulator: verify read case, write own progress, deny write case — **manual** (deploy rules, then verify in Console/emulator)

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-18 | Steps 0.1–0.4 | Entities, models, collections, UTC helpers, rules, `/story` stub, 8 unit tests |
| 2026-06-27 | Schema fix | Document + implement `clueGuesses` map shape for Firestore compatibility |

## Open questions / blockers

_Resolved:_

- **Progress storage:** separate `userStoryProgress` collection (not `userGameData`)
- **Case rollover:** UTC via `DateHelper.todayUtcDateId()`

## Dev seed case

Use [seed-case.example.json](./seed-case.example.json). In Firebase Console, create document `detectiveCases/2026-06-18` and paste fields. Set `createdAt` as a Firestore timestamp. Client writes are blocked by rules — use Console or Admin SDK only.
