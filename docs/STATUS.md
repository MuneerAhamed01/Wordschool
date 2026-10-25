# Project status — snapshot

> **Read this first** for "where are we / what's next / what's deployed". It is a cache of
> `TASKS.md`, git and Firebase so a status question costs one small file, not a code scan.
> Open code only when a task needs it. **Update this file whenever a board status, a deploy or a
> milestone changes** (same change as `TASKS.md`).

**Last updated:** 2026-10-25 · **Integration branch:** `psc-dev` · **Firebase (dev):** `kerala-pcs-dev` (`asia-south1`)

## Milestones

| Milestone | Target | State | Done / total |
| --- | --- | --- | --- |
| M0 Foundations | 2026-11-04 | **closed 2026-10-23** | 9 / 9 |
| M1 Backend: rules, indexes, functions | 2026-11-18 | **closed 2026-10-23** | 17 / 17 (CW-010 … CW-026; CW-026 live check → CW-071) |
| M2 Admin panel (Flutter web) | 2026-12-04 | **closed 2026-10-25** | 8 / 8 (CW-029 … CW-036) |
| M3 Player app | 2026-12-24 | **closed 2026-10-25** | 16 / 19 done (CW-040 … CW-052, CW-054, CW-055, CW-058) · CW-053, CW-057 `not-needed` · CW-056 `todo` (follow-up) |
| M4 Content | 2026-12-31 | not started (runs in parallel) | 0 / 4 (CW-060 … CW-063) |
| M5 QA & launch | 2027-01-15 | not started | 1 / 7 (CW-073 dropped into CW-008) |

**In review:** nothing. M3 merged into `psc-dev` and pushed 2026-10-25 (QA: `docs/qa/M3-manual-test.md`). **Blocked:** nothing. **Not needed:** CW-053 analytics, CW-057 solved-by-category summary (reasons on the cards).

## Next up (unblocked `todo`, lowest milestone first)

| ID | Task | Est | Why it's unblocked |
| --- | --- | --- | --- |
| CW-056 | Home: offline banner + Remote Config feature gate | 0.5d | Needs CW-044 (done) |
| CW-060 | Seed 5 categories (content) | 0.25d | Needs CW-031 (done) — use the admin panel |
| CW-061 | 150 verified questions | ongoing | Needs CW-032 (done) — CSV bulk upload is ready (CW-036) |
| CW-070 | CI: analyze, tests, lint, rules tests | 1d | Needs CW-009, CW-010 (done) |

CW-056 is the one M3 follow-up left `todo` when M3 closed.

## Deployed on `kerala-pcs-dev`

- **Rules + indexes:** deployed 2026-10-23 (CW-010, CW-011). No changes since.
- **Functions (Python 3.12, `asia-south1`)** — 16 in `functions/main.py`:
  - Admin callables: `adminSaveCategory`, `adminSaveQuestion`, `adminVerifyQuestion`, `adminSaveCrosswordPuzzle`,
    `adminSetPuzzleStatus`, `adminScheduleDaily`, `adminListReports`, `adminResolveReport`,
    `adminListCategories`, `adminListQuestions`, `adminListPuzzles`, `adminGetPuzzle`, `adminGetQuestion`
  - Player callable: `submitCrossword`
  - Scheduled (IST): `crosswordDailyRollover` (00:05), `refreshLeaderboardTop`
  - All 16 live (checked with `firebase functions:list` on 2026-10-25, M3 close).
- **Admin claim:** muneerahamed.dev@gmail.com (CW-024, `functions/scripts/set_admin_claim.py`).
- **Admin panel hosting:** none yet — run locally (`fvm flutter run -t lib/main_admin.dart -d chrome`).
- **Content in dev DB:** whatever was entered while reviewing M2; the real seed is M4.

## What exists in code (map, so you don't have to search)

| Area | Where | Notes |
| --- | --- | --- |
| Player app entry | `lib/main.dart`, `lib/di.dart`, `lib/core/routes/app_router.dart` | Shell tabs Play `/home` (Crossword Home) · Revise · Ranks · Profile; full-screen `/crossword/category/:id`, `/crossword/puzzle/:id`, `…/result` |
| Crossword (player) | `lib/features/crossword/{shared,home,category,puzzle(+hints,report),result,revise,leaderboard}/` | **File map: `docs/plans/M3-player-app.md`** — one folder per module with its own data/domain/presentation + `di.dart`; `shared/` = entities, progress cache, change signal. Modules don't import each other |
| Other player features | `lib/features/{auth,game,profile}` | One-module features; `profile` is a placeholder; auth writes `users/{uid}` in a transaction, not awaited (CW-055). Tab pages for Play/Revise/Ranks are the crossword module pages |
| Admin panel entry | `lib/main_admin.dart`, `lib/di_admin.dart`, `lib/core/routes/admin_router.dart` | Google popup + `admin` claim; theme `lib/config/themes/admin_theme.dart` |
| Admin code | `lib/features/admin/{shared,auth,shell,home,categories,questions,puzzles(+detail,builder),schedule,reports,bulk_upload}/` | `shared/data/data_source/` = `AdminCallable` + services used by 2+ sections (categories, questions, puzzles, schedule) and `AdminAuthService`; `shared/domain/` models + pure utils (grid validator, status flow, question text); each section keeps only its own code. Routes in `core/routes/admin_routes.dart` |
| Shared | `lib/shared/`, `lib/core/` | Widgets: `GameScaffold`, `AppButton`, `AppProgressBar`, `StateMessage`, `SkeletonBox`, `showAppSheet`, `category_visuals`; `Paged`. Core: `guardData()` (`core/resorces/data_guard.dart`), `json_read.dart` (one copy for app + admin), `ist_date.dart` (+ `istIsoWeekId`), `routes/app_routes.dart` |
| Remote Config | `lib/core/remote_config/app_remote_config.dart` (CW-005) | Server reads hint penalties from the same template (CW-026) |
| Functions | `functions/crossword/` | `<name>_logic.py` pure + `<name>.py` handler, `_test.py` beside each; helpers in `functions/{admin,utils}/`, `firestore_client.py` |
| Rules tests | `firestore-tests/` | Jest on the emulator |
| Tests | `test/` mirrors `lib/` (per module) | 214 green on 2026-10-25. Crossword fakes/fixtures: `test/features/crossword/crossword_{fakes,fixtures}.dart`, `fixtures_entities.dart`, `test/fixtures/crossword/` |
| Checks | `scripts/check.sh [paths] [--fn]` | analyze + `scripts/check_structure.py` (modules, `_build`, ≤ 700 lines, names) + tests, prints only problems + one summary line each |

## Known, accepted

- M3 needs no new deploy (no rules, index or function changes).

- `fvm flutter analyze` shows **6 old issues** in pre-PSC files (`colors.dart`, `game_page.dart`, `glowing_bulb.dart`, `wordle_tile/`). Accepted in CW-009; not a blocker.
- `tool/admin_preview.dart` is a local visual harness — **never commit it**.

## Ops — commands the user runs

```bash
# Deploy everything (idempotent; functions predeploy runs ruff + pytest)
firebase deploy --only firestore:rules,firestore:indexes,functions --project kerala-pcs-dev
```

## How to keep this file useful

- Change a board status in `TASKS.md` → update the milestone counts and "Next up" here.
- Deploy something → update "Deployed".
- New folder, entry point or big module → one row in "What exists in code".
- Keep it under ~120 lines; details belong in `TASKS.md` cards, the daily log or the design docs.
