# CLAUDE.md — Kerala PSC App

Guidance for Claude Code (and Cursor) working in this repository.

**Reading order (keeps token use low):**
1. This file.
2. `docs/STATUS.md` — milestones, what's next, what's deployed, a map of the code. **Answer status / "what's next" / "what's deployed" questions from this file alone**; don't scan code or git for them.
3. `TASKS.md` — only the board row and card of the task you're on (search for `CW-0XX`; don't read the whole file).
4. Module file map — `docs/plans/M<n>-*.md` (e.g. `M3-player-app.md` lists every crossword file and what to copy).
5. Code — only the files the card names, plus the closest existing example of the same kind.

## What this project is

A Flutter app of **Kerala PSC exam-prep games**, built on the `psc-dev` branch (a fresh, slim start from the WordSchool codebase).

- **Phase 1 (now):** **PSC Crossword** — topic crosswords built from a verified PSC fact bank. Backend (M1) and admin panel (M2) are done, the player app (M3) is in review, content (M4) is next. Live state: `docs/STATUS.md`.
- **Phase 2 (later):** Kerala Map Challenge (designs ready in `design/`).

The older full WordSchool app lives on `development`. Port code from there when a task says so (admin panel, functions tooling, flavors, analytics) — don't merge the branches.

Package name is `wordshool` (sic). **Do not rename** it, or the misspelled folders `resorces`, `repostiories`, `usercases` — imports depend on them.

## Where things are

| Need | Look in |
| --- | --- |
| Where we are, what's next, what's deployed, code map | `docs/STATUS.md` (read first) |
| Task scope and "Done when" | `TASKS.md` (status board + task cards + decisions) |
| Module plans / file maps, QA checklists | `docs/plans/`, `docs/qa/` |
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
scripts/check.sh                          # analyze + structure rules + all tests, prints only problems (+ --fn, or test paths)
python3 scripts/check_structure.py        # just the structure rules (modules, _build, 700 lines, names)
fvm flutter analyze
fvm flutter test
fvm dart run build_runner build --delete-conflicting-outputs   # only for existing freezed files

# after CW-007 (functions, Python) / CW-029 (admin):
cd functions && python3.12 -m venv venv && venv/bin/pip install -r requirements-dev.txt   # first time
# no admin rights for `apt install python3.12-venv`? create it without pip, then bootstrap pip:
#   python3.12 -m venv --without-pip venv && curl -fsSL https://bootstrap.pypa.io/get-pip.py | venv/bin/python
#   venv/bin/pip install -r requirements-dev.txt
cd functions && venv/bin/ruff check . && venv/bin/ruff format --check . && venv/bin/pytest   # emulator tests skip
firebase emulators:exec --only firestore --project demo-kerala-pcs "cd functions && venv/bin/pytest"  # + emulator tests
cd firestore-tests && npm install && npm test             # rules tests (CW-010): Jest on the Firestore emulator
firebase emulators:start --only functions,firestore   # Firestore emulator needs Java 11+; Android Studio's works:
                                                      # export JAVA_HOME=/opt/android-studio/jbr PATH=$JAVA_HOME/bin:$PATH
fvm flutter run -t lib/main_admin.dart -d chrome
firebase deploy --only firestore:rules,firestore:indexes,functions   # project kerala-pcs-dev
```

Before saying a task is done: `scripts/check.sh` passes (= `fvm flutter analyze` with only the 6 accepted old issues, `scripts/check_structure.py` with 0 problems, and `fvm flutter test`); if `functions/` changed, `ruff check`, `ruff format --check` and `pytest` pass.

## Architecture (Flutter)

Clean architecture per feature, `get_it` for DI, `flutter_bloc` for state, `go_router` for navigation.

```
lib/
  config/themes/  colors.dart (MyColors, MyColorScheme.dark), fonts.dart (Nunito)
  core/           constants, enums, firebase (collections, dt_converter), resorces (DataState, UseCase),
                  routes (app_routes.dart / admin_routes.dart paths, app_router.dart, admin_router.dart), utils
  shared/         used by 2+ features: session, Paged, LocalizedText, shared widgets
  features/<feature>/                  e.g. crossword, admin
    shared/                            used by 2+ modules of this feature (same layers as a module)
    <module>/                          one screen area, e.g. crossword/home, crossword/revise, admin/reports
      <sub_module>/                    a sub-screen, sheet or dialog with its own logic, e.g. puzzle/report
        data/ domain/ presentation/
      domain/
        entities/       <name>.dart                → class <Name>Entity extends Equatable
        repositories/   <module>_repository.dart   → abstract class <Module>Repository
        usecases/       <verb>_<noun>.dart         → class <Verb><Noun>UseCase extends UseCase<R, P>
        usecases/utils/ <verb>_<noun>_param.dart   → class <Verb><Noun>Param
        utils/          pure logic (engines, calculators) — fully unit tested
      data/
        models/         <name>.dart                → class <Name>Model extends <Name>Entity (fromJson/toJson)
        data_source/    <name>_service.dart        → abstract class <Name>DataSource
        data_source/remote/ <name>_service.dart    → class <Name>DataSourceImpl extends <Name>DataSource
        repositories/   <module>_repository_impl.dart
      presentation/
        bloc/<name>_bloc.dart                      (sealed events + states in this file)
        pages/          <name>_page.dart           (static const routeName = AppRoutes.x)
        widgets/        one widget per file
      di.dart           init<Feature><Module>(GetIt) — called from features/<feature>/di.dart
  di.dart         _initialize<Feature>() per one-module feature; initCrossword(getIt) for crossword
  main.dart       Firebase init → dotenv → DI → initial route from FirebaseAuth state
```

A feature with a single screen (`auth`, `game`, `profile`) is its own module: `data/ domain/ presentation/`
sit directly in the feature folder. Admin modules are thin over callables: data sources (no repository /
use case) + pages; their shared services live in `admin/shared/data/data_source/`.

### Code structure rules (checked in review and by `scripts/check_structure.py`)

- **Modules are independent.** A file may import only its own module (and its sub-modules), its feature's
  `shared/`, and `lib/{core,config,shared}`. Anything a second module needs moves to `<feature>/shared/`;
  anything a second feature needs moves to `lib/shared` or `lib/core`. Only composition roots
  (`lib/di*.dart`, `lib/main*.dart`, `core/routes/*_router.dart`, `<feature>/di.dart`) import across modules.
- **Navigate by path, not by page.** Use `AppRoutes` / `AdminRoutes`; never import another module's page
  for its `routeName`. Pass data between modules as shared entities (e.g. `ResultArgs` via `extra`).
- **Talk between modules through shared state**, e.g. `CrosswordProgressRepository` (session cache) and
  `CrosswordChangesRepository` (`CrosswordChange.puzzleSubmitted` / `.revisionChanged`), not by importing
  each other's blocs or repositories.
- **One job per function and per file.** Split long `build` methods into `_build…` helpers or widgets;
  one public widget per file in `widgets/`.
- **Every function that returns a widget** (`Widget`, `Widget?`, `List<Widget>`) is `build` or starts with
  `_build` — including former local helpers (make them private methods).
- **No file over 700 lines** (generated `*.freezed.dart` / `*.g.dart` excepted). Split with widgets,
  `part` files + private extensions/mixins, or helpers in `utils/`.
- **Names don't repeat their folder.** Inside a module, file names don't carry the feature prefix or the
  folder kind: `crossword/shared/data/models/puzzle.dart`, not `…/models/crossword_puzzle_model.dart`.
  Class names keep their prefix (`CrosswordPuzzleModel`) so imports never clash.

### Rules that keep the code consistent

- **Results:** data sources and repositories return `Future<DataState<T>>` — `DataSuccess(data:)` or `DataError(error: AppError(...))`. Never throw across layers. Wrap each data-source method in `guardData('Source.method', () async {...})` (`core/resorces/data_guard.dart`): it catches, logs, keeps the Firebase code and sets a player-readable `message`. Read JSON with `core/utils/json_read.dart` (`asInt`, `asString`, …).
- **Use cases:** `extends UseCase<ReturnType, ParamType>`, single `call({required param})`; params are small immutable classes in `usecases/utils/`.
- **Firebase access:** data sources receive `FirebaseFirestore` / `FirebaseFunctions` / `FirebaseAuth` through their constructor; only `di.dart` touches `.instance`. Collection names come from `lib/core/firebase/collections.dart`.
- **DI:** `getIt.registerSingleton<Abstract>(Impl(...))` inside the module's `di.dart` (or `_initialize<Feature>()` for a one-module feature); blocs are created in `app_router.dart` / `BlocProvider`, not registered.
- **Firestore writes the player waits on** (leaving a screen, sign-in) are not awaited on the server ack — Firestore queues them offline. Use a bounded wait (`awaitServerAck`, `core/firebase/server_ack.dart`) or `unawaited`, never a bare `await` that hangs offline.
- **Lists:** never read a whole collection; page at 20 with a cursor that can't skip ties (order field + doc id), or use a count / summary doc.
- **After an `await` in a bloc handler**, re-read `state` and check its type before using it; never `state as X`.
- **Bloc (new code):** `sealed class XEvent` / `sealed class XState` with `final class` subclasses in the bloc file (DEC-005). The existing freezed blocs in `auth` and `game` stay as they are.
- **Domain is pure:** no Flutter, Firebase or `get_it` imports in `domain/`.
- **Models:** `factory X.fromJson(Map<String, dynamic> json, {String? documentId})` + `toJson()`. Timestamps via `FirebaseDTConverter`. Localized text as `LocalizedText` (`{en, ml}`, added in CW-040).
- **UI:** build on the shared widgets — `GameScaffold`, `AppButton` (variants), `PressableScale`, `FadeSlideIn`, `SkeletonBox` (loading), `StateMessage` (empty / error + retry), `AppProgressBar`, `showAppSheet` + `AppSheetHeader` (bottom sheets), `category_visuals.dart`, `snackbar.dart`. Colours from `MyColors` / tokens in `design/tokens/`; no hex in widgets.
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
- Full schema: `docs/firebase/FIREBASE_DESIGN.md`. Schema change = update that doc in the same change.

## Cloud Functions (`functions/`, from CW-007)

- **Python 3.12** (DEC-010), `firebase-functions` Python SDK (`https_fn.on_call`, `scheduler_fn.on_schedule`, `firestore_fn.on_document_*`), `firebase-admin`. Dependencies in `requirements.txt` (deployed) and `requirements-dev.txt` (ruff, pytest); local venv in `functions/venv` (the Firebase CLI needs that path).
- **ruff** lint + format (config in `pyproject.toml`): line length 100, type hints on every function, Google-style docstrings on public functions, `snake_case` names. Firestore field names stay camelCase.
- Region `asia-south1` via `set_global_options` in `main.py`; schedules use `timezone="Asia/Kolkata"`.
- Admin callables: `admin_uid = assert_admin(req)` first, `write_audit_log(...)` last. Player callables: auth check, `users/{uid}.blockedAt` check, idempotent.
- Pure logic (validation, scoring, encoding) in its own module with a `<module>_test.py` beside it (pytest). No Firestore imports in pure modules.
- Shape of a callable (see `functions/crossword/`): `<name>_logic.py` parses input with `InputReader` (collects every problem) and decides; `<name>.py` has a `do_thing(client, uid, data)` that reads/writes in one transaction (`run_transaction`) and the thin `@https_fn.on_call` handler wrapped in `with callable_errors():` (maps `InputError`/`NotFoundError`/`PreconditionError`/`PermissionDeniedError`/`RateLimitError` to `HttpsError`).
- Emulator tests use the `emulator_db` fixture (`functions/conftest.py`), which points every module's `db()` at the emulator; call real handlers with `inspect.unwrap(handler)(callable_request(data))`.
- Crossword code in `functions/crossword/`; every deployed function imported in `functions/main.py`.
- Deployed names stay camelCase as in the design doc, because the apps call them by name: `def submitCrossword(req: https_fn.CallableRequest) -> dict:  # noqa: N802`. Everything else is snake_case.

## Tests

- Flutter: `test/` mirrors `lib/`. Pure logic first (grid engine, scoring, model `fromJson`), then bloc and widget tests.
- Functions: pytest for every validator and scoring rule.
- Rules: `firestore-tests/firestore.rules.test.js` (Jest + `@firebase/rules-unit-testing`) — allow and deny cases for every collection.
- Crossword test kit: `test/features/crossword/crossword_fakes.dart` (fake repository + real use cases, `registerCrosswordFakes` for router tests) and `crossword_fixtures.dart` (JSON in `test/fixtures/crossword/`). Screens are tested at 360 × 740 (`tester.view.physicalSize`).
- In `testWidgets`, don't `await bloc.close()` at the end (it never completes in fake async); `scripts/check.sh` runs with a 60 s per-test timeout.
- Bug fix = a failing test first.

## Working on tasks

1. Find the task in `TASKS.md`; set its board status to `doing`.
2. Branch from `psc-dev`: one branch per milestone or group of tasks (e.g. `module/m2`), or `feat/CW-0XX-short-name` for a lone task (`chore/` for ops, `fix/` for bugs).
3. Use the matching skill. Keep the change inside the card's scope; extra work becomes a new task.
4. Tick the card's "Done when" boxes; run analyze/tests; set status `review`.
5. **Don't commit, push or merge until the user asks.** When asked: **one commit per task** (`CW-0XX: what changed`) on the current branch, push it (`git push -u origin <branch>`), merge into `psc-dev` and push that. No PRs — the user reviews the pushed branch. Docs-only changes go in a final `docs:` commit.
6. Add notable changes to `docs/daily/YYYY-MM-DD.md`.
7. **Update `docs/STATUS.md`** in the same change whenever a board status, a deploy or a milestone changes.
8. When a deploy is needed, give the user the exact `firebase deploy …` command to run; don't deploy yourself unless asked.

## Skills (`.claude/skills/`)

| Skill | Use it to |
| --- | --- |
| `task-workflow` | Pick the next task, start one, finish one, close a milestone, add/split tasks |
| `flutter-feature` | Scaffold entity → model → data source → repo → use case → bloc → page, and wire DI/routes |
| `cloud-function` | Add a Python admin callable, player callable, scheduled job or trigger, with pytest |
| `firestore-collection` | Add a collection end to end: constants, rules + tests, indexes, design doc |
| `crossword-content` | Draft PSC questions and crossword puzzles as JSON; validate grids |
| `cavemen` | Terse chat replies to save tokens (`/cavemen [lite\|full\|ultra\|off]`); files and code stay normal |

## Design

- Dark theme (`MyColorScheme.dark()`): background `#121213`, tiles `#538D4E` / `#B59F3B`. Filled buttons with white text use `#467A41` (contrast). Tokens in `design/tokens/psc-crossword.tokens.json`.
- Screen specs: `design/screens/psc-crossword.md`. Touch targets ≥ 44 px; works at 360 px width.

## Don'ts

- Don't write content or score fields from the app.
- Don't add list listeners or save on every keystroke.
- Don't hard-delete content — set `status: archived`.
- Don't commit `.env`, service-account keys or signing files.
- Don't merge `development` into `psc-dev`; port only what a task names.
- Don't add packages without saying why in the daily log.
- Don't hardcode credentials, even for a local test harness; `tool/` is local-only and never committed.
