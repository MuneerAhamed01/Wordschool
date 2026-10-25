# Project status — snapshot

> **Read this first** for "where are we / what's next / what's deployed". It is a cache of
> `TASKS.md`, git and Firebase so a status question costs one small file, not a code scan.
> Open code only when a task needs it. **Update this file whenever a board status, a deploy or a
> milestone changes** (same change as `TASKS.md`).

**Last updated:** 2026-10-25 · **Integration branch:** `psc-dev` · **Firebase (dev):** `kerala-pcs-dev` (`asia-south1`)

## Milestones

| Milestone | Target | State | Done / total |
| --- | --- | --- | --- |
| M0 Foundations | 2026-11-04 | **closed** | 9 / 9 |
| M1 Backend: rules, indexes, functions | 2026-11-18 | **closed** | 17 / 17 (CW-010 … CW-026) |
| M2 Admin panel (Flutter web) | 2026-12-04 | **closed 2026-10-25** | 8 / 8 (CW-029 … CW-036) |
| M3 Player app | 2026-12-24 | not started | 0 / 16 (CW-040 … CW-055) |
| M4 Content | 2026-12-31 | not started (runs in parallel) | 0 / 4 (CW-060 … CW-063) |
| M5 QA & launch | 2027-01-15 | not started | 1 / 7 (CW-073 dropped into CW-008) |

Nothing is `doing`, `review` or `blocked`.

## Next up (unblocked `todo`, lowest milestone first)

| ID | Task | Est | Why it's unblocked |
| --- | --- | --- | --- |
| CW-040 | Player domain entities | 1d | Needs CW-009 (done). `LocalizedText` already exists in `lib/shared/domains/entities/` |
| CW-055 | Player profile doc `users/{uid}` on sign-in | 0.5d | Needs CW-010 (done) |
| CW-060 | Seed 5 categories (content) | 0.25d | Needs CW-031 (done) — use the admin panel |
| CW-061 | 150 verified questions | ongoing | Needs CW-032 (done) — CSV bulk upload is ready (CW-036) |
| CW-070 | CI: analyze, tests, lint, rules tests | 1d | Needs CW-009, CW-010 (done) |

Then in M3: CW-041 → CW-042 → CW-043 (grid engine) → CW-044 … (see `TASKS.md`).

## Deployed on `kerala-pcs-dev`

- **Rules + indexes:** deployed 2026-10-23 (CW-010, CW-011). No changes since.
- **Functions (Python 3.12, `asia-south1`)** — 16 in `functions/main.py`:
  - Admin callables: `adminSaveCategory`, `adminSaveQuestion`, `adminVerifyQuestion`, `adminSaveCrosswordPuzzle`,
    `adminSetPuzzleStatus`, `adminScheduleDaily`, `adminListReports`, `adminResolveReport`,
    `adminListCategories`, `adminListQuestions`, `adminListPuzzles`, `adminGetPuzzle`, `adminGetQuestion`
  - Player callable: `submitCrossword`
  - Scheduled (IST): `crosswordDailyRollover` (00:05), `refreshLeaderboardTop`
  - `adminGetQuestion` (CW-035) was the only one not live on 2026-10-25 — deploy command in "Ops" below.
- **Admin claim:** muneerahamed.dev@gmail.com (CW-024, `functions/scripts/set_admin_claim.py`).
- **Admin panel hosting:** none yet — run locally (`fvm flutter run -t lib/main_admin.dart -d chrome`).
- **Content in dev DB:** whatever was entered while reviewing M2; the real seed is M4.

## What exists in code (map, so you don't have to search)

| Area | Where | Notes |
| --- | --- | --- |
| Player app entry | `lib/main.dart`, `lib/di.dart`, `lib/core/routes/app_router.dart` | Bottom nav shell (CW-006); Play = `/home` daily word card |
| Player features | `lib/features/{auth,game,home,profile,ranks,revise}` | `crossword/` holds only `domain/utils/answer_encoding.dart` (CW-014) until CW-040; `revise`, `ranks`, `profile` are placeholder pages |
| Admin panel entry | `lib/main_admin.dart`, `lib/di_admin.dart`, `lib/core/routes/admin_router.dart` | Google popup + `admin` claim; theme `lib/config/themes/admin_theme.dart` |
| Admin code | `lib/features/admin/` | `data/admin_api_service.dart` (all callables → `DataState`), `domain/models/`, `domain/utils/` (pure, tested: grid validator, puzzle draft, status flow, bulk import, csv), `presentation/pages/` (one per section) |
| Shared | `lib/shared/` | Session, `LocalizedText`, shared widgets |
| Remote Config | `lib/core/remote_config/app_remote_config.dart` (CW-005) | Server reads hint penalties from the same template (CW-026) |
| Functions | `functions/crossword/` | `<name>_logic.py` pure + `<name>.py` handler, `_test.py` beside each; helpers in `functions/{admin,utils}/`, `firestore_client.py` |
| Rules tests | `firestore-tests/` | Jest on the emulator |
| Tests | `test/` mirrors `lib/` | 103 Flutter tests green on 2026-10-25 |

## Known, accepted

- `fvm flutter analyze` shows **6 old issues** in pre-PSC files (`colors.dart`, `game_page.dart`, `glowing_bulb.dart`, `wordle_tile/`). Accepted in CW-009; not a blocker.
- `tool/admin_preview.dart` is a local visual harness — **never commit it**.

## Ops — commands the user runs

```bash
# Deploy everything (idempotent; functions predeploy runs ruff + pytest)
firebase deploy --only firestore:rules,firestore:indexes,functions --project kerala-pcs-dev
# Just the M2 leftover
firebase deploy --only functions:adminGetQuestion --project kerala-pcs-dev
```

## How to keep this file useful

- Change a board status in `TASKS.md` → update the milestone counts and "Next up" here.
- Deploy something → update "Deployed".
- New folder, entry point or big module → one row in "What exists in code".
- Keep it under ~120 lines; details belong in `TASKS.md` cards, the daily log or the design docs.
