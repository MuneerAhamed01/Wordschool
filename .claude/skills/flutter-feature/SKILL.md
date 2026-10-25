---
name: flutter-feature
description: Scaffold a Flutter feature or slice in the Kerala PSC app's clean architecture (entity, model, data source, repository, use case, sealed-class bloc, page, model test) and wire it into get_it and go_router. Use when adding a new feature folder, a new entity, a new Firestore-backed screen, or a new use case in lib/features.
---

# Flutter feature generator

Generates code that matches the existing `auth` / `game` features' layering (plus sealed-class blocs, DEC-005), so new code reads like the old code.

## When to use

- A task card asks for entities, models, data sources, repositories, use cases, blocs or pages (e.g. CW-040 – CW-054).
- You are adding a screen backed by a Firestore document or query.

## Before you write anything — reuse

The crossword feature (M3) is the reference implementation; its file map is `docs/plans/M3-player-app.md`. Copy from it:

| Need | Copy / use |
| --- | --- |
| Where a file goes | `lib/features/<feature>/<module>/[<sub_module>/]{data,domain,presentation}`; used by 2+ modules → `<feature>/shared/`; by 2+ features → `lib/shared` / `lib/core` (CLAUDE.md "Code structure rules") |
| Data-source method | `guardData('Source.method', () async {...})` from `lib/core/resorces/data_guard.dart` — e.g. `crossword/category/data/data_source/remote/category_service.dart` |
| Reading JSON | `lib/core/utils/json_read.dart` (`asInt`, `asString`, `asStringList`, `asMap`, `asMapList`, `asDate`), Firestore timestamps `FirebaseDTConverter.tryParse` |
| Paged list | `Paged<T>` (`lib/shared/domains/entities/paged.dart`); cursor = last item, with the doc id as tiebreaker when the order field can repeat (`crossword/revise/data/data_source/remote/revise_service.dart`) |
| State two modules need | A shared repository (`crossword/shared/domain/repositories/progress_repository.dart`) or the change signal (`changes_repository.dart` + `CrosswordChange`) — never import the other module |
| Navigating to another module | `AppRoutes` / `AdminRoutes` in `lib/core/routes/` — never import another module's page |
| Sealed bloc | `crossword/revise/presentation/bloc/revise_bloc.dart` (small) or `crossword/puzzle/presentation/bloc/puzzle_bloc.dart` (timer, save queue) |
| Loading / empty / error UI | `SkeletonBox`, `StateMessage` / `StateMessage.error`, `showAppSheet` |
| Module DI | `crossword/<module>/di.dart` → `initCrossword<Module>(GetIt)`, called from `crossword/di.dart` |
| Bloc + widget tests | `test/features/crossword/crossword_fakes.dart` (one fake implementing every module repository + real use cases), screens at 360 px in `test/features/crossword/screens_test.dart` |
| Run checks | `scripts/check.sh test/features/<feature>` (analyze + `scripts/check_structure.py` + tests) |

The scaffold script below is fine for flat entities; for nested fields (lists of maps, `LocalizedText`) writing by hand from the crossword files is faster.

## Step 1 — Generate the slice

Run from the repo root. It never overwrites files (use `--force` only on purpose).

```bash
python3 .claude/skills/flutter-feature/scripts/scaffold_feature.py \
  --feature crossword --module notes \
  --entity note \
  --collection notes \
  --fields "id:String,questionId:String,text:String,createdAt:DateTime?" \
  --usecase load_note \
  --bloc notes \
  --page notes
```

| Flag | Meaning |
| --- | --- |
| `--feature` | Folder under `lib/features/` (snake_case) |
| `--module` | Module folder inside the feature (`lib/features/<feature>/<module>/`); names come from it, so no feature prefix |
| `--entity` | Entity file/class name (snake_case → `CrosswordPuzzleEntity`, `CrosswordPuzzleModel`) |
| `--fields` | `name:Type`, `?` = nullable. Types: `String int double bool DateTime List<T> Map<K,V>` or any class (gets a TODO) |
| `--source` | Data source name → `<source>_service.dart`, `<Source>DataSource(Impl)` |
| `--collection` | Constant on `FirebaseCollections` |
| `--usecase` | Use case name (default `load_<entity>`) |
| `--method` | Repository method (default `get<Entity>`) |
| `--bloc`, `--page` | Optional presentation layer |
| `--dry-run` | Show what would be created |

Field names must match `docs/firebase/FIREBASE_DESIGN.md` exactly.

## Step 2 — Finish what the script can't know

1. **Paste the printed snippets.** The DI snippet goes into the module's `di.dart` (`init<Feature><Module>(GetIt getIt)`, called from the feature's `di.dart`; a one-module feature uses `_initialize<Feature>()` in `lib/di.dart`). The route path goes into `lib/core/routes/app_routes.dart` and the route into `app_router.dart`. The collection constant goes into `lib/core/firebase/collections.dart`.
2. **Shared files that already existed** (repository, data source, repo impl) — the script lists them. Add the new method to the interface, the impl and the repository by hand, using the generated method body as the pattern.
3. **Fill the TODOs**: custom field parsing (e.g. `LocalizedText.fromJson`, list of nested models), field assertions in the model test, the page body from `design/screens/*.md`.
4. Run `fvm dart format lib test`, then `fvm flutter analyze && fvm flutter test`.

## Patterns the script doesn't generate

**Paged list query** (rules require the `status` filter):

```dart
Future<DataState<List<CrosswordPuzzleModel>>> getPuzzles({
  required String categoryId,
  DocumentSnapshot? startAfter,
  int limit = 20,
}) async {
  try {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirebaseCollections.crosswordPuzzles)
        .where('categoryId', isEqualTo: categoryId)
        .where('status', isEqualTo: 'published')
        .orderBy('number', descending: true)
        .limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    final snap = await query.get();
    return DataSuccess(
      data: snap.docs
          .map((d) => CrosswordPuzzleModel.fromJson(d.data(), documentId: d.id))
          .toList(),
    );
  } catch (error, stackTrace) {
    log('CrosswordContentDataSource.getPuzzles failed', error: error, stackTrace: stackTrace);
    return DataError(error: AppError(error: error, code: '500'));
  }
}
```

**Callable function** (inject `FirebaseFunctions`, region `asia-south1`):

```dart
final callable = _functions.httpsCallable('submitCrossword');
final result = await callable.call<Map<String, dynamic>>({
  'puzzleId': puzzleId,
  'letters': letters,
  'elapsedSec': elapsedSec,
});
return DataSuccess(data: CrosswordResultModel.fromJson(
  Map<String, dynamic>.from(result.data as Map),
));
```

`FirebaseFunctions.instanceFor(region: 'asia-south1')` and `FirebaseFirestore` are registered once in `di.dart` → `_initializeFirebase()`; take them with `getIt<FirebaseFunctions>()`.

**Player-owned write** (only fields the rules allow; server timestamp):

```dart
await _firestore
    .collection(FirebaseCollections.users).doc(uid)
    .collection(FirebaseCollections.crosswordProgress).doc(puzzleId)
    .update({
  'letters': letters,
  'elapsedSec': elapsedSec,
  'hintsUsed': hintsUsed.toJson(),
  'checksUsed': checksUsed,
  'updatedAt': FieldValue.serverTimestamp(),
});
```

## Checklist before you finish

- [ ] `domain/` has no Flutter/Firebase/get_it imports
- [ ] Every data source method goes through `guardData` (catches, logs, `DataError` with a player message)
- [ ] Queries carry the filters the rules check
- [ ] New use cases registered in DI; blocs created in router/page
- [ ] Model test passes with a real-shaped JSON fixture
- [ ] Files in the right module; nothing imports another module (only its own, `<feature>/shared/`, `lib/{core,config,shared}`)
- [ ] No file over 700 lines; widget-returning functions are `build` / `_build…`; one job per function
- [ ] File names don't repeat the feature or folder (`models/puzzle.dart`, not `models/crossword_puzzle_model.dart`)
- [ ] `scripts/check.sh` passes; screens tested at 360 px
