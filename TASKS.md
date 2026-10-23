# WordSchool PSC — Task Sheet

> **Current phase:** Phase 1 — PSC Crossword
> **Branch:** `development` · **Last updated:** 2026-10-22
> **Specs:** [Firebase design](docs/firebase/FIREBASE_DESIGN.md) · [Screen specs](design/screens/psc-crossword.md) · [Conventions](CLAUDE.md)

This file is the single source of truth for project work. The **status board** below is the only place a task's status is written; the **task cards** further down hold the details and stay stable.

---

## How to use this file

**Status values** (edit only the board):

| Status | Meaning |
| --- | --- |
| `todo` | Not started |
| `doing` | Someone (or Claude) is on it — only one `doing` per person |
| `review` | Code done, waiting for review / manual test |
| `done` | Merged to `development` and checked |
| `blocked` | Waiting on a decision or another task — say why in Notes |

**Working with Claude Code / Cursor**

- "**Start CW-019**" → Claude reads the card, sets it to `doing`, follows the matching skill, and checks every "Done when" box before setting `review`.
- "**What's next?**" → Claude picks the first `todo` task whose dependencies are all `done` (skill: `task-workflow`).
- One task = one branch = one PR: `feat/CW-019-submit-crossword` → PR into `development`, title `CW-019: submitCrossword callable`.
- At the end of a work day, add a short entry to `daily update/YYYY-MM-DD.md` (what changed, why, files).

**Adding a task:** next free number in its milestone block, add a row to the board **and** a card. Never reuse an ID.

**Estimates** are focused working days (d) for one developer.

---

## Status board

### M0 · Foundations — target 2026-10-31

| ID | Task | Area | Est | Depends | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CW-001 | Untrack `.env*` files from git | ops | 0.25d | — | todo | |
| CW-002 | Decide environment setup (DEC-002) | ops | 0.25d | — | todo | Decision needed |
| CW-003 | Add AI kit to repo (CLAUDE.md, rules, skills, docs) | ops | 0.25d | — | todo | |
| CW-004 | Crossword collection constants (Dart + TS) | app, functions | 0.25d | — | todo | |
| CW-005 | Remote Config keys for crossword | app | 0.5d | — | todo | |
| CW-006 | Crossword feature gate | app | 0.5d | CW-005 | todo | |

### M1 · Backend: rules, indexes, functions — target 2026-11-14

| ID | Task | Area | Est | Depends | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CW-010 | Firestore rules + emulator rules tests | rules | 1.5d | CW-004 | todo | |
| CW-011 | Indexes + field overrides | rules | 0.25d | — | todo | |
| CW-012 | Shared TS types for crossword | functions | 0.5d | CW-004 | todo | |
| CW-013 | Grid validator + tests | functions | 1.5d | CW-012 | todo | |
| CW-014 | Answer encoding (TS + Dart, same algorithm) | functions, app | 0.5d | — | todo | |
| CW-015 | `adminSaveCategory` | functions | 0.5d | CW-012 | todo | |
| CW-016 | `adminSaveQuestion` + `adminVerifyQuestion` | functions | 1d | CW-012 | todo | |
| CW-017 | `adminSaveCrosswordPuzzle` | functions | 1d | CW-013, CW-014, CW-016 | todo | |
| CW-018 | `adminSetPuzzleStatus` + `adminScheduleDaily` | functions | 1d | CW-017 | todo | |
| CW-019 | `submitCrossword` (scoring, XP, leaderboard, mistakes) | functions | 2d | CW-013, CW-017 | todo | |
| CW-020 | `crosswordDailyRollover` scheduled job | functions | 0.5d | CW-018 | todo | |
| CW-021 | `refreshLeaderboardTop` scheduled job | functions | 0.5d | CW-019 | todo | |
| CW-022 | `adminListReports` + `adminResolveReport` | functions | 0.5d | CW-012 | todo | |
| CW-023 | Export, deploy to dev DB, smoke test | functions | 0.5d | CW-015…CW-022 | todo | |

### M2 · Admin panel (Flutter web) — target 2026-11-28

| ID | Task | Area | Est | Depends | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CW-030 | `AdminApiService` crossword methods + models | admin | 1d | CW-023 | todo | |
| CW-031 | Categories page | admin | 0.5d | CW-030 | todo | |
| CW-032 | Question bank page (list, add/edit, verify) | admin | 1.5d | CW-030 | todo | |
| CW-033 | Puzzle builder (grid editor + live validation) | admin | 3d | CW-030, CW-014 | todo | Biggest admin task |
| CW-034 | Puzzle preview, status workflow, schedule calendar | admin | 1d | CW-033 | todo | |
| CW-035 | Reports page | admin | 0.5d | CW-030 | todo | |
| CW-036 | Import questions / puzzles from JSON | admin | 1d | CW-032, CW-033 | todo | Saves typing for content team |

### M3 · Player app (Flutter) — target 2026-12-19

| ID | Task | Area | Est | Depends | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CW-040 | Domain entities | app | 1d | — | todo | |
| CW-041 | Models, data sources, `CrosswordRepository` | app | 1.5d | CW-040, CW-004 | todo | |
| CW-042 | Use cases + DI registration | app | 0.5d | CW-041 | todo | |
| CW-043 | Grid engine (pure Dart) + unit tests | app | 2d | CW-040, CW-014 | todo | |
| CW-044 | Crossword Home page | app | 1.5d | CW-042 | todo | |
| CW-045 | Category puzzle list (paged) | app | 1d | CW-042 | todo | |
| CW-046 | Puzzle screen (grid, clue bar, chips, keyboard, timer) | app | 3d | CW-043 | todo | |
| CW-047 | Progress autosave (pause / leave / 30 s) | app | 0.5d | CW-046 | todo | |
| CW-048 | Hints sheet (clue, letter, word, rewarded ad) | app | 1.5d | CW-046 | todo | |
| CW-049 | Submit + Results page | app | 1.5d | CW-046, CW-019 | todo | |
| CW-050 | My mistakes / Revise list | app | 1d | CW-049 | todo | |
| CW-051 | Crossword weekly leaderboard | app | 1d | CW-021 | todo | |
| CW-052 | "Report a wrong answer" flow | app | 0.5d | CW-046 | todo | |
| CW-053 | Analytics events | app | 0.5d | CW-046 | todo | |
| CW-054 | Routing, dashboard entry, feature gate wiring | app | 0.5d | CW-006, CW-044 | todo | |

### M4 · Content — target 2026-12-26 (runs in parallel from M2)

| ID | Task | Area | Est | Depends | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CW-060 | Seed 5 categories | content | 0.25d | CW-031 | todo | |
| CW-061 | 150 verified questions (30 × 5 categories) | content | ongoing | CW-032 | todo | |
| CW-062 | 14 daily puzzles + 10 per category | content | ongoing | CW-033, CW-061 | todo | |
| CW-063 | Second-person fact-check pass | content | 1d | CW-062 | todo | |

### M5 · QA & launch — target 2027-01-09

| ID | Task | Area | Est | Depends | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CW-070 | CI: analyze, tests, lint, rules tests | ops | 1d | CW-010 | todo | |
| CW-071 | Manual test scenarios doc | qa | 0.5d | CW-049 | todo | |
| CW-072 | App Check enforcement | ops | 0.5d | CW-023 | todo | |
| CW-073 | Budget alerts ($10 / $25) | ops | 0.1d | — | todo | |
| CW-074 | Production deploy + content seed | ops | 0.5d | M1–M4 | todo | |
| CW-075 | Store release | ops | 1d | CW-074 | todo | |

### Backlog — Phase 2 and later (not scheduled)

| ID | Task | Area | Notes |
| --- | --- | --- | --- |
| MAP-001 | Kerala Map Challenge — data model (`mapChallenges`) | functions | Design ready: `design/screens/kerala-map-challenge.md` |
| MAP-002 | Map asset pipeline (DataMeet → app SVG paths) | app | Source data in `design/assets/kerala-map/` |
| MAP-003 | Draw the River mode | app | |
| MAP-004 | Explore the Western Ghats mode | app | |
| MAP-005 | Build Kerala (drag districts) mode | app | |
| MAP-006 | `submitMapChallenge` scoring | functions | |
| NEXT-001 | Clue Wordle (question-driven Wordle) | app | Reuses `pscQuestions` |
| NEXT-002 | Malayalam UI and Malayalam crossword | app | Bilingual fields already in schema |
| NEXT-003 | Spaced repetition on `revisionItems.nextReviewAt` | app, functions | |
| NEXT-004 | Overall XP leaderboard `xp-{week}` | functions | |
| NEXT-005 | Exam packs (LDC / LGS / Degree) + Pro pass | app | Monetization |

---

## Decisions

| ID | Decision | Status | Choice / recommendation |
| --- | --- | --- | --- |
| DEC-001 | Daily puzzle date key timezone | Proposed | **IST (Asia/Kolkata)** for crossword. Existing Wordle/Story use UTC (`DateHelper.todayUtcDateId`) — keep those as they are; add `DateHelper.todayIstDateId()`. |
| DEC-002 | Environments | **Open** | Today: one project `wordschool-dev`, dev = named DB `development`, prod = `(default)`. Recommended before public launch: separate `wordschool-prod` project. Until then, every admin callable must keep accepting `databaseId` like the existing ones. |
| DEC-003 | Answers on the client | Accepted | Puzzle doc carries **encoded** answers for offline Check/Reveal; real key in private `crosswordSolutions`; server re-scores. |
| DEC-004 | Answer alphabet | Accepted | Phase 1 answers are English A–Z only; Malayalam crossword is NEXT-002. |
| DEC-005 | Bloc style for new code | Accepted | `sealed class` events/states in one bloc file (like `leaderboard_bloc.dart`) — no new freezed code. |

---

## Task cards

### M0 · Foundations

#### CW-001 · Untrack `.env*` files from git
`.gitignore` lists `.env`, but `.env`, `.env.dev`, `.env.prod` are tracked.
- Run `git rm --cached .env .env.dev .env.prod`; keep `.env.example` tracked; add `.env.*` and `!.env.example` to `.gitignore`.
- If any real secret was ever committed, rotate it.

Done when:
- [ ] `git ls-files | grep .env` shows only `.env.example`
- [ ] README "Quick Start" says to copy `.env.example`

#### CW-002 · Decide environment setup (DEC-002)
Choose between keeping the dual-database setup or creating `wordschool-prod`. Record the choice in **Decisions**.

Done when:
- [ ] DEC-002 status is Accepted with the choice written down
- [ ] If split: CW-074 card updated with the new project id

#### CW-003 · Add AI kit to repo
Copy `CLAUDE.md`, `.cursor/rules/`, `.claude/`, `docs/`, `design/`, `TASKS.md` into the repo root.

Done when:
- [ ] Claude Code lists the skills (`/` menu) and Cursor shows the rules
- [ ] Committed on `chore/CW-003-ai-kit`

#### CW-004 · Crossword collection constants
Add every crossword collection name to `lib/core/firebase/collections.dart` and to a new `functions/src/crossword/collections.ts`. No string literals for collection names anywhere else.

Done when:
- [ ] Constants: `crosswordCategories`, `crosswordPuzzles`, `crosswordSolutions`, `crosswordDaily`, `pscQuestions`, `crosswordProgress`, `revisionItems`, `leaderboards`, `contentReports`

#### CW-005 · Remote Config keys
Add defaults + typed getters (pattern: `lib/core/remote_config/story_mode_config.dart`).

Done when:
- [ ] `crossword_enabled` (bool, default false), `crossword_rollout_percent` (int, default 0 — same `isEnabledForUser` pattern as Story Mode), `crossword_hint_penalties` (JSON `{"letter":5,"word":15}`), `xp_level_formula` (JSON `{"base":100,"growth":1.25}`), `crossword_autosave_seconds` (int, 30)

#### CW-006 · Crossword feature gate
Mirror `StoryModeFeatureGate`: hide the Crossword entry and redirect deep links when `crossword_enabled` is false.

Done when:
- [ ] Widget test: entry hidden when disabled

### M1 · Backend

#### CW-010 · Firestore rules + rules tests
Add the rules in `docs/firebase/FIREBASE_DESIGN.md#security-rules` to `firestore.rules`. Add `@firebase/rules-unit-testing` to `functions` dev deps and a `rules.test.ts` that runs on the emulator.

Done when:
- [ ] Tests prove: player **cannot** read `crosswordSolutions` or `pscQuestions`; **cannot** read a `draft` puzzle; **cannot** write any content collection; **cannot** lower `elapsedSec`/hints; **cannot** edit a `completed` progress doc; **can** create a valid report but not read it
- [ ] Existing rules unchanged in behaviour (current tests still pass)

#### CW-011 · Indexes + field overrides
Merge the JSON in the design doc into `firestore.indexes.json`.

Done when:
- [ ] `firebase deploy --only firestore:indexes` succeeds on dev; indexes show "Enabled"

#### CW-012 · Shared TS types
`functions/src/crossword/types.ts`: `CrosswordCategory`, `PscQuestion`, `CrosswordPuzzle`, `CrosswordWord`, `CrosswordProgress`, `CrosswordResult`, `RevisionItem`, `LeaderboardEntry`, `ContentReport`, plus enums as string unions. Field names exactly as the design doc.

Done when:
- [ ] `npm run build` passes; no `any`

#### CW-013 · Grid validator
`functions/src/crossword/validatePuzzle.ts` — pure function, throws `PuzzleValidationError` listing **all** problems. Same checks as `.claude/skills/crossword-content/scripts/validate_crossword.py`.

Done when:
- [ ] Checks: layout length = rows×cols; every word fits and starts on `.`; crossing letters agree; every `.` cell is in ≥1 word; no 2+ letter run without a word; answers `^[A-Z]{2,}$`; ids = `{number}{A|D}`; numbering follows standard order
- [ ] Jest tests for each failure + the example puzzle passes

#### CW-014 · Answer encoding
One reversible encoding shared by TS and Dart: `answerEnc = base64(utf8(answer) XOR utf8(puzzleId + ":" + wordId))`, key repeated. **Obfuscation, not security.** Reference implementation: `.claude/skills/crossword-content/scripts/validate_crossword.py --encode`.

Done when:
- [ ] `encodeAnswer`/`decodeAnswer` in TS + Dart, both with tests using the same fixtures, including `VAIKOM` / `kerala-history-0012` / `2D` → `PSQ7KiMs`

#### CW-015 · `adminSaveCategory`
Admin callable. Upsert by slug; validates slug `^[a-z0-9-]+$`, `name.en` required, `order` int.

Done when:
- [ ] `assertAdmin`, `parseDatabaseId`, `writeAuditLog` used (see existing `functions/src/admin/`)
- [ ] Unit test for validation

#### CW-016 · `adminSaveQuestion` + `adminVerifyQuestion`
Create/edit `pscQuestions`; answer normalized (uppercase, strip spaces/hyphens) and must match `^[A-Z]{2,}$`; `source` required. Verify sets `status: verified`, `verifiedBy`, `verifiedAt`. Editing a verified question sets it back to `draft`.

Done when:
- [ ] Tests: normalization, missing source rejected, re-edit resets status

#### CW-017 · `adminSaveCrosswordPuzzle`
Input: puzzle without `answerEnc`, with `answer` per word. Steps: load all `questionId`s (must be `verified`), run validator, encode answers, write puzzle (`status: draft`) + `crosswordSolutions/{id}` in **one batch**, add puzzle id to each question's `usedInPuzzles`. New puzzles get the next `number` in the category.

Done when:
- [ ] Rejects unverified questions and invalid grids with readable errors
- [ ] Re-saving a `published` puzzle is refused (must archive → copy)

#### CW-018 · `adminSetPuzzleStatus` + `adminScheduleDaily`
State machine: `draft→in_review→scheduled→published→archived`, plus `in_review→draft` and `in_review→published` (publish now). Publishing sets `publishedAt` and increments `crosswordCategories.publishedPuzzleCount` (transaction); archiving decrements. `adminScheduleDaily({dateId, puzzleId})` writes `crosswordDaily/{dateId}` summary; puzzle must be `scheduled` or `published`.

Done when:
- [ ] Tests for every allowed and refused transition

#### CW-019 · `submitCrossword`
Player callable. Input `{puzzleId, letters, elapsedSec}`. See design doc "Player: finish a puzzle".
- Idempotent: if progress is `completed`, return stored result.
- Score: per word correct/incorrect from `crosswordSolutions`; XP = `xpReward` − penalties (Remote Config defaults mirrored server-side) − 0 floor; revealed words count as wrong for revision.
- Plausibility: refuse `elapsedSec < wordCount × 2`; rate limit 30/hour/user (counter on `userGameStates`).
- One batch: progress result, `userGameStates.xp` + `crossword` stats (streak by IST date), leaderboard entry `crossword-{isoWeek}`, `revisionItems` upserts.

Done when:
- [ ] Jest tests: scoring, penalties, idempotency, streak continue/reset, rejection cases
- [ ] Emulator test: full submit writes all 4 places

#### CW-020 · `crosswordDailyRollover`
`onSchedule("5 0 * * *", timeZone: "Asia/Kolkata")`: publish puzzles whose `publishAt ≤ now`; warn (log error) if tomorrow has no `crosswordDaily` doc.

Done when:
- [ ] Unit test for the selection logic; manual run on dev

#### CW-021 · `refreshLeaderboardTop`
`onSchedule("every 15 minutes")`: for the current week's crossword board, read top 50 entries and write `top50` + `updatedAt` on the parent doc.

Done when:
- [ ] Reads ≤ 50 docs per run (check in logs)

#### CW-022 · Reports callables
`adminListReports({status, limit})`, `adminResolveReport({reportId, status, note})`.

Done when:
- [ ] Audit log written on resolve

#### CW-023 · Export, deploy, smoke test
Export from `functions/src/index.ts` (keep alphabetical inside the crossword block). Deploy rules, indexes, functions to dev.

Done when:
- [ ] Admin panel (dev DB) can create a category → question → puzzle → publish; app account can submit and see result

### M2 · Admin panel

#### CW-030 · `AdminApiService` crossword methods
Add typed methods for every crossword callable using the existing `_call` helper (sends `databaseId`). Models in `lib/features/admin/domain/models/`.

Done when:
- [ ] Each method has `fromJson` model; errors surface as snackbars

#### CW-031 · Categories page
List, add/edit, reorder (`order`), toggle `isActive`.

#### CW-032 · Question bank page
Filter by subject + status; add/edit form (answer, display EN/ML, clues, fact, examTags, difficulty, source); Verify button.

Done when:
- [ ] Prod environment shows the existing `ProdConfirmDialog` before any write

#### CW-033 · Puzzle builder
Grid editor (rows/cols up to 15×15), place a verified question across/down at a cell, auto-numbering, crossing conflicts highlighted, validator errors listed live (port of CW-013 in Dart or call a dry-run flag on `adminSaveCrosswordPuzzle`).

Done when:
- [ ] The example puzzle in `.claude/skills/crossword-content/examples/` can be rebuilt in the builder
- [ ] Save works only when the validator is clean

#### CW-034 · Preview, workflow, schedule
Preview renders the puzzle as the player sees it; buttons for each allowed status move; calendar of `crosswordDaily` for the next 30 days with empty days flagged.

#### CW-035 · Reports page
Open reports with links to the puzzle/question; resolve with note.

#### CW-036 · Import from JSON
Upload a `content/questions/*.json` or `content/puzzles/*.json` file (shapes in `.claude/skills/crossword-content/examples/`). Show a preview with validation errors, then call `adminSaveQuestion` / `adminSaveCrosswordPuzzle` per item. `draftNotes` is dropped; imported questions stay `draft`.

Done when:
- [ ] Both example files import cleanly into the dev DB
- [ ] Re-importing the same file updates instead of duplicating (match on `answer` + `subject` for questions, `id` for puzzles)

### M3 · Player app

#### CW-040 · Domain entities
`lib/features/crossword/domain/entities/`: `CrosswordCategoryEntity`, `CrosswordPuzzleEntity`, `CrosswordWordEntity`, `CrosswordDailyEntity`, `CrosswordProgressEntity`, `CrosswordResultEntity`, `RevisionItemEntity`, `LocalizedText`. Equatable, immutable.

Done when:
- [ ] Generated with the `flutter-feature` skill; no Firebase imports in domain

#### CW-041 · Data layer
Models (`fromJson/toJson`, `documentId` param), `CrosswordContentDataSource` (daily, categories, puzzles paged by `number desc` 20/page, puzzle by id) and `CrosswordProgressDataSource` (get, save, submit via `FirebaseFunctions`), `CrosswordRepositoryImpl`. Firestore injected, collection names from `FirebaseCollections`.

Done when:
- [ ] Queries include `isActive == true` / `status == 'published'` (rules require it)
- [ ] Model tests with real-shaped JSON fixtures

#### CW-042 · Use cases + DI
`LoadCrosswordHomeUseCase`, `LoadCategoryPuzzlesUseCase`, `LoadPuzzleUseCase`, `SaveCrosswordProgressUseCase`, `SubmitCrosswordUseCase`, `LoadRevisionItemsUseCase`, `SetRevisionMasteredUseCase`, `ReportContentUseCase`. Register in `di.dart` → `_initializeCrossword()`.

#### CW-043 · Grid engine
Pure Dart in `domain/utils/crossword_grid.dart`: parse layout, cell→word lookup, next/prev cell, tap-twice direction toggle, backspace behaviour, check (per cell correct/wrong), reveal letter/word, `isSolved`. Uses decoded answers.

Done when:
- [ ] ≥ 90% line coverage on the engine; the example puzzle is used in tests

#### CW-044 · Crossword Home
Matches `design/screens/psc-crossword.md#1-home`: daily card, categories grid with progress, streak chip, EN/ML toggle (EN only works in phase 1).

#### CW-045 · Category list
Paged list (20), puzzle number, title, difficulty, solved state from progress.

#### CW-046 · Puzzle screen
Matches `#2-puzzle`. Grid, active word highlight, clue bar with prev/next, clue chips, on-screen keyboard, timer, Check.

Done when:
- [ ] Works on 360 px wide screens; touch targets ≥ 44 px
- [ ] Golden or widget test for the active-word highlight

#### CW-047 · Progress autosave
Save on `AppLifecycleState.paused`, on route pop, and every `crossword_autosave_seconds` if dirty. Never per keystroke.

Done when:
- [ ] Log shows ≤ 1 write per 30 s during continuous typing

#### CW-048 · Hints sheet
Matches `#3-hints`. Show clue (free), reveal letter (1 hint), reveal word (3 hints), rewarded ad (+1) via existing `AdService`; uses `hintPackBalance`; increments `hintsUsed` locally.

#### CW-049 · Submit + Results
Matches `#4-results`. Calls `submitCrossword`, shows score, time, correct/total, XP, streak, level bar (level from `xp_level_formula`), mistakes with facts. No extra reads after submit.

#### CW-050 · My mistakes / Revise
List `revisionItems` where `mastered == false` newest first; swipe or button to mark mastered.

#### CW-051 · Crossword leaderboard
Read `leaderboards/crossword-{isoWeek}` `top50`; own rank via `count()` query. Add a tab to the existing leaderboard page.

#### CW-052 · Report a wrong answer
From the clue bar overflow menu: reason + optional message → `contentReports`.

#### CW-053 · Analytics
Events in `lib/core/analytics/analytics_events.dart`: `crossword_open`, `crossword_start`, `crossword_hint` (type), `crossword_check`, `crossword_submit` (score, time), `crossword_report`.

#### CW-054 · Routing + entry
Routes under `/crossword` (home), `/crossword/category/:id`, `/crossword/puzzle/:id`, `/crossword/puzzle/:id/result`, `/crossword/revise`. Dashboard card behind the feature gate.

### M4 · Content

#### CW-060 · Seed categories
`kerala-history`, `indian-history`, `constitution`, `geography`, `science` (order 10–50).

#### CW-061 · Question bank
30 verified questions per category with `source` filled (PYQ year or book + page). Use the `crossword-content` skill to draft; a human verifies every fact.

#### CW-062 · Puzzles
14 daily puzzles scheduled + 10 per category published. Every puzzle passes the validator.

#### CW-063 · Fact-check pass
A second person checks every published answer and fact; fixes logged in the audit log.

### M5 · QA & launch

#### CW-070 · CI
GitHub Actions on PRs to `development`: `fvm flutter analyze`, `fvm flutter test`, `npm --prefix functions run lint`, `npm --prefix functions test`, rules tests on the emulator.

#### CW-071 · Manual test scenarios
`technical_doc/crossword/manual-testing-scenarios.md` (same format as story mode's).

#### CW-072 · App Check
Play Integrity (Android) + App Attest (iOS); enforce on Firestore and callable functions after 1 week of monitoring.

#### CW-073 · Budget alerts
Google Cloud Billing alerts at $10 and $25 / month.

#### CW-074 · Production deploy
Rules → indexes → functions → seed content → set `crossword_enabled=true` and raise `crossword_rollout_percent` 10 → 50 → 100 over a week.

#### CW-075 · Store release
Version bump, changelog, new screenshots (crossword), listing text update in `assets/playstore/` and `assets/appstore/`.
