# Kerala PSC App — Task Sheet

> **Current phase:** Phase 1 — PSC Crossword
> **Branch:** `psc-dev` · **Firebase (dev):** `kerala-pcs-dev` · **Last updated:** 2026-10-25
> **Specs:** [Firebase design](docs/firebase/FIREBASE_DESIGN.md) · [Screen specs](design/screens/psc-crossword.md) · [Conventions](CLAUDE.md)

This file is the single source of truth for project work. The **status board** below is the only place a task's status is written; the **task cards** further down hold the details and stay stable.

> **Re-baselined 2026-10-23 for** `psc-dev`**.** This branch is a fresh, slim app (auth + daily word game) on its own Firebase project. Unlike `development`, it has no Cloud Functions, admin panel, web target, tests, Remote Config or analytics yet, so M0 now sets those up first.

---



## How to use this file

**Status values** (edit only the board):


| Status    | Meaning                                                    |
| --------- | ---------------------------------------------------------- |
| `todo`    | Not started                                                |
| `doing`   | Someone (or Claude) is on it — only one `doing` per person |
| `review`  | Code done, waiting for review / manual test                |
| `done`    | Merged to `psc-dev` and checked                            |
| `blocked` | Waiting on a decision or another task — say why in Notes   |
| `not-needed` | Decided not to build (for now) — Notes say why and when to revisit |


**Working with Claude Code / Cursor**

- "**Start CW-019**" → Claude reads the card, sets it to `doing`, follows the matching skill, and checks every "Done when" box before setting `review`.
- "**What's next?**" → Claude picks the first `todo` task whose dependencies are all `done` (skill: `task-workflow`).
- One task = one branch: `feat/CW-019-submit-crossword`. Claude commits only when asked, then pushes the branch; no PRs (the user reviews the pushed branch).
- Note notable changes in `docs/daily/YYYY-MM-DD.md` (what changed, why, files).

**Adding a task:** next free number in its milestone block, add a row to the board **and** a card. Never reuse an ID.

**Estimates** are focused working days (d) for one developer.

---



## Status board



### M0 · Foundations — target 2026-11-04 · **closed 2026-10-23**


| ID     | Task                                                   | Area           | Est   | Depends | Status | Notes                                                                                     |
| ------ | ------------------------------------------------------ | -------------- | ----- | ------- | ------ | ----------------------------------------------------------------------------------------- |
| CW-001 | Untrack `.env*` files from git                         | ops            | 0.25d | —       | done   | b0e1aa3                                                                                   |
| CW-002 | Decide environment setup (DEC-002)                     | ops            | 0.25d | —       | done   | Separate projects; dev = `kerala-pcs-dev`                                                 |
| CW-003 | Add AI kit to repo (incl. `.claude/`, `.cursor/`)      | ops            | 0.25d | —       | done   | `.claude/` + `.cursor/` added; `/` menu + Cursor rules checked                            |
| CW-004 | Crossword collection constants (Dart + Python)         | app, functions | 0.25d | CW-007  | done   | Python–Dart drift test in `collections_test.py`                                           |
| CW-005 | Remote Config (package + typed config class)           | app            | 0.5d  | —       | done   | Offline first launch checked on a device                                                  |
| CW-006 | App shell: bottom navigation + routes                  | app            | 1d    | —       | done   | Play = `/home` (daily word card). Back button + tabs checked on a device                  |
| CW-007 | Create `functions/` codebase (Python) + shared helpers | functions      | 1d    | CW-008  | done   | Python (DEC-010); ruff + 32 pytest green; emulators boot (Java from Android Studio)       |
| CW-008 | Blaze plan, budget alerts, confirm Firestore location  | ops            | 0.25d | —       | done   | `(default)` recreated in `asia-south1` (free tier). Rules + indexes redeployed            |
| CW-009 | Test setup (Flutter `test/`) + first green run         | app            | 0.5d  | —       | done   | 7 model tests green. 6 pre-existing `analyze` issues in `lib/` accepted (no cleanup task) |




### M1 · Backend: rules, indexes, functions — target 2026-11-18 · **closed 2026-10-23**


| ID     | Task                                                             | Area           | Est   | Depends                | Status | Notes                                                                           |
| ------ | ---------------------------------------------------------------- | -------------- | ----- | ---------------------- | ------ | ------------------------------------------------------------------------------- |
| CW-010 | Firestore rules (incl. lock down `users`, `games`) + rules tests | rules          | 2d    | CW-004, CW-007         | done   | 24 rules tests green; deployed to dev                                           |
| CW-011 | Indexes + field overrides                                        | rules          | 0.25d | —                      | done   | + `contentReports` index (CW-022). Deployed to dev                              |
| CW-012 | Shared Python types for crossword                                | functions      | 0.5d  | CW-004                 | done   |                                                                                 |
| CW-013 | Grid validator + tests                                           | functions      | 1.5d  | CW-012                 | done   |                                                                                 |
| CW-014 | Answer encoding (Python + Dart, same algorithm)                  | functions, app | 0.5d  | CW-007, CW-009         | done   | Fixtures in `test/fixtures/`                                                    |
| CW-015 | `adminSaveCategory`                                              | functions      | 0.5d  | CW-012                 | done   |                                                                                 |
| CW-016 | `adminSaveQuestion` + `adminVerifyQuestion`                      | functions      | 1d    | CW-012                 | done   |                                                                                 |
| CW-017 | `adminSaveCrosswordPuzzle`                                       | functions      | 1d    | CW-013, CW-014, CW-016 | done   | Numbers from `lastPuzzleNumber`                                                 |
| CW-018 | `adminSetPuzzleStatus` + `adminScheduleDaily`                    | functions      | 1d    | CW-017                 | done   |                                                                                 |
| CW-019 | `submitCrossword` (scoring, XP, leaderboard, mistakes)           | functions      | 2d    | CW-013, CW-017         | done   | Scoring per DEC-011 (Accepted)                                                  |
| CW-020 | `crosswordDailyRollover` scheduled job                           | functions      | 0.5d  | CW-018                 | done   | Force-run on dev checked 2026-10-23                                             |
| CW-021 | `refreshLeaderboardTop` scheduled job                            | functions      | 0.5d  | CW-019                 | done   |                                                                                 |
| CW-022 | `adminListReports` + `adminResolveReport`                        | functions      | 0.5d  | CW-012                 | done   |                                                                                 |
| CW-023 | Export, deploy to `kerala-pcs-dev`, smoke test                   | functions      | 0.5d  | CW-015…CW-022          | done   | Emulator flow test green; 11 functions live then (16 on 2026-10-25) |
| CW-024 | `setAdminClaim` script + first admin account                     | functions, ops | 0.25d | CW-007                 | done   | [muneerahamed.dev@gmail.com](mailto:muneerahamed.dev@gmail.com) is admin on dev |
| CW-025 | Admin read callables (list/get questions, puzzles + solution)    | functions      | 1d    | CW-017                 | done   | Callables (rules stay closed); deployed with indexes |
| CW-026 | Server hint penalties from Remote Config                         | functions      | 0.5d  | CW-019                 | done   | Deployed; unit-tested. Live RC → XP check moved to CW-071 |




### M2 · Admin panel (Flutter web) — target 2026-12-04 · **closed 2026-10-25**


| ID     | Task                                                                          | Area  | Est  | Depends                | Status | Notes                                |
| ------ | ----------------------------------------------------------------------------- | ----- | ---- | ---------------------- | ------ | ------------------------------------ |
| CW-029 | Admin foundation: web target, `main_admin.dart`, claim login, shell, API base | admin | 1.5d | CW-024                 | done   | Web app on dev; Google popup + claim |
| CW-030 | `AdminApiService` crossword methods + models                                  | admin | 1d   | CW-029, CW-023, CW-025 | done   | Daily docs read via Firestore; services now in `admin/shared/data/data_source/` (CW-058) |
| CW-031 | Categories page                                                               | admin | 0.5d | CW-030                 | done   | Drag to reorder; ID from name        |
| CW-032 | Question bank page (list, add/edit, verify)                                   | admin | 1.5d | CW-030                 | done   | "Mark as checked" = verify           |
| CW-033 | Puzzle builder (grid editor + live validation)                                | admin | 3d   | CW-030, CW-014         | done   | Dart port of the validator           |
| CW-034 | Puzzle preview, status workflow, schedule calendar                            | admin | 1d   | CW-033                 | done   | 30-day calendar, IST times           |
| CW-035 | Reports page                                                                  | admin | 0.5d | CW-030                 | done   | + `adminGetQuestion`; deployed 2026-10-25 |
| CW-036 | Import questions / puzzles from JSON                                          | admin | 1d   | CW-032, CW-033         | done   | + CSV for questions                  |




### M3 · Player app (Flutter) — target 2026-12-24 · **closed 2026-10-25** · plan `docs/plans/M3-player-app.md` · QA `docs/qa/M3-manual-test.md`


| ID     | Task                                                   | Area       | Est  | Depends        | Status  | Notes                           |
| ------ | ------------------------------------------------------ | ---------- | ---- | -------------- | ------- | ------------------------------- |
| CW-040 | Domain entities                                        | app        | 1d   | CW-009         | done    | + `Paged`, `PuzzleSession`, `ContentReport` |
| CW-041 | Models, data sources, `CrosswordRepository`            | app        | 1.5d | CW-040, CW-004 | done    | One data source per module + shared progress cache (CW-058); JSON fixtures |
| CW-042 | Use cases + DI registration                            | app        | 0.5d | CW-041         | done    | + category, leaderboard, change-stream use cases; `initCrossword(getIt)` |
| CW-043 | Grid engine (pure Dart) + unit tests                   | app        | 2d   | CW-040, CW-014 | done    | 98.8% line coverage |
| CW-044 | Crossword Home page                                    | app        | 1.5d | CW-042, CW-006 | done    | Daily word game is a card under it |
| CW-045 | Category puzzle list (paged)                           | app        | 1d   | CW-042         | done    | Marks: one `whereIn` read per page, then session cache |
| CW-046 | Puzzle screen (grid, clue bar, chips, keyboard, timer) | app        | 3d   | CW-043         | done    | Hardware keys too; 360 px widget test |
| CW-047 | Progress autosave (pause / leave / 30 s)               | app        | 0.5d | CW-046         | done    | ≤ 1 write / 30 s (bloc test); leave doesn't wait for the write |
| CW-048 | Hints sheet (free clue + per-puzzle reveals)           | app        | 1d   | CW-046         | done    | Reveals kept on device for submit |
| CW-049 | Submit + Results page                                  | app        | 1.5d | CW-046, CW-019 | done    | Share = copy text (no new package) |
| CW-050 | My mistakes / Revise list                              | app        | 1d   | CW-049         | done    | Revise tab; refreshes after submit |
| CW-051 | Crossword weekly leaderboard page                      | app        | 1d   | CW-021         | done    | Ranks tab; own rank via `count()` |
| CW-052 | "Report a wrong answer" flow                           | app        | 0.5d | CW-046         | done    | Clue bar ⋯ / long press + header menu |
| CW-053 | Analytics (package + service + events)                 | app        | 1d   | CW-046         | not-needed | No analytics in phase 1; revisit before launch (M5) if usage data is wanted |
| CW-054 | Routing + entry points                                 | app        | 0.5d | CW-006, CW-044 | done    | Play tab stays `/home` |
| CW-055 | Player profile doc `users/{uid}` on sign-in            | app, rules | 0.5d | CW-010         | done    | Transaction create/update, not awaited; after sign-in + every app start |
| CW-056 | Home: offline banner + Remote Config feature gate      | app        | 0.5d | CW-044         | todo    | In the Home spec; not built in M3 — next up |
| CW-057 | Server-kept `crossword.solvedByCategory` summary       | functions, app | 0.5d | CW-019, CW-044 | not-needed | Home already uses 1 `count()` per category, cached per session (~5 reads); revisit at ~20+ categories |
| CW-058 | Module restructure + code-review fixes                 | app, admin | 1d   | CW-040…CW-055  | done    | One folder per module; `check_structure.py` |




### M4 · Content — target 2026-12-31 (runs in parallel from M2)


| ID     | Task                                       | Area    | Est     | Depends        | Status | Notes                                |
| ------ | ------------------------------------------ | ------- | ------- | -------------- | ------ | ------------------------------------ |
| CW-060 | Seed 5 categories                          | content | 0.25d   | CW-031         | todo   |                                      |
| CW-061 | 150 verified questions (30 × 5 categories) | content | ongoing | CW-032         | todo   | Drafting can start now in `content/` |
| CW-062 | 14 daily puzzles + 10 per category         | content | ongoing | CW-033, CW-061 | todo   |                                      |
| CW-063 | Second-person fact-check pass              | content | 1d      | CW-062         | todo   |                                      |




### M5 · QA & launch — target 2027-01-15


| ID     | Task                                     | Area     | Est  | Depends        | Status | Notes                                       |
| ------ | ---------------------------------------- | -------- | ---- | -------------- | ------ | ------------------------------------------- |
| CW-070 | CI: analyze, tests, lint, rules tests    | ops      | 1d   | CW-009, CW-010 | todo   |                                             |
| CW-071 | Manual test scenarios doc                | qa       | 0.5d | CW-049         | todo   |                                             |
| CW-072 | App Check enforcement                    | ops      | 0.5d | CW-023         | todo   |                                             |
| CW-073 | ~~Budget alerts~~                        | ops      | —    | —              | done   | Moved into CW-008                           |
| CW-074 | Production deploy + content seed         | ops      | 0.5d | CW-076, M1–M4  | todo   |                                             |
| CW-075 | Store release                            | ops      | 1d   | CW-074         | todo   |                                             |
| CW-076 | Prod Firebase project + dev/prod flavors | ops, app | 1.5d | CW-023         | todo   | Port `AppConfig`/flavors from `development` |




### Backlog — Phase 2 and later (not scheduled)


| ID       | Task                                                               | Area           | Notes                                                       |
| -------- | ------------------------------------------------------------------ | -------------- | ----------------------------------------------------------- |
| MAP-001  | Kerala Map Challenge — data model (`mapChallenges`)                | functions      | Design ready: `design/screens/kerala-map-challenge.md`      |
| MAP-002  | Map asset pipeline (DataMeet → app SVG paths)                      | app            | Source data in `design/assets/kerala-map/`; confirm licence |
| MAP-003  | Draw the River mode                                                | app            |                                                             |
| MAP-004  | Explore the Western Ghats mode                                     | app            |                                                             |
| MAP-005  | Build Kerala (drag districts) mode                                 | app            |                                                             |
| MAP-006  | `submitMapChallenge` scoring                                       | functions      |                                                             |
| NEXT-001 | Clue Wordle (question-driven Wordle)                               | app            | Could evolve the existing daily word game                   |
| NEXT-002 | Malayalam UI and Malayalam crossword                               | app            | Bilingual fields already in schema                          |
| NEXT-003 | Spaced repetition on `revisionItems.nextReviewAt`                  | app, functions |                                                             |
| NEXT-004 | Overall XP leaderboard `xp-{week}`                                 | functions      |                                                             |
| NEXT-005 | Exam packs (LDC / LGS / Degree) + Pro pass                         | app            | Monetization                                                |
| NEXT-006 | Hint packs, rewarded ads (port `AdService`/IAP from `development`) | app, functions | DEC-008                                                     |


---



## Decisions


| ID      | Decision                       | Status       | Choice / recommendation                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ------- | ------------------------------ | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DEC-001 | Daily puzzle date key timezone | Accepted     | **IST (Asia/Kolkata)** for all daily keys on this app.                                                                                                                                                                                                                                                                                                                                                                                                                        |
| DEC-002 | Environments                   | **Accepted** | One Firebase project per environment. Dev = `kerala-pcs-dev` (`(default)` database). Prod = a new project in CW-076. Functions take **no** `databaseId` parameter.                                                                                                                                                                                                                                                                                                            |
| DEC-003 | Answers on the client          | Accepted     | Puzzle doc carries **encoded** answers for offline Check/Reveal; real key in private `crosswordSolutions`; server re-scores.                                                                                                                                                                                                                                                                                                                                                  |
| DEC-004 | Answer alphabet                | Accepted     | Phase 1 answers are English A–Z only; Malayalam crossword is NEXT-002.                                                                                                                                                                                                                                                                                                                                                                                                        |
| DEC-005 | Bloc style for new code        | Accepted     | `sealed class` events/states in one bloc file. Existing freezed blocs (`auth`, `game`) stay as they are.                                                                                                                                                                                                                                                                                                                                                                      |
| DEC-006 | Player root document           | Accepted     | `users/{uid}` (already in `FirebaseCollections`) replaces `userGameStates/{uid}` from the `development` design.                                                                                                                                                                                                                                                                                                                                                               |
| DEC-007 | App home                       | **Accepted** | Crossword Home is the start screen: the Play tab (`/home`) of the bottom nav Play · Revise · Ranks · Profile; the daily word game is a card on Home (`/game`). Built in CW-044 / CW-054.                                                                                                                                                                                                                                                                                        |
| DEC-008 | Hints in phase 1               | Accepted     | Built in CW-048. No ads or purchases at launch: "Show a clue" is free; each puzzle allows 3 reveals (letter = 1, word = 3) with XP penalties. Monetization is NEXT-005/006.                                                                                                                                                                                                                                                                                                                    |
| DEC-009 | Firebase region                | Accepted     | `asia-south1` **(Mumbai)** for Firestore and Functions in every environment. Dev's `(default)` DB (first made in `nam5`) is recreated in CW-008.                                                                                                                                                                                                                                                                                                                              |
| DEC-011 | Crossword scoring rules        | Accepted     | `score` = % of words correct. XP = round(`xpReward` × correct ÷ total) − 5/letter reveal − 15/word reveal, min 0 (scaled so an empty grid earns nothing). Revealed words count as wrong. `played` = completed puzzles; `solved` = all words correct; streak = consecutive IST days with a completed puzzle (`lastSolvedDate` = last such day); `bestTimeSec` from solved puzzles only. Weekly `points` = sum of `xpEarned`; `puzzlesSolved` on the board = completed puzzles. |
| DEC-010 | Cloud Functions language       | Accepted     | **Python 3.12** (`firebase-functions` Python SDK, ruff, pytest) instead of TypeScript. Code under `functions/` with `main.py` as the entry point. Rules tests are not covered by a Python library — CW-010 chooses the harness.                                                                                                                                                                                                                                               |


---



## Task cards



### M0 · Foundations



#### CW-001 · Untrack `.env*` files — done

Done in b0e1aa3 (`.env` removed, `.env.example` added, `.gitignore` updated).

#### CW-002 · Environment setup — done

See DEC-002.

#### CW-003 · Add AI kit to repo

Docs, design and content were committed in 40b6343. The hidden folders `.claude/` (skills + settings) and `.cursor/` (rules) were not — Finder and some unzip tools hide dot-folders.

Done when:

- [x] `git ls-files .claude .cursor` lists 6 skill/settings files and 7 rule files
- [x] Claude Code shows the skills in the `/` menu; Cursor lists the rules under Settings → Rules



#### CW-004 · Crossword collection constants

Add to `lib/core/firebase/collections.dart` (keep `games`, `users`) and to `functions/crossword/collections.py` (`UPPER_SNAKE` constants). No string literals for collection names anywhere else.

Done when:

- [x] Constants: `crosswordCategories`, `crosswordPuzzles`, `crosswordSolutions`, `crosswordDaily`, `pscQuestions`, `crosswordProgress`, `revisionItems`, `leaderboards`, `leaderboardEntries` (`entries`), `contentReports`, `adminAuditLog`



#### CW-005 · Remote Config

Add `firebase_remote_config`; create `lib/core/remote_config/app_remote_config.dart` (abstract class + Firebase impl, pattern from `development`'s `story_mode_config.dart`), initialize in `di.dart` with in-app defaults, fetch with a 1 h minimum interval.

Done when:

- [x] Keys with defaults: `crossword_hint_penalties` (`{"letter":5,"word":15}`), `crossword_reveals_per_puzzle` (3), `xp_level_formula` (`{"base":100,"growth":1.25}`), `crossword_autosave_seconds` (30), `min_supported_build` (0)
- [x] App works offline on first launch using defaults



#### CW-006 · App shell

`StatefulShellRoute.indexedStack` with a bottom bar: Play · Revise · Ranks · Profile (placeholders except Play). Use `GameScaffold`/theme colours. Depends on DEC-007 for which screen Play shows.

Done when:

- [x] Tabs keep their state when switching; back button behaves on Android (widget tests + checked on a device)
- [x] Auth redirect still works (signed-out → `/auth`) — now a router `redirect` refreshed on auth changes



#### CW-007 · `functions/` codebase

Create the Cloud Functions project in **Python 3.12** (DEC-010): `firebase-functions` + `firebase-admin` in `requirements.txt`, ruff + pytest in `requirements-dev.txt`, config in `pyproject.toml`, venv in `functions/venv`. Add `functions` (runtime `python312`) to `firebase.json`. Shared helpers:

- `firestore_client.py` → `db()` (default database)
- `admin/assert_admin.py` → `assert_admin(req) -> str` (no `parseDatabaseId`)
- `admin/audit_log.py` → `write_audit_log(action=, admin_uid=, target_id=None, payload=None)`
- `utils/date_id.py` (`today_ist_date_id()`, `is_valid_date_id()`), `utils/iso_week_id.py` (`iso_week_id()`, `ist_iso_week_id()`)
- `set_global_options(region="asia-south1", max_instances=10)` in `main.py`

Done when:

- [x] `ruff check`, `ruff format --check` and `pytest` pass with tests for `assert_admin`, `date_id`, `iso_week_id`
- [x] `firebase emulators:start --only functions,firestore` boots



#### CW-008 · Blaze plan, budget, location

Cloud Functions and scheduled jobs need the Blaze (pay-as-you-go) plan on `kerala-pcs-dev`.

Done when:

- [x] Blaze enabled; budget alerts at $10 and $25 / month on the billing account
- [x] Firestore location written in `docs/firebase/FIREBASE_DESIGN.md` (ideally `asia-south1`; it can't change later — if it's elsewhere, keep functions in the nearest region)
- [x] `firebase firestore:databases:list` shows `(default)` with `locationId: asia-south1`



#### CW-009 · Test setup

Create `test/` mirroring `lib/`; add `mocktail` (dev) if needed; first tests: `GameModel.fromJson`, `WordSchoolUserModel.fromJson`.

Done when:

- [x] `fvm flutter test` runs green locally



### M1 · Backend



#### CW-010 · Firestore rules + rules tests

Replace the open rules on psc-dev with the rules in `docs/firebase/FIREBASE_DESIGN.md#security-rules`:

- `users/{uid}`: owner may create/update **only** profile fields (`displayName`, `photoUrl`, `isAnonymous`, `lastSeenAt`, `createdAt`); `xp`, `crossword`, `rateLimit`, `blockedAt` are server-only.
- `games/{id}`: keep current behaviour for the daily word game until it moves server-side (note in card when done).
- All crossword collections as designed.
Rules tests run on the emulator. Functions are Python (DEC-010), which has no rules-testing library: either a small Node package (`firestore-tests/`, `@firebase/rules-unit-testing` + Jest) or pytest calling the emulator REST API with mock auth tokens — pick one and note it here. The rules in the design doc were reviewed by hand but not yet run on the emulator — expect small fixes.

**Harness (picked):** Node package `firestore-tests/` with `@firebase/rules-unit-testing` + Jest; `cd firestore-tests && npm install && npm test` (runs `firebase emulators:exec --only firestore`, needs Java). The design-doc rules passed unchanged. `games` keeps read + create for signed-in users (update/delete denied) until the daily word game moves server-side.

Done when:

- [x] Tests prove: player **cannot** set own `xp`; **cannot** read `crosswordSolutions` / `pscQuestions` / a `draft` puzzle; **cannot** write content; **cannot** lower `elapsedSec`/hints; **cannot** edit a `completed` progress doc; **can** create a valid report but not read it
- [ ] Daily word game still works on a real device



#### CW-011 · Indexes + field overrides

Merge the JSON in the design doc into `firestore.indexes.json` (currently empty).

Added a fourth index, `contentReports` (status + `createdAt` desc), for `adminListReports` (CW-022); design doc updated.

Done when:

- [ ] `firebase deploy --only firestore:indexes` succeeds; indexes show "Enabled"



#### CW-012 · Shared Python types

`functions/crossword/types.py` (`TypedDict` for documents): `CrosswordCategory`, `PscQuestion`, `CrosswordPuzzle`, `CrosswordWord`, `CrosswordProgress`, `CrosswordResult`, `RevisionItem`, `LeaderboardEntry`, `ContentReport`, `UserProfile`, plus enums as `Literal` / `StrEnum`. Field names (camelCase keys) exactly as the design doc.

Done when:

- [x] `ruff check` passes; no `Any` in document types



#### CW-013 · Grid validator

`functions/crossword/validate_puzzle.py` — pure function, raises `PuzzleValidationError` listing **all** problems. Same checks as `.claude/skills/crossword-content/scripts/validate_crossword.py`.

Done when:

- [x] Checks: layout length = rows×cols; every word fits and fills its whole run; crossing letters agree; every `.` cell is in ≥1 word; no 2+ letter run without a word; answers `^[A-Z]{2,}$`; ids = `{number}{A|D}`; numbering follows standard order
- [x] pytest cases for each failure + the example puzzle passes



#### CW-014 · Answer encoding

One reversible encoding shared by Python and Dart: `answerEnc = base64(utf8(answer) XOR utf8(puzzleId + ":" + wordId))`, key repeated. **Obfuscation, not security.** Reference implementation: `.claude/skills/crossword-content/scripts/validate_crossword.py --encode`.

Done when:

- [x] `encode_answer`/`decode_answer` in Python + `encodeAnswer`/`decodeAnswer` in Dart, both with tests using the same fixtures, including `VAIKOM` / `kerala-history-0012` / `2D` → `PSQ7KiMs`



#### CW-015 · `adminSaveCategory`

Admin callable. Upsert by slug; validates slug `^[a-z0-9-]+$`, `name.en` required, `order` int.

Done when:

- [x] `assertAdmin` + `writeAuditLog` used; unit test for validation



#### CW-016 · `adminSaveQuestion` + `adminVerifyQuestion`

Create/edit `pscQuestions`; answer normalized (uppercase, strip spaces/hyphens/dots) and must match `^[A-Z]{2,}$`; `source` required. Verify sets `status: verified`, `verifiedBy`, `verifiedAt`. Editing a verified question sets it back to `draft`.

Also: retired questions can't be edited or verified; verify refuses a `source.ref` that still starts with `TODO`.

Done when:

- [x] Tests: normalization, missing source rejected, re-edit resets status



#### CW-017 · `adminSaveCrosswordPuzzle`

Input: puzzle with plain `answer` per word. Steps: load all `questionId`s (must be `verified`), run validator, encode answers, write puzzle (`status: draft`) + `crosswordSolutions/{id}` in **one batch**, add puzzle id to each question's `usedInPuzzles`. New puzzles get the next `number` in the category.

Also: each word's answer must equal its question's answer; only `draft`/`in_review` puzzles can be re-saved (saving makes it `draft` again); one transaction (reads before writes) instead of a plain batch, because the number comes from `crosswordCategories.lastPuzzleNumber`.

Done when:

- [x] Rejects unverified questions and invalid grids with readable errors
- [x] Re-saving a `published` puzzle is refused (archive → copy instead)



#### CW-018 · `adminSetPuzzleStatus` + `adminScheduleDaily`

State machine: `draft→in_review→scheduled→published→archived`, plus `in_review→draft` and `in_review→published` (publish now). Publishing sets `publishedAt` and increments `crosswordCategories.publishedPuzzleCount` (transaction); archiving decrements. `adminScheduleDaily({dateId, puzzleId})` writes `crosswordDaily/{dateId}`; puzzle must be `scheduled` or `published`.

Also: `scheduled → scheduled` changes `publishAt` (the only way to move a scheduled date). Daily: date must be today or later (IST); a scheduled puzzle must have `publishAt` ≤ 00:00 IST of that day (the 00:05 rollover publishes it).

Done when:

- [x] Tests for every allowed and refused transition



#### CW-019 · `submitCrossword`

Player callable. Input `{puzzleId, letters, elapsedSec, hintsUsed}`. See design doc "Player: finish".

- Idempotent: if progress is `completed`, return stored result.
- Score each word against `crosswordSolutions`; XP = `xpReward` − penalties (floor 0); revealed words count as wrong for revision.
- Plausibility: refuse `elapsedSec < wordCount × 2`; rate limit 30/hour/user (`users/{uid}.rateLimit`).
- One batch: progress result, `users/{uid}.xp` + `crossword` stats (streak by IST date), leaderboard entry `crossword-{isoWeek}`, `revisionItems` upserts.

Scoring choices are DEC-011 (Accepted). Input also takes `revealedWordIds` so the Results screen can tag "Revealed" words. Penalties are constants mirroring Remote Config defaults (CW-026 reads them from Remote Config).

Done when:

- [x] pytest: scoring, penalties, idempotency, streak continue/reset, rejection cases
- [x] Emulator test: full submit writes all 4 places



#### CW-020 · `crosswordDailyRollover`

`onSchedule({schedule: "5 0 * * *", timeZone: "Asia/Kolkata"})`: publish puzzles whose `publishAt ≤ now`; log an error if tomorrow has no `crosswordDaily` doc.

Done when:

- [x] Unit test for the selection logic; manual run on dev — force run from Cloud Scheduler on 2026-10-23; logs showed the expected "No crosswordDaily doc" errors (no content yet)



#### CW-021 · `refreshLeaderboardTop`

`onSchedule("every 15 minutes")`: read the current week's top 50 entries and write `top50` + `updatedAt` on the board's parent doc.

Done when:

- [x] Reads ≤ 50 docs per run (check logs) — emulator test asserts it; the job logs `reads` on dev



#### CW-022 · Reports callables

`adminListReports({status, limit})`, `adminResolveReport({reportId, status, note})`.

Done when:

- [x] Audit log written on resolve



#### CW-023 · Export, deploy, smoke test

Import every function in `functions/main.py`. Deploy rules, indexes, functions to `kerala-pcs-dev`.

Done when:

- [x] With the admin panel (or the emulator UI before M2): create category → question → puzzle → publish; a test account can submit and see the result — automated on the emulator in `functions/crossword/flow_test.py` (real handlers)
- [x] Rules, indexes and functions deployed to `kerala-pcs-dev` (2026-10-23) — same flow on dev to repeat with the admin panel (M2)



#### CW-024 · Admin claim script

Port `development`'s `functions/src/scripts/setAdminClaim.ts` to `functions/scripts/set_admin_claim.py` (`venv/bin/python -m scripts.set_admin_claim you@example.com`), defaulting to project `kerala-pcs-dev`.

Done when:

- [x] Your account has `admin: true` (check: `getIdTokenResult().claims.admin`) — set 2026-10-23 with a service-account key; confirmed via the Admin SDK



#### CW-025 · Admin read callables

The admin panel can't read content directly: rules deny `pscQuestions` and `crosswordSolutions` to everyone, and puzzles/categories only when published/active. Add `adminListQuestions({subject?, status?, startAfterId?})` (index `subject, status, updatedAt` exists), `adminListPuzzles({categoryId, status?})`, `adminGetPuzzle({puzzleId})` (puzzle + plain answers from `crosswordSolutions`, for editing), `adminListCategories()`. Alternative: allow reads in rules for `request.auth.token.admin == true` — decide before CW-030.

**Decided:** callables (`crossword/admin_reads.py`); rules stay closed so no client token can read `pscQuestions` or `crosswordSolutions`. Lists page at 20 (`limit` ≤ 100, `startAfterId`); `adminListPuzzles` rows leave out `words`/`layout`. New indexes: `pscQuestions (subject, updatedAt)`, `(status, updatedAt)`, `crosswordPuzzles (categoryId, number)`.

Done when:

- [x] Admin can page questions and open a puzzle with its answers; players are refused — emulator tests in `admin_reads_test.py`; functions + indexes deployed (all 16 functions live, checked 2026-10-25)



#### CW-026 · Server hint penalties from Remote Config

`submitCrossword` uses constants (5/15) that mirror the Remote Config defaults (`crossword_hint_penalties`). Read the server template (`firebase_admin.remote_config`) with a cached fallback so a Remote Config change applies to both app and server.

**Changed approach:** the Admin SDK's server template is a separate namespace (`firebase-server`), so the app's parameter would have to be kept in two places. `crossword/remote_config.py` reads the **client** template over REST instead (default value only; cached 5 min per instance; last good value, else 5/15, if the fetch fails). The functions' service account needs `cloudconfig.configs.get` (Editor has it).

Done when:

- [ ] Changing `crossword_hint_penalties` changes server XP; fallback tested — unit tests cover template → XP, cache refresh and fallback; function deployed. The live check on dev (change the RC value, submit, compare XP) was never run → added to CW-071



### M2 · Admin panel



#### CW-029 · Admin foundation

psc-dev has no web target. Add it (`fvm flutter create --platforms web .`, then `flutterfire configure` for a web app in `kerala-pcs-dev`). Port from `development`: `lib/main_admin.dart` (entry), `lib/app/bootstrap_admin.dart`, `lib/di_admin.dart`, `lib/core/routes/admin_router.dart`, `features/admin/data/admin_auth_service.dart` (Google sign-in + `admin` claim check), `admin_shell_page.dart`, `admin_login_page.dart`, and an `AdminApiService` with a `_call(name, data)` helper using `FirebaseFunctions.instanceFor(region: 'asia-south1')`. Drop the database switcher (DEC-002); show the project id as an environment badge.

**Done (branch** `module/m2`**):** web target added; Firebase web app `wordshool (web)` created in `kerala-pcs-dev` with the Firebase CLI (no FlutterFire CLI here) and added to `firebase_options.dart`. Sign-in is a Google popup (`signInWithPopup`, no `google_sign_in` on web); `AdminAuthService` is a `ChangeNotifier` the router listens to, so a non-admin is signed out and stays on `/login`. Sections: Home, Categories, Questions, Puzzles, Daily schedule, Reports, Bulk upload. Env badge shows `TEST · kerala-pcs-dev` (any non `-dev` project shows `LIVE` in red). Pages are `StatefulWidget`s that call `AdminApiService` directly (as on `development`); pure logic lives in `features/admin/domain/utils/` with tests. *(CW-058 split this into modules: `AdminApiService` became `admin/shared/data/data_source/*_service.dart` + `callable.dart`; pages live in `admin/<section>/presentation/pages/`.)*

Done when:

- [x] `fvm flutter run -t lib/main_admin.dart -d chrome` → non-admin is refused, admin reaches the shell — redirect logic unit-tested; signed in during review (2026-10-25)
- [x] The mobile app build is unaffected — web-only code sits behind conditional imports (now `admin/bulk_upload/presentation/utils/text_file.dart`)



#### CW-030 · `AdminApiService` crossword methods

Typed methods for every crossword callable; models in `lib/features/admin/domain/models/` (now `admin/shared/domain/models/`, CW-058).

**Done:** every method returns `DataState<T>`; `listAllQuestions` pages at 100 for import matching and the builder. `crosswordDaily` docs are read straight from Firestore (players may read them; one `get()` per day) instead of a new callable. `LocalizedText` added in `lib/shared/domains/entities/` (CW-040 reuses it); `toJson` leaves out empty optional text because the server rejects e.g. an empty `topic`. Errors: `showAdminError` shows the server message in a snackbar, with "See all" when the server lists several problems.

Done when:

- [x] Each method has a `fromJson` model; errors surface as snackbars with the server message



#### CW-031 · Categories page

List, add/edit, reorder (`order`), toggle `isActive`.

**Done:** list with drag handles (orders become 10, 20, 30… and only changed categories are re-saved), a "Visible to players" switch, and an add/edit dialog. The ID is made from the English name (editable only when adding), the icon and colour are picked from 12 icons and 8 colours.

#### CW-032 · Question bank page

Filter by subject + status; add/edit form (answer, display EN/ML, clues, fact, examTags, difficulty, source); Verify button.

**Done:** filters (subject from categories + loaded questions, status), search within loaded pages, "Load more" (20 per page). The form is numbered in 5 steps; the answer shows as letter tiles as you type (normalised like the server), subjects/topics/exam tags are converted to snake_case, and the source hint changes with its type. Verify is labelled **"Mark as checked"**, asks for confirmation showing the source, and opens the editor instead when the source still starts with TODO. Editing a checked question warns that it goes back to "Needs checking".

#### CW-033 · Puzzle builder

Grid editor (up to 15×15), place a verified question across/down at a cell, auto-numbering, crossing conflicts highlighted, validator errors listed live (port of CW-013 in Dart, or a `dryRun` flag on `adminSaveCrosswordPuzzle`).

**Done:** validator ported to Dart (`admin/shared/domain/utils/grid_validator.dart` since CW-058, same checks as CW-013 and the same test cases; messages written for people, rows/columns from 1, with the cells to highlight). The admin never draws black squares: they place **checked** questions and `PuzzleDraft` works out the layout, numbering and word ids (unused squares become blocks). Picking a question shows suggested spots that cross existing words on a matching letter without touching others; tapping a square places it there instead. Selected word: edit the clue (or pick one of the question's clues), extra hint, remove. Grid size 3–15, "Fit to words", Clear, Undo. Problems are listed live and cells turn red; Save stays disabled ("Fix N to save") until the grid, details and question checks are clean. Also: the Puzzles list page (category chips, status filter, paging). `/puzzles/:id` opens the builder until CW-034 adds the preview page.

Done when:

- [x] The example puzzle in `.claude/skills/crossword-content/examples/` can be rebuilt in the builder — `puzzle_draft_test.dart` rebuilds it from placements only: same layout, numbers and ids, no problems (in the panel it needs its 7 questions checked first)
- [x] Save works only when the validator is clean



#### CW-034 · Preview, workflow, schedule

Preview renders the puzzle as the player sees it; buttons for each allowed status move; calendar of `crosswordDaily` for the next 30 days with empty days flagged.

**Done:** `/puzzles/:id` shows the grid with black squares and Across/Down clue lists ("Show answers" adds answers and facts; tapping a clue or square highlights the word). "What next?" lists one button per allowed move from `status_flow.dart` (mirrors `TRANSITIONS`, unit-tested) with a one-line explanation: Send for review, Back to draft, Schedule / Change date (date + time picker in IST, must be in the future), Publish now and Archive (both confirm). Live and scheduled puzzles also get "Make puzzle of the day". `/schedule` lists the next 30 IST days (one `get()` per day), "N of 30 days have a puzzle", empty days in yellow, and a picker that only offers Live puzzles or Scheduled ones going live by midnight of that day.

#### CW-035 · Reports page

Open reports with links to the puzzle/question; resolve with note.

**Done:** Open / Fixed / Rejected tabs, paging. "Open puzzle" goes to the puzzle page with the reported word highlighted (`?word=2D`); "Open question" opens the question editor. There was no way to read one question, so a new admin callable `adminGetQuestion({id})` was added (`crossword/admin_reads.py`, emulator tests, design doc). "Mark fixed" / "Reject" ask for an optional note. **Deployed** 2026-10-25 (`firebase functions:list` shows it live).

#### CW-036 · Import from JSON

Upload a `content/questions/*.json` or `content/puzzles/*.json` file (shapes in `.claude/skills/crossword-content/examples/`). Show a preview with validation errors, then call `adminSaveQuestion` / `adminSaveCrosswordPuzzle` per item. `draftNotes` is dropped; imported questions stay `draft`.

**Done:** "Bulk upload" page (`/bulk-upload`). Questions come from a CSV spreadsheet (downloadable template, UTF-8 with BOM so Excel shows Malayalam; cells pasted from Google Sheets also work) or JSON; puzzles from JSON. Every row is checked like the server does and shown as New / Update / No change / Error before anything is saved; rows with errors are skipped. Questions match on `subject` + `answer` (an identical one is left alone, so checked questions stay checked). Puzzle words with a `TODO` question id are linked to a checked question by answer; puzzles match on `id`, then on title in the category, and only drafts are overwritten. Pure logic in `admin/bulk_upload/domain/utils/{bulk_import,csv}.dart` with tests; browser file open/save in `admin/bulk_upload/presentation/utils/text_file*.dart` (package `web`) — paths since CW-058. Status filters on Questions, Puzzles and Reports now use a shared `FilterChips` widget.

Done when:

- [x] Both example files import cleanly into the dev DB — both parse with no problems in `bulk_import_test.dart`; uploaded during review (2026-10-25)
- [x] Re-importing the same file updates instead of duplicating (match on `answer` + `subject` for questions, `id` for puzzles) — `planQuestionImport` / `planPuzzleImport` tests



### M3 · Player app



#### CW-040 · Domain entities

`lib/features/crossword/domain/entities/`: `CrosswordCategoryEntity`, `CrosswordPuzzleEntity`, `CrosswordWordEntity`, `CrosswordDailyEntity`, `CrosswordProgressEntity`, `CrosswordResultEntity`, `RevisionItemEntity`, and shared `LocalizedText` in `lib/shared/domains/entities/`. Equatable, immutable.

Done when:

**Done:** 10 entities (+ `Paged<T>` in `lib/shared/domains/entities/`, `PuzzleSessionEntity`, `ContentReportEntity`, `CrosswordHomeEntity`). Since CW-058 they live in each module's `domain/entities/`; the ones 2+ modules use (category, puzzle, word, progress, result, `ResultArgs`, change) in `crossword/shared/domain/entities/`; enums carry their wire value (`CrosswordDirection`, `CrosswordDifficulty`, `CrosswordProgressStatus`, `ReportReason`). `LocalizedText` was already shared (CW-030). Written by hand to the skill's conventions (the scaffold script can't express nested fields).

- [x] Same layering as the `flutter-feature` skill; no Firebase imports in domain



#### CW-041 · Data layer

Models (`fromJson/toJson`, `documentId` param), `CrosswordContentDataSource` (daily, categories, puzzles paged by `number desc` 20/page, puzzle by id) and `CrosswordProgressDataSource` (get, save, submit via `FirebaseFunctions`), `CrosswordRepositoryImpl`. `FirebaseFirestore` and `FirebaseFunctions` injected from `di.dart`.

Done when:

**Done:** one data source per module since CW-058 — `HomeDataSource`, `CategoryDataSource`, `PuzzleDataSource` (load + `submitCrossword`), `RevealsDataSource` (SharedPreferences: revealed squares, which the rules keep off the progress doc), `ReportDataSource`, `ReviseDataSource`, `LeaderboardDataSource`, and the shared `ProgressDataSource` with `CrosswordProgressRepository` (session cache) and `CrosswordChangesRepository`. Every method goes through `guardData()` (`lib/core/resorces/data_guard.dart`): catches, logs, returns `DataError` with a player-readable message. The progress repository reads progress once per session and keeps it up to date (Home, category marks); the changes repository fires after a submit so Home/Revise/Ranks refresh without listeners. Writes the player waits on use `awaitServerAck()` (5 s). Fixtures in `test/fixtures/crossword/` (puzzle encoded with the server's encoder).

- [x] Queries include `isActive == true` / `status == 'published'` (rules require it)
- [x] Model tests with real-shaped JSON fixtures — `test/features/crossword/*/data/models/*_test.dart` and `*/data/repositories/*_test.dart`



#### CW-042 · Use cases + DI

`LoadCrosswordHomeUseCase`, `LoadCategoryPuzzlesUseCase`, `LoadPuzzleUseCase`, `SaveCrosswordProgressUseCase`, `SubmitCrosswordUseCase`, `LoadRevisionItemsUseCase`, `SetRevisionMasteredUseCase`, `ReportContentUseCase`. Register in `di.dart` → `_initializeCrossword()`.

**Done:** the eight above + `LoadCrosswordCategoryUseCase` (deep links), `LoadPuzzleMarksUseCase` / `CountCompletedUseCase` (category), `LoadHomeProgressUseCase` / `CountRevisionItemsUseCase` (home), `LoadLeaderboardUseCase`, `WatchCrosswordChangesUseCase`; one param class per file in each module's `usecases/utils/`. Each module has `di.dart` (`init<Module>`), called from `crossword/di.dart` → `initCrossword(getIt)`. `lib/di.dart` registers `FirebaseFirestore` and `FirebaseFunctions` (asia-south1) once in `_initializeFirebase()`.

#### CW-043 · Grid engine

Pure Dart in `lib/features/crossword/domain/utils/crossword_grid.dart` (now `crossword/puzzle/domain/utils/grid.dart`): parse layout, cell→word lookup, next/prev cell, tap-twice direction toggle, backspace behaviour, check (per-cell correct/wrong), reveal letter/word, `isSolved`. Uses decoded answers.

Done when:

**Done:** `CrosswordGrid` (mutable, `revision` counter): layout + numbering, across/down lookup, tap / tap-again toggle, type → next square, backspace (clear, then back), word jump to first empty square, prev/next (wraps), Check (until edited), reveal letter/word (revealed squares locked), `isSolved`, `lettersString` for saves/submit, restore from progress + device reveals.

- [x] ≥ 90% line coverage on the engine (98.8%); the example puzzle is used in tests



#### CW-044 · Crossword Home

Matches `design/screens/psc-crossword.md#1-home`: daily card, categories grid with progress, streak chip, EN/ML toggle (EN only in phase 1). Reuse `GameScaffold`, `AppButton`, `FadeSlideIn`.

**Done:** Crossword Home is the Play tab's page (`crossword/home/presentation/pages/home_page.dart`; the old placeholder `features/home` was removed in CW-054). The daily word game stays as a "More games" card below. Daily card states: new / continue (`4 / 31`) / view result (`· 71%`) / "on its way"; categories in a 2-column grid with `played / published` and a bar; 6th tile "My mistakes" (count). Skeletons while loading, pull to refresh, error + retry. Offline banner and feature gate → CW-056.

#### CW-045 · Category list

Paged list (20), puzzle number, title, difficulty, solved state from progress.

**Done:** `/crossword/category/:id` (category passed from Home, loaded on deep link); loads the next page near the end of the list; marks New / In progress / Done · score; marks come from one `whereIn` progress read per page and refresh from the session cache when returning from a puzzle.

#### CW-046 · Puzzle screen

Matches `#2-puzzle`. Grid, active word highlight, clue bar with prev/next, clue chips, on-screen keyboard (reuse/extend `features/game/presentation/widgets/keyboard/`), timer, Check.

Done when:

**Done:** header (back, title, `Puzzle 12 · Medium`, timer, hints badge, menu: Report / Finish), letters-filled row + check status, `CrosswordBoard`, `ClueBar` (prev/next, ⋯), `ClueChips`, solved/complete banner, `CrosswordKeyboard` (CHECK + letters + delete, 52 high). A hardware keyboard works too (letters, Backspace, Enter = Check, Tab = next word). Cells have screen-reader labels (position, letter, right/not right, revealed).

- [x] Works on 360 px wide screens; touch targets ≥ 44 px — `test/features/crossword/screens_test.dart` runs every screen at 360 × 740 (the test font is wider than real fonts, so it also covers large text)
- [x] Widget test for the active-word highlight — `puzzle/presentation/widgets/puzzle_widgets_test.dart`



#### CW-047 · Progress autosave

Save on `AppLifecycleState.paused`, on route pop, and every `crossword_autosave_seconds` if dirty. Never per keystroke.

Done when:

**Done:** in `PuzzleBloc`: saves when changed every `crossword_autosave_seconds`, on pause (also stops the timer), and on leaving (`saveNow()` is started, not awaited: the route pops at once and the bloc's save queue finishes the write; Firestore keeps it offline). A puzzle that was only looked at gets no progress doc. Each write logs `progress saved … (create|update)` under `CROSSWORD_AUTOSAVE`.

- [x] Log shows ≤ 1 write per 30 s during continuous typing — `puzzle_bloc_test.dart`: 65 s of typing → 2 writes; also check the log on a device (QA doc)



#### CW-048 · Hints sheet (phase 1 variant, DEC-008)

Matches `#3-hints` except the balance row: "3 reveals left in this puzzle" (from `crossword_reveals_per_puzzle`). Show clue = free; reveal letter = 1; reveal word = 3; no ad button, no "Get more". Increments `hintsUsed` locally.

**Done:** `HintsSheet` in the shared `showAppSheet`; XP penalties shown from Remote Config; "Not enough reveals" / "Already revealed" disable a row; "Show a clue" opens in place and counts once per word per session.

#### CW-049 · Submit + Results

Matches `#4-results`. Calls `submitCrossword`, shows score, time, correct/total, XP, streak, level bar (level from `xp_level_formula`), mistakes with facts. No extra reads after submit.

**Done:** submit from the solved/complete banner or "Finish puzzle" (confirms when squares are empty). `ResultArgs` carries the puzzle, the response and what was typed; mistakes show "You typed VAI·AM" or "Revealed". Share copies a text summary (no `share_plus`). Opening a completed puzzle calls `submitCrossword` again (idempotent, no writes) and shows its result.

#### CW-050 · My mistakes / Revise

List `revisionItems` where `mastered == false` newest first; button to mark as learned. Lives in the Revise tab (CW-006).

**Done:** `RevisePage` (`crossword/revise/`) is the Revise tab: answer tiles, clue, fact, subject chip, "Missed N times", "Mark as learned"; pages of 20; empty state; reloads after a submit.

#### CW-051 · Crossword leaderboard page

Ranks tab: read `leaderboards/crossword-{isoWeek}` `top50`; own rank via `count()` query; own row pinned at the bottom.

**Done:** `LeaderboardPage` (`crossword/leaderboard/`) is the Ranks tab; board id from the IST ISO week (`istIsoWeekId`, twin of `functions/utils/iso_week_id.py`); empty state; reloads after a submit.

#### CW-052 · Report a wrong answer

From the clue bar menu: reason + optional message → `contentReports`.

**Done:** `ReportSheet` (3 reasons, ≤ 500 chars) from the clue bar ⋯ / long press and the header menu; sends `questionId` + `wordId`.

#### CW-053 · Analytics

Add `firebase_analytics`; create `lib/core/analytics/analytics_service.dart` + `analytics_events.dart` (pattern from `development`). Events: `crossword_open`, `crossword_start`, `crossword_hint` (type), `crossword_check`, `crossword_submit` (score, time), `crossword_report`.

**Not needed (2026-10-25):** started in M3, then taken out again — phase 1 ships without analytics (no package, no events). Revisit before launch (M5) if usage data is wanted; it would be a new task.

#### CW-054 · Routing + entry points

Routes `/crossword`, `/crossword/category/:id`, `/crossword/puzzle/:id`, `/crossword/puzzle/:id/result`, `/revise`, `/ranks`. Auth page navigates to the shell's Play tab after sign-in.

**Done:** the Play tab stays `/home` and *is* Crossword Home (DEC-007), so there is no separate `/crossword`. Category, puzzle and result open full screen over the bottom bar; blocs are created in `app_router.dart`.

#### CW-055 · Player profile doc

After sign-in (Google or guest), create/merge `users/{uid}` with `displayName` (Google name or "Guest 1234"), `photoUrl`, `isAnonymous`, `createdAt` (create only), `lastSeenAt`. Only these keys — the rules reject anything else. Every write must send `lastSeenAt: FieldValue.serverTimestamp()` (the rule checks it).

Done when:

**Done:** `SavePlayerProfileUseCase` (auth feature): `AuthBloc` calls it after sign-in and `main.dart` on every start of a signed-in app, both `unawaited` so sign-in never waits on it. A transaction reads the doc, then `update`s (doc made by `submitCrossword`) or `set`s with `createdAt`, so a doc created in between retries as an update instead of a create the rules reject. Guest name `Guest 1234` from the uid (stable).

- [x] New and returning users get a valid doc — only the rules' keys are written; a write including `xp` is rejected by rules (`firestore.rules.test.js` → "player cannot set own xp"). Check once on a device (QA doc)



#### CW-056 · Home: offline banner + feature gate

From `#1-home` States: show "Offline — progress saves when you're back" when Firestore serves from cache, and hide the crossword entry when a Remote Config flag (`crossword_enabled`) is off.

Done when:

- [ ] Banner shows in airplane mode with cached content; flag off hides Home's crossword sections

#### CW-057 · Solved-by-category summary

Home reads every progress doc once per session to count solved puzzles per category. Keep `users/{uid}.crossword.solvedByCategory` in `submitCrossword` instead, and read it from the profile doc.

**Not needed (2026-10-25):** the premise is wrong — Home doesn't read the progress docs. It runs one `count()` per category (1 read each per 1,000 matches), cached per session and bumped locally after a submit: about 5 reads per session with 5 categories. A server-kept summary would add a schema change, `submitCrossword` work, a backfill and a deploy to save those few reads. Revisit at ~20+ categories or if the Firebase bill shows these counts.

Done when:

- [ ] Home makes no progress-collection read; counts match the old scan in an emulator test

#### CW-058 · Module restructure + code-review fixes

Split `crossword` and `admin` into independent modules (one folder per screen area with its own data / domain / presentation + `di.dart`, shared code in `<feature>/shared/`), navigate by path (`AppRoutes`, `AdminRoutes`), and apply the M3 code-review fixes.

Done when:

- [x] Modules import only themselves, their feature's `shared/` and `lib/{core,config,shared}`; `scripts/check_structure.py` enforces it (+ `_build` names, ≤ 700 lines, folder names) — 0 problems
- [x] Review fixes: puzzle edits / Check / reveals locked while a submit is sending; progress, revise "learned" and report writes use a bounded server wait (`awaitServerAck`) — tests added
- [x] `scripts/check.sh` green (checked in review 2026-10-25)



### M4 · Content



#### CW-060 · Seed categories

`kerala-history`, `indian-history`, `constitution`, `geography`, `science` (order 10–50).

#### CW-061 · Question bank

30 verified questions per category with `source` filled (PYQ year or book + page). Draft now in `content/questions/` with the `crossword-content` skill; a person verifies every fact before import.

#### CW-062 · Puzzles

14 daily puzzles scheduled + 10 per category published. Every puzzle passes the validator.

#### CW-063 · Fact-check pass

A second person checks every published answer and fact; fixes logged in the audit log.

### M5 · QA & launch



#### CW-070 · CI

GitHub Actions on PRs to `psc-dev`: `fvm flutter analyze`, `fvm flutter test`, `ruff check functions`, `pytest functions`, rules tests on the emulator.

#### CW-071 · Manual test scenarios

`docs/qa/crossword-manual-tests.md`: sign-in paths, offline play, autosave/resume, submit twice, hints, report, leaderboard week rollover, and the CW-026 live check (change `crossword_hint_penalties` in Remote Config, submit with a reveal, XP uses the new penalty).

#### CW-072 · App Check

Play Integrity (Android) + App Attest (iOS); enforce on Firestore and callable functions after a week of monitoring.

#### CW-074 · Production deploy

Rules → indexes → functions → seed content to the prod project (CW-076) → staged rollout.

#### CW-075 · Store release

Version bump, changelog, screenshots, store listing for the Kerala PSC app.

#### CW-076 · Prod project + flavors

Create the production Firebase project (Firestore in the same region as dev). Port `AppConfig`, `AppEnvironment`, `main_dev.dart` / `main_prod.dart` and Android/iOS flavors from `development`; `flutterfire configure` per flavor; `.firebaserc` aliases `dev` / `prod`.

Done when:

- [ ] `fvm flutter run -t lib/main_dev.dart --flavor dev` and `--flavor prod` point at different projects