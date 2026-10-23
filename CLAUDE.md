# CLAUDE.md — Kerala PSC App

Guidance for Claude Code (and Cursor) working in this repository. Read this first, then `TASKS.md`.

## What this project is

A Flutter app of **Kerala PSC exam-prep games**, built on the `psc-dev` branch (a fresh, slim start from the WordSchool codebase).

- **On the branch today:** Google + guest sign-in, a daily word game (`features/game`), shared UI widgets.
- **Phase 1 (now):** **PSC Crossword** — topic crosswords built from a verified PSC fact bank, with an admin panel and Cloud Functions.
- **Phase 2 (later):** Kerala Map Challenge (designs ready in `design/`).

The older full WordSchool app lives on `development`. Port code from there when a task says so (admin panel, functions tooling, flavors, analytics) — don't merge the branches.

Package name is `wordshool` (sic). **Do not rename** it, or the misspelled folders `resorces`, `repostiories`, `usercases` — imports depend on them.

## Where things are

| Need | Look in |
| --- | --- |
| What to work on | `TASKS.md` (status board + task cards + decisions) |
| Firestore schema, rules, indexes, costs | `docs/firebase/FIREBASE_DESIGN.md` |
| Screen specs, tokens, prototypes | `design/` |
| PSC content drafts | `content/` |
| Daily change log | `docs/daily/YYYY-MM-DD.md` |
| Generators and workflows | `.claude/skills/` (see "Skills") |

## Commands

Flutter **3.32.0** pinned with **FVM** (`.fvmrc`) — always prefix with `fvm`.

```bash
cp .env.example .env                      # first time
fvm flutter pub get
fvm flutter run                           # player app → Firebase project kerala-pcs-dev
fvm flutter analyze
fvm flutter test
fvm dart run build_runner build --delete-conflicting-outputs   # only for existing freezed files

# after CW-007 (functions, Python) / CW-029 (admin):
cd functions && python3.12 -m venv venv && venv/bin/pip install -r requirements-dev.txt   # first time
cd functions && venv/bin/ruff check . && venv/bin/ruff format --check . && venv/bin/pytest
firebase emulators:start --only functions,firestore
fvm flutter run -t lib/main_admin.dart -d chrome
firebase deploy --only firestore:rules,firestore:indexes,functions   # project kerala-pcs-dev
```

Before saying a task is done: `fvm flutter analyze` and `fvm flutter test` pass; if `functions/` changed, `ruff check`, `ruff format --check` and `pytest` pass.

## Architecture (Flutter)

Clean architecture per feature, `get_it` for DI, `flutter_bloc` for state, `go_router` for navigation.

```
lib/
  config/themes/  colors.dart (MyColors, MyColorScheme.dark), fonts.dart (Nunito)
  core/           constants, enums, firebase (collections, dt_converter), resorces (DataState, UseCase),
                  routes (app_router.dart), utils
  shared/         session (SessionHandler, user entity/model), shared widgets
  features/<feature>/
    domain/
      entities/       <name>.dart                → class <Name>Entity extends Equatable
      repositories/   <feature>_repository.dart  → abstract class <Feature>Repository
      usecases/       <verb>_<noun>.dart         → class <Verb><Noun>UseCase extends UseCase<R, P>
      usecases/utils/ <verb>_<noun>_param.dart   → class <Verb><Noun>Param
      utils/          pure logic (engines, calculators) — fully unit tested
    data/
      models/         <name>.dart                → class <Name>Model extends <Name>Entity (fromJson/toJson)
      data_source/    <name>_service.dart        → abstract class <Name>DataSource
      data_source/remote/ <name>_service.dart    → class <Name>DataSourceImpl extends <Name>DataSource
      repositories/   <feature>_repository_impl.dart
    presentation/
      bloc/<name>_bloc/<name>_bloc.dart          (new code: sealed events + states in this file)
      pages/          <name>_page.dart           (static const routeName)
      widgets/
  di.dart         _initialize<Feature>() per feature, called from initializeDependency()
  main.dart       Firebase init → dotenv → DI → initial route from FirebaseAuth state
```

### Rules that keep the code consistent

- **Results:** data sources and repositories return `Future<DataState<T>>` — `DataSuccess(data:)` or `DataError(error: AppError(...))`. Never throw across layers. Catch in the data source and include the error code and context.
- **Use cases:** `extends UseCase<ReturnType, ParamType>`, single `call({required param})`; params are small immutable classes in `usecases/utils/`.
- **Firebase access:** data sources receive `FirebaseFirestore` / `FirebaseFunctions` / `FirebaseAuth` through their constructor; only `di.dart` touches `.instance`. Collection names come from `lib/core/firebase/collections.dart`.
- **DI:** `getIt.registerSingleton<Abstract>(Impl(...))` inside `_initialize<Feature>()`; blocs are created in `app_router.dart` / `BlocProvider`, not registered.
- **Bloc (new code):** `sealed class XEvent` / `sealed class XState` with `final class` subclasses in the bloc file (DEC-005). The existing freezed blocs in `auth` and `game` stay as they are.
- **Domain is pure:** no Flutter, Firebase or `get_it` imports in `domain/`.
- **Models:** `factory X.fromJson(Map<String, dynamic> json, {String? documentId})` + `toJson()`. Timestamps via `FirebaseDTConverter`. Localized text as `LocalizedText` (`{en, ml}`, added in CW-040).
- **UI:** build on the shared widgets — `GameScaffold`, `AppButton` (variants), `PressableScale`, `FadeSlideIn`, `ShimmerGridItem`, `snackbar.dart`. Colours from `MyColors` / tokens in `design/tokens/`; no hex in widgets.
- **Config:** tunables in Remote Config (CW-005); secrets/keys in `.env` (never committed).
- **Dates:** daily keys are IST `YYYY-MM-DD` (DEC-001).
- **No `print`** in new code (add a small logger if needed; `development` has `AppLogger` to port).

## Firebase

- **One project per environment (DEC-002).** Dev = `kerala-pcs-dev`, `(default)` database. Prod project comes in CW-076. No `databaseId` parameters anywhere.
- **Player root doc is `users/{uid}` (DEC-006).** The client may write only profile fields; `xp`, `crossword`, `rateLimit`, `blockedAt` are server-only.
- **Content is admin-only.** Apps never write content collections. Admin panel → admin callables (`assertAdmin` → validate → batch → `writeAuditLog`) → Firestore.
- **Scores are server-side.** XP, streaks, leaderboards, results come from functions (`submitCrossword`).
- **Rules are operation-scoped:** each client update lists exactly which keys may change (`diff(resource.data).affectedKeys().hasOnly([...])`); values that only go up are checked; everything not matched is denied.
- **Cost habits:** one-time `get()` for lists (no list listeners); paginate at 20; batch progress saves (pause / leave / 30 s, never per keystroke); read summary docs (`top50`, `crosswordDaily`) instead of collections; `fieldOverrides` to turn off indexing on big fields.
- Full schema: `docs/firebase/FIREBASE_DESIGN.md`. Schema change = update that doc in the same PR.

## Cloud Functions (`functions/`, from CW-007)

- **Python 3.12** (DEC-010), `firebase-functions` Python SDK (`https_fn.on_call`, `scheduler_fn.on_schedule`, `firestore_fn.on_document_*`), `firebase-admin`. Dependencies in `requirements.txt` (deployed) and `requirements-dev.txt` (ruff, pytest); local venv in `functions/venv` (the Firebase CLI needs that path).
- **ruff** lint + format (config in `pyproject.toml`): line length 100, type hints on every function, Google-style docstrings on public functions, `snake_case` names. Firestore field names stay camelCase.
- Region `asia-south1` via `set_global_options` in `main.py`; schedules use `timezone="Asia/Kolkata"`.
- Admin callables: `admin_uid = assert_admin(req)` first, `write_audit_log(...)` last. Player callables: auth check, `users/{uid}.blockedAt` check, idempotent.
- Pure logic (validation, scoring, encoding) in its own module with a `<module>_test.py` beside it (pytest). No Firestore imports in pure modules.
- Crossword code in `functions/crossword/`; every deployed function imported in `functions/main.py`.
- Deployed names stay camelCase as in the design doc, because the apps call them by name: `def submitCrossword(req: https_fn.CallableRequest) -> dict:  # noqa: N802`. Everything else is snake_case.

## Tests

- Flutter: `test/` mirrors `lib/`. Pure logic first (grid engine, scoring, model `fromJson`), then bloc and widget tests.
- Functions: pytest for every validator and scoring rule; emulator rules tests for every collection (CW-010 picks the harness).
- Bug fix = a failing test first.

## Working on tasks

1. Find the task in `TASKS.md`; set its board status to `doing`.
2. Branch `feat/CW-0XX-short-name` from `psc-dev` (`chore/` for ops, `fix/` for bugs).
3. Use the matching skill. Keep the change inside the card's scope; extra work becomes a new task.
4. Tick the card's "Done when" boxes; run analyze/tests; set status `review`.
5. Commit `CW-0XX: what changed`; one task per PR into `psc-dev`.
6. Add notable changes to `docs/daily/YYYY-MM-DD.md`.

## Skills (`.claude/skills/`)

| Skill | Use it to |
| --- | --- |
| `task-workflow` | Pick the next task, start one, finish one, add/split tasks |
| `flutter-feature` | Scaffold entity → model → data source → repo → use case → bloc → page, and wire DI/routes |
| `cloud-function` | Scaffold an admin callable, player callable, scheduled job or trigger, with tests |
| `firestore-collection` | Add a collection end to end: constants, rules + tests, indexes, design doc |
| `crossword-content` | Draft PSC questions and crossword puzzles as JSON; validate grids |

## Design

- Dark theme (`MyColorScheme.dark()`): background `#121213`, tiles `#538D4E` / `#B59F3B`. Filled buttons with white text use `#467A41` (contrast). Tokens in `design/tokens/psc-crossword.tokens.json`.
- Screen specs: `design/screens/psc-crossword.md`. Touch targets ≥ 44 px; works at 360 px width.

## Don'ts

- Don't write content or score fields from the app.
- Don't add list listeners or save on every keystroke.
- Don't hard-delete content — set `status: archived`.
- Don't commit `.env`, service-account keys or signing files.
- Don't merge `development` into `psc-dev`; port only what a task names.
- Don't add packages without saying why in the PR.
