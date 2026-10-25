import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/puzzle_service.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/reveals_service.dart';
import 'package:wordshool/features/crossword/puzzle/domain/entities/session.dart';
import 'package:wordshool/features/crossword/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/changes_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/progress_repository.dart';

class PuzzleRepositoryImpl implements PuzzleRepository {
  PuzzleRepositoryImpl({
    required PuzzleDataSource source,
    required RevealsDataSource reveals,
    required CrosswordProgressRepository progress,
    required CrosswordChangesRepository changes,
  })  : _source = source,
        _reveals = reveals,
        _progress = progress,
        _changes = changes;

  final PuzzleDataSource _source;
  final RevealsDataSource _reveals;
  final CrosswordProgressRepository _progress;
  final CrosswordChangesRepository _changes;

  @override
  Future<DataState<PuzzleSessionEntity>> loadPuzzle(String puzzleId) async {
    final puzzle = _source.getPuzzle(puzzleId);
    final progress = _progress.getProgress(puzzleId);
    final reveals = _reveals.getReveals(puzzleId);

    final puzzleResult = await puzzle;
    if (puzzleResult is DataError) return DataError(error: puzzleResult.error);
    final progressResult = await progress;
    if (progressResult is DataError) {
      return DataError(error: progressResult.error);
    }
    final revealed = (await reveals).data;
    return DataSuccess(
      data: PuzzleSessionEntity(
        puzzle: puzzleResult.data!,
        progress: progressResult.data,
        revealedCells: revealed?.cells ?? const [],
        revealedWordIds: revealed?.wordIds ?? const [],
      ),
    );
  }

  @override
  Future<DataState<void>> saveProgress({
    required CrosswordProgressEntity progress,
    required bool create,
    required List<int> revealedCells,
    required List<String> revealedWordIds,
  }) async {
    await _reveals.saveReveals(progress.puzzleId,
        cells: revealedCells, wordIds: revealedWordIds);
    return _progress.saveProgress(progress, create: create);
  }

  @override
  Future<DataState<CrosswordSubmitOutcome>> submit({
    required CrosswordProgressEntity progress,
    required List<String> revealedWordIds,
  }) async {
    final result = await _source.submit(
        progress: progress, revealedWordIds: revealedWordIds);
    if (result is DataError) return DataError(error: result.error);
    final outcome = result.data!;
    await _reveals.clearReveals(progress.puzzleId);
    _progress.markCompleted(_completed(progress, outcome.result));
    if (!outcome.alreadySubmitted) {
      _changes.notify(CrosswordChange.puzzleSubmitted);
    }
    return DataSuccess(data: outcome);
  }

  CrosswordProgressEntity _completed(
    CrosswordProgressEntity progress,
    CrosswordResultEntity result,
  ) =>
      CrosswordProgressEntity(
        puzzleId: progress.puzzleId,
        status: CrosswordProgressStatus.completed,
        letters: progress.letters,
        elapsedSec: progress.elapsedSec,
        hintsUsed: progress.hintsUsed,
        checksUsed: progress.checksUsed,
        result: result,
      );
}
