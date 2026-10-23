# Kerala PSC App — Task Sheet

> **Current phase:** Phase 1 — PSC Crossword
> **Branch:** `psc-dev` · **Firebase (dev):** `kerala-pcs-dev` · **Last updated:** 2026-10-23
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


**Working with Claude Code / Cursor**

- "**Start CW-019**" → Claude reads the card, sets it to `doing`, follows the matching skill, and checks every "Done when" box before setting `review`.
- "**What's next?**" → Claude picks the first `todo` task whose dependencies are all `done` (skill: `task-workflow`).
- One task = one branch = one PR: `feat/CW-019-submit-crossword` → PR into `psc-dev`, title `CW-019: submitCrossword callable`.
- Note notable changes in `docs/daily/YYYY-MM-DD.md` (what changed, why, files).

**Adding a task:** next free number in its milestone block, add a row to the board **and** a card. Never reuse an ID.

**Estimates** are focused working days (d) for one developer.

---



## Status board



### M0 · Foundations — target 2026-11-04


| ID     | Task                                                  | Area           | Est   | Depends | Status | Notes                                                                                                                         |
| ------ | ----------------------------------------------------- | -------------- | ----- | ------- | ------ | ----------------------------------------------------------------------------------------------------------------------------- |
| CW-001 | Untrack `.env*` files from git                        | ops            | 0.25d | —       | done   | b0e1aa3                                                                                                                       |
| CW-002 | Decide environment setup (DEC-002)                    | ops            | 0.25d | —       | done   | Separate projects; dev = `kerala-pcs-dev`                                                                                     |
| CW-003 | Add AI kit to repo (incl. `.claude/`, `.cursor/`)     | ops            | 0.25d | —       | review | `.claude/` + `.cursor/` added; check `/` menu + Cursor rules manually                                                         |
| CW-004 | Crossword collection constants (Dart + TS)            | app, functions | 0.25d | CW-007  | todo   |                                                                                                                               |
| CW-005 | Remote Config (package + typed config class)          | app            | 0.5d  | —       | review | Offline first launch needs a manual device check                                                                              |
| CW-006 | App shell: bottom navigation + routes                 | app            | 1d    | —       | todo   | Needs DEC-007                                                                                                                 |
| CW-007 | Create `functions/` codebase + shared helpers         | functions      | 1d    | CW-008  | review | Functions emulator boots; Firestore emulator needs Java (not installed) |
| CW-008 | Blaze plan, budget alerts, confirm Firestore location | ops            | 0.25d | —       | blocked | Blaze + budgets done. DB is in `nam5` → recreate `(default)` in `asia-south1` |
| CW-009 | Test setup (Flutter `test/`) + first green run        | app            | 0.5d  | —       | review | 7 model tests green. `analyze` has 6 pre-existing issues in `lib/` (unused `get` import, deprecations) — needs a cleanup task |




### M1 · Backend: rules, indexes, functions — target 2026-11-18


| ID     | Task                                                             | Area           | Est   | Depends                | Status | Notes                                        |
| ------ | ---------------------------------------------------------------- | -------------- | ----- | ---------------------- | ------ | -------------------------------------------- |
| CW-010 | Firestore rules (incl. lock down `users`, `games`) + rules tests | rules          | 2d    | CW-004, CW-007         | todo   | `users/{uid}` is fully client-writable today |
| CW-011 | Indexes + field overrides                                        | rules          | 0.25d | —                      | todo   |                                              |
| CW-012 | Shared TS types for crossword                                    | functions      | 0.5d  | CW-004                 | todo   |                                              |
| CW-013 | Grid validator + tests                                           | functions      | 1.5d  | CW-012                 | todo   |                                              |
| CW-014 | Answer encoding (TS + Dart, same algorithm)                      | functions, app | 0.5d  | CW-007, CW-009         | todo   |                                              |
| CW-015 | `adminSaveCategory`                                              | functions      | 0.5d  | CW-012                 | todo   |                                              |
| CW-016 | `adminSaveQuestion` + `adminVerifyQuestion`                      | functions      | 1d    | CW-012                 | todo   |                                              |
| CW-017 | `adminSaveCrosswordPuzzle`                                       | functions      | 1d    | CW-013, CW-014, CW-016 | todo   |                                              |
| CW-018 | `adminSetPuzzleStatus` + `adminScheduleDaily`                    | functions      | 1d    | CW-017                 | todo   |                                              |
| CW-019 | `submitCrossword` (scoring, XP, leaderboard, mistakes)           | functions      | 2d    | CW-013, CW-017         | todo   |                                              |
| CW-020 | `crosswordDailyRollover` scheduled job                           | functions      | 0.5d  | CW-018                 | todo   |                                              |
| CW-021 | `refreshLeaderboardTop` scheduled job                            | functions      | 0.5d  | CW-019                 | todo   |                                              |
| CW-022 | `adminListReports` + `adminResolveReport`                        | functions      | 0.5d  | CW-012                 | todo   |                                              |
| CW-023 | Export, deploy to `kerala-pcs-dev`, smoke test                   | functions      | 0.5d  | CW-015…CW-022          | todo   |                                              |
| CW-024 | `setAdminClaim` script + first admin account                     | functions, ops | 0.25d | CW-007                 | todo   |                                              |




### M2 · Admin panel (Flutter web) — target 2026-12-04


| ID     | Task                                                                          | Area  | Est  | Depends        | Status | Notes                         |
| ------ | ----------------------------------------------------------------------------- | ----- | ---- | -------------- | ------ | ----------------------------- |
| CW-029 | Admin foundation: web target, `main_admin.dart`, claim login, shell, API base | admin | 1.5d | CW-024         | todo   | Port from `development`       |
| CW-030 | `AdminApiService` crossword methods + models                                  | admin | 1d   | CW-029, CW-023 | todo   |                               |
| CW-031 | Categories page                                                               | admin | 0.5d | CW-030         | todo   |                               |
| CW-032 | Question bank page (list, add/edit, verify)                                   | admin | 1.5d | CW-030         | todo   |                               |
| CW-033 | Puzzle builder (grid editor + live validation)                                | admin | 3d   | CW-030, CW-014 | todo   | Biggest admin task            |
| CW-034 | Puzzle preview, status workflow, schedule calendar                            | admin | 1d   | CW-033         | todo   |                               |
| CW-035 | Reports page                                                                  | admin | 0.5d | CW-030         | todo   |                               |
| CW-036 | Import questions / puzzles from JSON                                          | admin | 1d   | CW-032, CW-033 | todo   | Saves typing for content team |




### M3 · Player app (Flutter) — target 2026-12-24


| ID     | Task                                                   | Area       | Est  | Depends        | Status | Notes                                   |
| ------ | ------------------------------------------------------ | ---------- | ---- | -------------- | ------ | --------------------------------------- |
| CW-040 | Domain entities                                        | app        | 1d   | CW-009         | todo   |                                         |
| CW-041 | Models, data sources, `CrosswordRepository`            | app        | 1.5d | CW-040, CW-004 | todo   |                                         |
| CW-042 | Use cases + DI registration                            | app        | 0.5d | CW-041         | todo   |                                         |
| CW-043 | Grid engine (pure Dart) + unit tests                   | app        | 2d   | CW-040, CW-014 | todo   |                                         |
| CW-044 | Crossword Home page                                    | app        | 1.5d | CW-042, CW-006 | todo   |                                         |
| CW-045 | Category puzzle list (paged)                           | app        | 1d   | CW-042         | todo   |                                         |
| CW-046 | Puzzle screen (grid, clue bar, chips, keyboard, timer) | app        | 3d   | CW-043         | todo   |                                         |
| CW-047 | Progress autosave (pause / leave / 30 s)               | app        | 0.5d | CW-046         | todo   |                                         |
| CW-048 | Hints sheet (free clue + per-puzzle reveals)           | app        | 1d   | CW-046         | todo   | No ads/IAP in phase 1 (DEC-008)         |
| CW-049 | Submit + Results page                                  | app        | 1.5d | CW-046, CW-019 | todo   |                                         |
| CW-050 | My mistakes / Revise list                              | app        | 1d   | CW-049         | todo   |                                         |
| CW-051 | Crossword weekly leaderboard page                      | app        | 1d   | CW-021         | todo   | New page (none on psc-dev)              |
| CW-052 | "Report a wrong answer" flow                           | app        | 0.5d | CW-046         | todo   |                                         |
| CW-053 | Analytics (package + service + events)                 | app        | 1d   | CW-046         | todo   | `firebase_analytics` not on psc-dev yet |
| CW-054 | Routing + entry points                                 | app        | 0.5d | CW-006, CW-044 | todo   |                                         |
| CW-055 | Player profile doc `users/{uid}` on sign-in            | app, rules | 0.5d | CW-010         | todo   | Leaderboard needs `displayName`         |




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


| ID      | Decision                       | Status       | Choice / recommendation                                                                                                                                                                |
| ------- | ------------------------------ | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DEC-001 | Daily puzzle date key timezone | Accepted     | **IST (Asia/Kolkata)** for all daily keys on this app.                                                                                                                                 |
| DEC-002 | Environments                   | **Accepted** | One Firebase project per environment. Dev = `kerala-pcs-dev` (`(default)` database). Prod = a new project in CW-076. Functions take **no** `databaseId` parameter.                     |
| DEC-003 | Answers on the client          | Accepted     | Puzzle doc carries **encoded** answers for offline Check/Reveal; real key in private `crosswordSolutions`; server re-scores.                                                           |
| DEC-004 | Answer alphabet                | Accepted     | Phase 1 answers are English A–Z only; Malayalam crossword is NEXT-002.                                                                                                                 |
| DEC-005 | Bloc style for new code        | Accepted     | `sealed class` events/states in one bloc file. Existing freezed blocs (`auth`, `game`) stay as they are.                                                                               |
| DEC-006 | Player root document           | Accepted     | `users/{uid}` (already in `FirebaseCollections`) replaces `userGameStates/{uid}` from the `development` design.                                                                        |
| DEC-007 | App home                       | **Open**     | Recommended: Crossword Home becomes the start screen (bottom nav: Play · Revise · Ranks · Profile); today's daily word game moves to a card on Home. Today `/game` is the start route. |
| DEC-008 | Hints in phase 1               | Proposed     | No ads or purchases at launch: "Show a clue" is free; each puzzle allows 3 reveals (letter = 1, word = 3) with XP penalties. Monetization is NEXT-005/006.                             |
| DEC-009 | Firebase region | Accepted | **`asia-south1` (Mumbai)** for Firestore and Functions in every environment. Dev's `(default)` DB (first made in `nam5`) is recreated in CW-008. |


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
- [ ] Claude Code shows the skills in the `/` menu; Cursor lists the rules under Settings → Rules



#### CW-004 · Crossword collection constants

Add to `lib/core/firebase/collections.dart` (keep `games`, `users`) and to `functions/src/crossword/collections.ts`. No string literals for collection names anywhere else.

Done when:

- [ ] Constants: `crosswordCategories`, `crosswordPuzzles`, `crosswordSolutions`, `crosswordDaily`, `pscQuestions`, `crosswordProgress`, `revisionItems`, `leaderboards`, `leaderboardEntries` (`entries`), `contentReports`, `adminAuditLog`



#### CW-005 · Remote Config

Add `firebase_remote_config`; create `lib/core/remote_config/app_remote_config.dart` (abstract class + Firebase impl, pattern from `development`'s `story_mode_config.dart`), initialize in `di.dart` with in-app defaults, fetch with a 1 h minimum interval.

Done when:

- [x] Keys with defaults: `crossword_hint_penalties` (`{"letter":5,"word":15}`), `crossword_reveals_per_puzzle` (3), `xp_level_formula` (`{"base":100,"growth":1.25}`), `crossword_autosave_seconds` (30), `min_supported_build` (0)
- [ ] App works offline on first launch using defaults



#### CW-006 · App shell

`StatefulShellRoute.indexedStack` with a bottom bar: Play · Revise · Ranks · Profile (placeholders except Play). Use `GameScaffold`/theme colours. Depends on DEC-007 for which screen Play shows.

Done when:

- [ ] Tabs keep their state when switching; back button behaves on Android
- [ ] Auth redirect still works (signed-out → `/auth`)



#### CW-007 · `functions/` codebase

Create the Cloud Functions project (TypeScript, Node 20, `firebase-functions` v2, `firebase-admin`), copying tooling from `development/functions`: `package.json` scripts, `tsconfig*.json`, `.eslintrc.js` (google style), `jest.config.js`. Add `functions` to `firebase.json`. Shared helpers:

- `src/firestore.ts` → `export const db = () => getFirestore();`
- `src/admin/assertAdmin.ts` → `assertAdmin(request): string` (no `parseDatabaseId`)
- `src/admin/auditLog.ts` → `writeAuditLog({action, adminUid, targetId?, payload?})`
- `src/utils/dateId.ts` (`todayIstDateId()`, `isValidDateId()`), `src/utils/isoWeekId.ts`
- `setGlobalOptions({region: "asia-south1", maxInstances: 10})` in `src/index.ts`

Done when:

- [x] `npm run lint && npm run build && npm test` pass with tests for `assertAdmin`, `dateId`, `isoWeekId`
- [ ] `firebase emulators:start --only functions,firestore` boots



#### CW-008 · Blaze plan, budget, location

Cloud Functions and scheduled jobs need the Blaze (pay-as-you-go) plan on `kerala-pcs-dev`.

Done when:

- [x] Blaze enabled; budget alerts at $10 and $25 / month on the billing account
- [x] Firestore location written in `docs/firebase/FIREBASE_DESIGN.md` (ideally `asia-south1`; it can't change later — if it's elsewhere, keep functions in the nearest region)
- [ ] `firebase firestore:databases:list` shows `(default)` with `locationId: asia-south1`



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
Add `@firebase/rules-unit-testing` to `functions` dev deps and `src/rules/rules.test.ts` running on the emulator. The rules in the design doc were reviewed by hand but not yet run on the emulator — expect small fixes.

Done when:

- [ ] Tests prove: player **cannot** set own `xp`; **cannot** read `crosswordSolutions` / `pscQuestions` / a `draft` puzzle; **cannot** write content; **cannot** lower `elapsedSec`/hints; **cannot** edit a `completed` progress doc; **can** create a valid report but not read it
- [ ] Daily word game still works on a real device



#### CW-011 · Indexes + field overrides

Merge the JSON in the design doc into `firestore.indexes.json` (currently empty).

Done when:

- [ ] `firebase deploy --only firestore:indexes` succeeds; indexes show "Enabled"



#### CW-012 · Shared TS types

`functions/src/crossword/types.ts`: `CrosswordCategory`, `PscQuestion`, `CrosswordPuzzle`, `CrosswordWord`, `CrosswordProgress`, `CrosswordResult`, `RevisionItem`, `LeaderboardEntry`, `ContentReport`, `UserProfile`, plus enums as string unions. Field names exactly as the design doc.

Done when:

- [ ] `npm run build` passes; no `any`



#### CW-013 · Grid validator

`functions/src/crossword/validatePuzzle.ts` — pure function, throws `PuzzleValidationError` listing **all** problems. Same checks as `.claude/skills/crossword-content/scripts/validate_crossword.py`.

Done when:

- [ ] Checks: layout length = rows×cols; every word fits and fills its whole run; crossing letters agree; every `.` cell is in ≥1 word; no 2+ letter run without a word; answers `^[A-Z]{2,}$`; ids = `{number}{A|D}`; numbering follows standard order
- [ ] Jest tests for each failure + the example puzzle passes



#### CW-014 · Answer encoding

One reversible encoding shared by TS and Dart: `answerEnc = base64(utf8(answer) XOR utf8(puzzleId + ":" + wordId))`, key repeated. **Obfuscation, not security.** Reference implementation: `.claude/skills/crossword-content/scripts/validate_crossword.py --encode`.

Done when:

- [ ] `encodeAnswer`/`decodeAnswer` in TS + Dart, both with tests using the same fixtures, including `VAIKOM` / `kerala-history-0012` / `2D` → `PSQ7KiMs`



#### CW-015 · `adminSaveCategory`

Admin callable. Upsert by slug; validates slug `^[a-z0-9-]+$`, `name.en` required, `order` int.

Done when:

- [ ] `assertAdmin` + `writeAuditLog` used; unit test for validation



#### CW-016 · `adminSaveQuestion` + `adminVerifyQuestion`

Create/edit `pscQuestions`; answer normalized (uppercase, strip spaces/hyphens/dots) and must match `^[A-Z]{2,}$`; `source` required. Verify sets `status: verified`, `verifiedBy`, `verifiedAt`. Editing a verified question sets it back to `draft`.

Done when:

- [ ] Tests: normalization, missing source rejected, re-edit resets status



#### CW-017 · `adminSaveCrosswordPuzzle`

Input: puzzle with plain `answer` per word. Steps: load all `questionId`s (must be `verified`), run validator, encode answers, write puzzle (`status: draft`) + `crosswordSolutions/{id}` in **one batch**, add puzzle id to each question's `usedInPuzzles`. New puzzles get the next `number` in the category.

Done when:

- [ ] Rejects unverified questions and invalid grids with readable errors
- [ ] Re-saving a `published` puzzle is refused (archive → copy instead)



#### CW-018 · `adminSetPuzzleStatus` + `adminScheduleDaily`

State machine: `draft→in_review→scheduled→published→archived`, plus `in_review→draft` and `in_review→published` (publish now). Publishing sets `publishedAt` and increments `crosswordCategories.publishedPuzzleCount` (transaction); archiving decrements. `adminScheduleDaily({dateId, puzzleId})` writes `crosswordDaily/{dateId}`; puzzle must be `scheduled` or `published`.

Done when:

- [ ] Tests for every allowed and refused transition



#### CW-019 · `submitCrossword`

Player callable. Input `{puzzleId, letters, elapsedSec, hintsUsed}`. See design doc "Player: finish".

- Idempotent: if progress is `completed`, return stored result.
- Score each word against `crosswordSolutions`; XP = `xpReward` − penalties (floor 0); revealed words count as wrong for revision.
- Plausibility: refuse `elapsedSec < wordCount × 2`; rate limit 30/hour/user (`users/{uid}.rateLimit`).
- One batch: progress result, `users/{uid}.xp` + `crossword` stats (streak by IST date), leaderboard entry `crossword-{isoWeek}`, `revisionItems` upserts.

Done when:

- [ ] Jest tests: scoring, penalties, idempotency, streak continue/reset, rejection cases
- [ ] Emulator test: full submit writes all 4 places



#### CW-020 · `crosswordDailyRollover`

`onSchedule({schedule: "5 0 * * *", timeZone: "Asia/Kolkata"})`: publish puzzles whose `publishAt ≤ now`; log an error if tomorrow has no `crosswordDaily` doc.

Done when:

- [ ] Unit test for the selection logic; manual run on dev



#### CW-021 · `refreshLeaderboardTop`

`onSchedule("every 15 minutes")`: read the current week's top 50 entries and write `top50` + `updatedAt` on the board's parent doc.

Done when:

- [ ] Reads ≤ 50 docs per run (check logs)



#### CW-022 · Reports callables

`adminListReports({status, limit})`, `adminResolveReport({reportId, status, note})`.

Done when:

- [ ] Audit log written on resolve



#### CW-023 · Export, deploy, smoke test

Export from `functions/src/index.ts`. Deploy rules, indexes, functions to `kerala-pcs-dev`.

Done when:

- [ ] With the admin panel (or the emulator UI before M2): create category → question → puzzle → publish; a test account can submit and see the result



#### CW-024 · Admin claim script

Port `functions/src/scripts/setAdminClaim.ts` from `development` (`npm run admin:claim -- you@example.com`), defaulting to project `kerala-pcs-dev`.

Done when:

- [ ] Your account has `admin: true` (check: `getIdTokenResult().claims.admin`)



### M2 · Admin panel



#### CW-029 · Admin foundation

psc-dev has no web target. Add it (`fvm flutter create --platforms web .`, then `flutterfire configure` for a web app in `kerala-pcs-dev`). Port from `development`: `lib/main_admin.dart` (entry), `lib/app/bootstrap_admin.dart`, `lib/di_admin.dart`, `lib/core/routes/admin_router.dart`, `features/admin/data/admin_auth_service.dart` (Google sign-in + `admin` claim check), `admin_shell_page.dart`, `admin_login_page.dart`, and an `AdminApiService` with a `_call(name, data)` helper using `FirebaseFunctions.instanceFor(region: 'asia-south1')`. Drop the database switcher (DEC-002); show the project id as an environment badge.

Done when:

- [ ] `fvm flutter run -t lib/main_admin.dart -d chrome` → non-admin is refused, admin reaches the shell
- [ ] The mobile app build is unaffected



#### CW-030 · `AdminApiService` crossword methods

Typed methods for every crossword callable; models in `lib/features/admin/domain/models/`.

Done when:

- [ ] Each method has a `fromJson` model; errors surface as snackbars with the server message



#### CW-031 · Categories page

List, add/edit, reorder (`order`), toggle `isActive`.

#### CW-032 · Question bank page

Filter by subject + status; add/edit form (answer, display EN/ML, clues, fact, examTags, difficulty, source); Verify button.

#### CW-033 · Puzzle builder

Grid editor (up to 15×15), place a verified question across/down at a cell, auto-numbering, crossing conflicts highlighted, validator errors listed live (port of CW-013 in Dart, or a `dryRun` flag on `adminSaveCrosswordPuzzle`).

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

`lib/features/crossword/domain/entities/`: `CrosswordCategoryEntity`, `CrosswordPuzzleEntity`, `CrosswordWordEntity`, `CrosswordDailyEntity`, `CrosswordProgressEntity`, `CrosswordResultEntity`, `RevisionItemEntity`, and shared `LocalizedText` in `lib/shared/domains/entities/`. Equatable, immutable.

Done when:

- [ ] Generated with the `flutter-feature` skill; no Firebase imports in domain



#### CW-041 · Data layer

Models (`fromJson/toJson`, `documentId` param), `CrosswordContentDataSource` (daily, categories, puzzles paged by `number desc` 20/page, puzzle by id) and `CrosswordProgressDataSource` (get, save, submit via `FirebaseFunctions`), `CrosswordRepositoryImpl`. `FirebaseFirestore` and `FirebaseFunctions` injected from `di.dart`.

Done when:

- [ ] Queries include `isActive == true` / `status == 'published'` (rules require it)
- [ ] Model tests with real-shaped JSON fixtures



#### CW-042 · Use cases + DI

`LoadCrosswordHomeUseCase`, `LoadCategoryPuzzlesUseCase`, `LoadPuzzleUseCase`, `SaveCrosswordProgressUseCase`, `SubmitCrosswordUseCase`, `LoadRevisionItemsUseCase`, `SetRevisionMasteredUseCase`, `ReportContentUseCase`. Register in `di.dart` → `_initializeCrossword()`.

#### CW-043 · Grid engine

Pure Dart in `lib/features/crossword/domain/utils/crossword_grid.dart`: parse layout, cell→word lookup, next/prev cell, tap-twice direction toggle, backspace behaviour, check (per-cell correct/wrong), reveal letter/word, `isSolved`. Uses decoded answers.

Done when:

- [ ] ≥ 90% line coverage on the engine; the example puzzle is used in tests



#### CW-044 · Crossword Home

Matches `design/screens/psc-crossword.md#1-home`: daily card, categories grid with progress, streak chip, EN/ML toggle (EN only in phase 1). Reuse `GameScaffold`, `AppButton`, `FadeSlideIn`.

#### CW-045 · Category list

Paged list (20), puzzle number, title, difficulty, solved state from progress.

#### CW-046 · Puzzle screen

Matches `#2-puzzle`. Grid, active word highlight, clue bar with prev/next, clue chips, on-screen keyboard (reuse/extend `features/game/presentation/widgets/keyboard/`), timer, Check.

Done when:

- [ ] Works on 360 px wide screens; touch targets ≥ 44 px
- [ ] Widget test for the active-word highlight



#### CW-047 · Progress autosave

Save on `AppLifecycleState.paused`, on route pop, and every `crossword_autosave_seconds` if dirty. Never per keystroke.

Done when:

- [ ] Log shows ≤ 1 write per 30 s during continuous typing



#### CW-048 · Hints sheet (phase 1 variant, DEC-008)

Matches `#3-hints` except the balance row: "3 reveals left in this puzzle" (from `crossword_reveals_per_puzzle`). Show clue = free; reveal letter = 1; reveal word = 3; no ad button, no "Get more". Increments `hintsUsed` locally.

#### CW-049 · Submit + Results

Matches `#4-results`. Calls `submitCrossword`, shows score, time, correct/total, XP, streak, level bar (level from `xp_level_formula`), mistakes with facts. No extra reads after submit.

#### CW-050 · My mistakes / Revise

List `revisionItems` where `mastered == false` newest first; button to mark as learned. Lives in the Revise tab (CW-006).

#### CW-051 · Crossword leaderboard page

Ranks tab: read `leaderboards/crossword-{isoWeek}` `top50`; own rank via `count()` query; own row pinned at the bottom.

#### CW-052 · Report a wrong answer

From the clue bar menu: reason + optional message → `contentReports`.

#### CW-053 · Analytics

Add `firebase_analytics`; create `lib/core/analytics/analytics_service.dart` + `analytics_events.dart` (pattern from `development`). Events: `crossword_open`, `crossword_start`, `crossword_hint` (type), `crossword_check`, `crossword_submit` (score, time), `crossword_report`.

#### CW-054 · Routing + entry points

Routes `/crossword`, `/crossword/category/:id`, `/crossword/puzzle/:id`, `/crossword/puzzle/:id/result`, `/revise`, `/ranks`. Auth page navigates to the shell's Play tab after sign-in.

#### CW-055 · Player profile doc

After sign-in (Google or guest), create/merge `users/{uid}` with `displayName` (Google name or "Guest 1234"), `photoUrl`, `isAnonymous`, `createdAt` (create only), `lastSeenAt`. Only these keys — the rules reject anything else. Every write must send `lastSeenAt: FieldValue.serverTimestamp()` (the rule checks it).

Done when:

- [ ] New and returning users get a valid doc; a write including `xp` is rejected by rules



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

GitHub Actions on PRs to `psc-dev`: `fvm flutter analyze`, `fvm flutter test`, `npm --prefix functions run lint`, `npm --prefix functions test`, rules tests on the emulator.

#### CW-071 · Manual test scenarios

`docs/qa/crossword-manual-tests.md`: sign-in paths, offline play, autosave/resume, submit twice, hints, report, leaderboard week rollover.

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