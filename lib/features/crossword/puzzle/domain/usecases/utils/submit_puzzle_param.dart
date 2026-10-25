import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

class SubmitCrosswordParam {
  const SubmitCrosswordParam({
    required this.progress,
    this.revealedWordIds = const [],
  });

  final CrosswordProgressEntity progress;
  final List<String> revealedWordIds;
}
