import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

class SaveCrosswordProgressParam {
  const SaveCrosswordProgressParam({
    required this.progress,
    required this.create,
    this.revealedCells = const [],
    this.revealedWordIds = const [],
  });

  final CrosswordProgressEntity progress;

  /// True on the first save of a puzzle (no progress doc yet).
  final bool create;
  final List<int> revealedCells;
  final List<String> revealedWordIds;
}
