import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

/// The player's progress docs, read only as far as a screen needs them
/// (never the whole collection) and kept for the session.
abstract class CrosswordProgressRepository {
  /// Null data when the player hasn't started [puzzleId].
  Future<DataState<CrosswordProgressEntity?>> getProgress(String puzzleId);

  /// Progress for one page of a list, by puzzle id (missing = not started).
  Future<DataState<Map<String, CrosswordProgressEntity>>> getProgressFor(
      List<String> puzzleIds);

  /// Completed puzzles in [categoryId] (one count query, then cached).
  Future<DataState<int>> countCompleted(String categoryId);

  Future<DataState<void>> saveProgress(
    CrosswordProgressEntity progress, {
    required bool create,
  });

  /// After a first submit: keeps the completed doc and the category count
  /// up to date without a read.
  void markCompleted(CrosswordProgressEntity progress);
}
