import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/puzzle/domain/entities/session.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';

/// The puzzle screen: open, autosave, submit.
abstract class PuzzleRepository {
  Future<DataState<PuzzleSessionEntity>> loadPuzzle(String puzzleId);

  /// Writes the progress doc ([create] on the first save) and keeps
  /// revealed squares on the device.
  Future<DataState<void>> saveProgress({
    required CrosswordProgressEntity progress,
    required bool create,
    required List<int> revealedCells,
    required List<String> revealedWordIds,
  });

  Future<DataState<CrosswordSubmitOutcome>> submit({
    required CrosswordProgressEntity progress,
    required List<String> revealedWordIds,
  });
}
