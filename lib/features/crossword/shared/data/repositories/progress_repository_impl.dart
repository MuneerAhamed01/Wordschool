import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/shared/data/data_source/progress_service.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/progress_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/utils/puzzle_ids.dart';

class CrosswordProgressRepositoryImpl implements CrosswordProgressRepository {
  CrosswordProgressRepositoryImpl({required ProgressDataSource source})
      : _source = source;

  final ProgressDataSource _source;

  /// Progress seen this session by puzzle id; null = known not started.
  final _progress = <String, CrosswordProgressEntity?>{};
  final _completedByCategory = <String, int>{};

  @override
  Future<DataState<CrosswordProgressEntity?>> getProgress(
      String puzzleId) async {
    if (_progress.containsKey(puzzleId)) {
      return DataSuccess(data: _progress[puzzleId]);
    }
    final result = await _source.getProgress(puzzleId);
    if (result is DataError) return DataError(error: result.error);
    _progress[puzzleId] = result.data;
    return DataSuccess(data: result.data);
  }

  @override
  Future<DataState<Map<String, CrosswordProgressEntity>>> getProgressFor(
      List<String> puzzleIds) async {
    final unknown =
        puzzleIds.where((id) => !_progress.containsKey(id)).toList();
    for (final chunk in _chunks(unknown, ProgressDataSource.maxIdsPerQuery)) {
      final result = await _source.getProgressFor(chunk);
      if (result is DataError) return DataError(error: result.error);
      _remember(chunk, result.data ?? const []);
    }
    return DataSuccess(data: {
      for (final id in puzzleIds)
        if (_progress[id] != null) id: _progress[id]!,
    });
  }

  @override
  Future<DataState<int>> countCompleted(String categoryId) async {
    final cached = _completedByCategory[categoryId];
    if (cached != null) return DataSuccess(data: cached);
    final result = await _source.countCompleted(categoryId);
    if (result is DataError) return DataError(error: result.error);
    return DataSuccess(data: _completedByCategory[categoryId] = result.data!);
  }

  @override
  Future<DataState<void>> saveProgress(
    CrosswordProgressEntity progress, {
    required bool create,
  }) async {
    // Cached before the write lands (like Firestore's own local cache), so a
    // list opened right after leaving the puzzle already shows the mark.
    final before = _progress[progress.puzzleId];
    _progress[progress.puzzleId] = progress;
    final result = await _source.saveProgress(progress, create: create);
    if (result is DataError && before == null) {
      _progress.remove(progress.puzzleId);
    }
    return result;
  }

  @override
  void markCompleted(CrosswordProgressEntity progress) {
    final wasCompleted = _progress[progress.puzzleId]?.isCompleted ?? false;
    _progress[progress.puzzleId] = progress;
    final category = categoryOfPuzzle(progress.puzzleId);
    final count = _completedByCategory[category];
    if (!wasCompleted && count != null) {
      _completedByCategory[category] = count + 1;
    }
  }

  void _remember(List<String> asked, List<CrosswordProgressEntity> found) {
    for (final id in asked) {
      _progress[id] = null;
    }
    for (final p in found) {
      _progress[p.puzzleId] = p;
    }
  }

  static Iterable<List<String>> _chunks(List<String> ids, int size) sync* {
    for (var i = 0; i < ids.length; i += size) {
      yield ids.sublist(i, i + size > ids.length ? ids.length : i + size);
    }
  }
}
