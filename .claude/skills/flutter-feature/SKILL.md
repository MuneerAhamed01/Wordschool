---
name: flutter-feature
description: Scaffold a Flutter feature or slice in the Kerala PSC app's clean architecture (entity, model, data source, repository, use case, sealed-class bloc, page, model test) and wire it into get_it and go_router. Use when adding a new feature folder, a new entity, a new Firestore-backed screen, or a new use case in lib/features.
---

# Flutter feature generator

Generates code that matches the existing `auth` / `game` features' layering (plus sealed-class blocs, DEC-005), so new code reads like the old code.

## When to use

- A task card asks for entities, models, data sources, repositories, use cases, blocs or pages (e.g. CW-040 – CW-054).
- You are adding a screen backed by a Firestore document or query.

## Step 1 — Generate the slice

Run from the repo root. It never overwrites files (use `--force` only on purpose).

```bash
python3 .claude/skills/flutter-feature/scripts/scaffold_feature.py \
  --feature crossword \
  --entity crossword_puzzle \
  --source crossword_content \
  --collection crosswordPuzzles \
  --fields "id:String,categoryId:String,number:int,difficulty:String,rows:int,cols:int,layout:String,xpReward:int,publishedAt:DateTime?" \
  --usecase load_crossword_puzzle \
  --bloc crossword_puzzle \
  --page crossword_puzzle
```

| Flag | Meaning |
| --- | --- |
| `--feature` | Folder under `lib/features/` (snake_case) |
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

1. **Paste the printed snippets.** The DI snippet goes into `lib/di.dart` inside `_initialize<Feature>()` (create it, call it from `initializeDependency`). The route snippet goes into `lib/core/routes/app_router.dart`. The collection constant goes into `lib/core/firebase/collections.dart`.
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

Add `cloud_functions` to `pubspec.yaml` (not on psc-dev yet) and register `FirebaseFunctions.instanceFor(region: 'asia-south1')` once in DI.

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
- [ ] Every data source method catches, logs (`dart:developer` `log`) and returns `DataError(error: AppError(...))`
- [ ] Queries carry the filters the rules check
- [ ] New use cases registered in DI; blocs created in router/page
- [ ] Model test passes with a real-shaped JSON fixture
- [ ] Analyze + tests pass
