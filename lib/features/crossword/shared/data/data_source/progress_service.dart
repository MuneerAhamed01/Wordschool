import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/shared/data/models/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

/// `users/{uid}/crosswordProgress`.
abstract class ProgressDataSource {
  /// Null data when the player hasn't started [puzzleId].
  Future<DataState<CrosswordProgressModel?>> getProgress(String puzzleId);

  /// At most [maxIdsPerQuery] ids (one `in` query).
  Future<DataState<List<CrosswordProgressModel>>> getProgressFor(
      List<String> puzzleIds);

  Future<DataState<int>> countCompleted(String categoryId);

  /// Only the fields the rules allow; server timestamps.
  Future<DataState<void>> saveProgress(
    CrosswordProgressEntity progress, {
    required bool create,
  });

  /// Firestore's limit for `in` filters.
  static const maxIdsPerQuery = 30;
}
