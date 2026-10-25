import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/shared/data/models/puzzle.dart';
import 'package:wordshool/features/crossword/shared/data/models/result.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

/// One published puzzle and the `submitCrossword` callable.
abstract class PuzzleDataSource {
  Future<DataState<CrosswordPuzzleModel>> getPuzzle(String puzzleId);

  Future<DataState<CrosswordSubmitOutcomeModel>> submit({
    required CrosswordProgressEntity progress,
    required List<String> revealedWordIds,
  });
}
