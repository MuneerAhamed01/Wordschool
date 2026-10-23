# CLAUDE.md — WordSchool PSC

Guidance for Claude Code (and Cursor) working in this repository. Read this first, then `TASKS.md`.

## What this project is

**WordSchool** is a Flutter app of daily word games, now growing into a **Kerala PSC exam-prep games app**.

- **Live today:** daily Wordle, Story Mode (detective cases), streaks, weekly leaderboards, ads/IAP, admin panel (Flutter web).
- **Phase 1 (now):** **PSC Crossword** — topic crosswords built from a verified PSC fact bank.
- **Phase 2 (later):** Kerala Map Challenge (designs ready in `design/`).

Package name is `wordshool` (sic). **Do not rename** it, or existing misspelled folders (`resorces`, `repostiories`, `usercases`) — imports depend on them.

## Where things are

| Need | Look in |
| --- | --- |
| What to work on | `TASKS.md` (status board + task cards) |
| Firestore schema, rules, indexes, costs | `docs/firebase/FIREBASE_DESIGN.md` |
| Screen specs, tokens, prototypes | `design/` |
| Older feature docs (Story Mode phases, environments) | `technical_doc/` |
| Daily change log | `daily update/YYYY-MM-DD.md` |
| Generators and workflows | `.claude/skills/` (see "Skills" below) |

## Commands

Flutter is pinned with **FVM** — always prefix with `fvm`.

```bash
fvm flutter pub get
fvm flutter run -t lib/main_dev.dart --flavor dev      # player app, dev DB
fvm flutter run -t lib/main.dart -d chrome             # admin panel (web)
fvm flutter analyze
fvm flutter test
fvm dart run build_runner build --delete-conflicting-outputs   # only for existing freezed files

cd functions
npm run lint && npm run build && npm test
npm run serve                                          # emulators: functions + firestore
firebase deploy --only firestore:rules,firestore:indexes -P default
firebase deploy --only functions -P default
```

Before saying a task is done: `fvm flutter analyze` and `fvm flutter test` pass; if `functions/` changed, `npm run lint && npm test` pass.

## Architecture (Flutter)

Clean architecture per feature, `get_it` for DI, `flutter_bloc` for state, `go_router` for navigation.

```
lib/
  app/            bootstrap (game + admin)
  config/themes/  colors, fonts, theme
  core/           analytics, config, firebase, logging, monetization, remote_config,
                  resorces (DataState, UseCase), routes, utils
  shared/         cross-feature data/domain/widgets (user game state, session)
  features/<feature>/
    domain/
      entities/       <name>.dart           → class <Name>Entity extends Equatable
      repositories/   <feature>_repository.dart  → abstract class <Feature>Repository
      usecases/       <verb>_<noun>.dart    → class <Verb><Noun>UseCase extends UseCase<R, P>
      usecases/utils/ <verb>_<noun>_param.dart   → class <Verb><Noun>Param
      utils/          pure logic (calculators, engines) — fully unit tested
    data/
      models/         <name>.dart           → class <Name>Model extends <Name>Entity (fromJson/toJson)
      data_source/    <name>_service.dart   → abstract class <Name>DataSource
      data_source/remote/ <name>_service.dart → class <Name>DataSourceImpl extends <Name>DataSource
      repositories/   <feature>_repository_impl.dart
    presentation/
      bloc/<name>_bloc/<name>_bloc.dart     (sealed events + states in the same file)
      pages/          <name>_page.dart      (static const routeName)
      widgets/
      utils/
  di.dart         _initialize<Feature>() per feature, called from initializeDependency
  di_admin.dart   admin panel DI
```

### Rules that keep the code consistent

- **Results:** data sources and repositories return `Future<DataState<T>>` — `DataSuccess(data:)` or `DataError(error: AppError…)`. Use `AppError.notFound / validation / cancelled / fromException`. Never throw across layers.
- **Use cases:** `extends UseCase<ReturnType, ParamType>`, single `call({required param})`. Params are small immutable classes in `usecases/utils/`. `void` when there is no param.
- **Firestore:** inject `FirebaseFirestore` via constructor (it is environment-scoped by `FirestoreProvider`). **Never** use `FirebaseFirestore.instance` in features. Collection names come from `lib/core/firebase/collections.dart`.
- **DI:** `getIt.registerSingleton<Abstract>(Impl(...))` in a `_initialize<Feature>()` function; blocs are created in the router/page, not registered.
- **Bloc (new code):** `sealed class XEvent` / `sealed class XState` with `final class` subclasses in the bloc file (see `features/leaderboard/presentation/bloc/leaderboard_bloc.dart`). Do **not** add new freezed blocs.
- **Domain is pure:** no Flutter, Firebase or `get_it` imports in `domain/`.
- **Models:** `factory X.fromJson(Map<String, dynamic> json, {String? documentId})` + `Map<String, dynamic> toJson()`. Timestamps via `FirebaseDTConverter` (`core/firebase/dt_converter.dart`). Localized text as `LocalizedText` (`{en, ml}` map — added in CW-040).
- **Logging:** `AppLogger.instance` — no `print`.
- **Config:** feature flags and tunables live in Remote Config (`core/remote_config/`), env flags in `.env.dev/.env.prod` (`MonetizationConfig.fromEnv()`).
- **Dates:** existing games use UTC date ids (`DateHelper.todayUtcDateId`). Crossword uses **IST** date ids (DEC-001).

## Firebase

- Project `wordschool-dev`. Dev data = named database **`development`**; prod = **`(default)`** (see DEC-002 in `TASKS.md`).
- **Content is admin-only.** Apps never write content collections. Admin panel → admin callables (`assertAdmin`, `parseDatabaseId`, `writeAuditLog`) → Firestore.
- **Scores are server-side.** XP, streaks, leaderboards, results come from functions (`submitCrossword`), never from the client.
- **Rules are operation-scoped:** each client update rule lists exactly which keys may change (`affectedKeys().hasOnly([...])`). Follow the pattern in `firestore.rules`; add new matches **above** the catch-all deny.
- **Cost habits:** one-time `get()` instead of listeners for lists; paginate (20); batch progress saves (pause / leave / 30 s, never per keystroke); read summary docs (`top50`) instead of collections; turn off indexing on big fields with `fieldOverrides`.
- Full schema: `docs/firebase/FIREBASE_DESIGN.md`. If you change the schema, update that doc in the same PR.

## Cloud Functions (`functions/`)

- TypeScript, Node 20, `firebase-functions` v2 (`onCall`, `onSchedule`, `onDocument*`), Admin SDK.
- Style: ESLint google config — **double quotes, 2-space indent, max line 100**.
- Admin callables: first line `const adminUid = assertAdmin(request);`, then `const databaseId = parseDatabaseId(data.databaseId); const db = dbForDatabaseId(databaseId);`, end with `writeAuditLog(...)`. Throw `HttpsError` with clear messages.
- Pure logic (validators, scoring) lives in its own file with a `*.test.ts` next to it (Jest, `ts-jest`).
- Export every function from `src/index.ts`. New crossword code goes in `src/crossword/`.
- Region: `asia-south1` for new crossword functions (`setGlobalOptions` or per-function `region`).

## Tests

- Flutter: `test/` mirrors `lib/` (`test/features/<feature>/domain/utils/..._test.dart`). Pure logic first: grid engine, scoring, validators, model `fromJson`.
- Functions: Jest unit tests for every validator and scoring rule; rules tests on the emulator for every new collection.
- Bug fix = a failing test first.

## Working on tasks

1. Find the task in `TASKS.md`; set its board status to `doing`.
2. Branch `feat/CW-0XX-short-name` from `development`.
3. Use the matching skill (below). Keep the change to the task's scope.
4. Tick the card's "Done when" boxes; run analyze/tests; set status `review`.
5. Commit messages: `CW-0XX: what changed` (imperative). One task per PR into `development`.
6. Note notable changes in `daily update/YYYY-MM-DD.md`.

## Skills (`.claude/skills/`)

| Skill | Use it to |
| --- | --- |
| `task-workflow` | Pick the next task, update status, close out a task |
| `flutter-feature` | Scaffold a feature or a slice (entity → model → data source → repo → use case → bloc → page) and wire DI/routes |
| `cloud-function` | Scaffold an admin callable, player callable, scheduled job or trigger, with tests |
| `firestore-collection` | Add a collection end-to-end: constants, model, rules + rules test, indexes, design doc |
| `crossword-content` | Draft PSC questions and crossword puzzles as JSON and validate grids |

## Design

- Player app: dark Wordle palette (`lib/config/themes/colors.dart`) — tiles `tileCorrect #538D4E`, `tilePresent #B59F3B`, background `#121213`. Tokens in `design/tokens/`.
- Screen specs: `design/screens/psc-crossword.md`. Match spacing and states there; touch targets ≥ 44 px; works at 360 px width.

## Don'ts

- Don't write to content collections from the app, or compute XP/score on the client for storage.
- Don't add listeners (`snapshots()`) for lists, or save on every keystroke.
- Don't hard-delete content — set `status: archived`.
- Don't commit `.env*` (except `.env.example`), service accounts or API keys.
- Don't change existing Wordle/Story Mode schemas or rules unless the task says so.
- Don't add packages without noting why in the PR; prefer what is already in `pubspec.yaml`.
