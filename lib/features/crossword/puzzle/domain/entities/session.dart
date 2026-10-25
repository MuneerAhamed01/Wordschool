import 'package:equatable/equatable.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';

/// What the puzzle screen needs to start or resume.
class PuzzleSessionEntity extends Equatable {
  const PuzzleSessionEntity({
    required this.puzzle,
    this.progress,
    this.revealedCells = const [],
    this.revealedWordIds = const [],
  });

  final CrosswordPuzzleEntity puzzle;

  /// Null on the first visit (no progress doc yet).
  final CrosswordProgressEntity? progress;

  /// Kept on the device: the rules don't allow them on the progress doc.
  final List<int> revealedCells;
  final List<String> revealedWordIds;

  @override
  List<Object?> get props => [puzzle, progress, revealedCells, revealedWordIds];
}
