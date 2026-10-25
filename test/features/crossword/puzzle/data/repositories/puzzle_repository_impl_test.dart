import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/puzzle_service.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/reveals_service.dart';
import 'package:wordshool/features/crossword/puzzle/data/repositories/puzzle_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/data/data_source/progress_service.dart';
import 'package:wordshool/features/crossword/shared/data/models/progress.dart';
import 'package:wordshool/features/crossword/shared/data/models/puzzle.dart';
import 'package:wordshool/features/crossword/shared/data/models/result.dart';
import 'package:wordshool/features/crossword/shared/data/repositories/changes_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/data/repositories/progress_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

import '../../../crossword_fixtures.dart';

class _Source implements PuzzleDataSource {
  bool alreadySubmitted = false;

  @override
  Future<DataState<CrosswordPuzzleModel>> getPuzzle(String puzzleId) async =>
      DataSuccess(data: examplePuzzle());

  @override
  Future<DataState<CrosswordSubmitOutcomeModel>> submit({
    required CrosswordProgressEntity progress,
    required List<String> revealedWordIds,
  }) async =>
      DataSuccess(
          data: CrosswordSubmitOutcomeModel.fromJson({
        ...fixture('submit_response'),
        'alreadySubmitted': alreadySubmitted,
      }));
}

class _Progress implements ProgressDataSource {
  final saved = <bool>[];

  @override
  Future<DataState<CrosswordProgressModel?>> getProgress(String id) async =>
      DataSuccess(data: null);

  @override
  Future<DataState<List<CrosswordProgressModel>>> getProgressFor(
          List<String> ids) async =>
      DataSuccess(data: const []);

  @override
  Future<DataState<int>> countCompleted(String categoryId) async =>
      DataSuccess(data: 0);

  @override
  Future<DataState<void>> saveProgress(CrosswordProgressEntity progress,
      {required bool create}) async {
    saved.add(create);
    return DataSuccess(data: null);
  }
}

class _Reveals implements RevealsDataSource {
  final store = <String, ({List<int> cells, List<String> wordIds})>{};

  @override
  Future<DataState<void>> clearReveals(String puzzleId) async {
    store.remove(puzzleId);
    return DataSuccess(data: null);
  }

  @override
  Future<DataState<({List<int> cells, List<String> wordIds})>> getReveals(
          String puzzleId) async =>
      DataSuccess(
          data: store[puzzleId] ?? (cells: <int>[], wordIds: <String>[]));

  @override
  Future<DataState<void>> saveReveals(String puzzleId,
      {required List<int> cells, required List<String> wordIds}) async {
    store[puzzleId] = (cells: cells, wordIds: wordIds);
    return DataSuccess(data: null);
  }
}

void main() {
  late _Source source;
  late _Progress progressSource;
  late _Reveals reveals;
  late CrosswordProgressRepositoryImpl progress;
  late CrosswordChangesRepositoryImpl changes;
  late PuzzleRepositoryImpl repo;

  final p = CrosswordProgressEntity(
      puzzleId: 'kerala-history-0012', letters: exampleLetters['inProgress']!);

  setUp(() {
    source = _Source();
    progressSource = _Progress();
    reveals = _Reveals();
    progress = CrosswordProgressRepositoryImpl(source: progressSource);
    changes = CrosswordChangesRepositoryImpl();
    repo = PuzzleRepositoryImpl(
        source: source, reveals: reveals, progress: progress, changes: changes);
  });

  test('reveals round-trip through the device store', () async {
    await repo.saveProgress(
        progress: p,
        create: true,
        revealedCells: [26],
        revealedWordIds: ['3D']);
    expect(progressSource.saved, [true]);
    final session = (await repo.loadPuzzle('kerala-history-0012')).data!;
    expect(session.revealedCells, [26]);
    expect(session.revealedWordIds, ['3D']);
    expect(session.progress, p);
  });

  test('submit clears reveals, caches the result and signals once', () async {
    reveals.store[p.puzzleId] = (cells: [26], wordIds: ['3D']);
    final signal =
        expectLater(changes.changes, emits(CrosswordChange.puzzleSubmitted));
    final outcome =
        (await repo.submit(progress: p, revealedWordIds: ['3D'])).data!;
    expect(outcome.xp, 1285);
    expect(reveals.store, isEmpty);
    final cached = (await progress.getProgress(p.puzzleId)).data!;
    expect(cached.isCompleted, isTrue);
    expect(cached.result!.score, 71);
    await signal;
  });

  test('a repeat submit returns the stored result without a signal', () async {
    source.alreadySubmitted = true;
    var signalled = false;
    final sub = changes.changes.listen((_) => signalled = true);
    await repo.submit(progress: p, revealedWordIds: const []);
    await Future<void>.delayed(Duration.zero);
    expect(signalled, isFalse);
    await sub.cancel();
  });
}
