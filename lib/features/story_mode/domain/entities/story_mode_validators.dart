import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_clue.dart';

class StoryModeValidators {
  StoryModeValidators._();

  static final _wordAnswerPattern = RegExp(r'^[A-Z]{5}$');

  static void validateCase(DetectiveCaseEntity caseEntity) {
    if (caseEntity.clues.length != 3) {
      throw ArgumentError(
        'Detective case must have exactly 3 clues, got ${caseEntity.clues.length}',
      );
    }

    for (var i = 0; i < caseEntity.clues.length; i++) {
      validateClue(caseEntity.clues[i], expectedIndex: i);
    }
  }

  static void validateClue(
    DetectiveClueEntity clue, {
    required int expectedIndex,
  }) {
    if (clue.index != expectedIndex) {
      throw ArgumentError(
        'Clue index must be $expectedIndex, got ${clue.index}',
      );
    }

    if (!_wordAnswerPattern.hasMatch(clue.answer)) {
      throw ArgumentError(
        'Clue answer must be 5 uppercase letters, got "${clue.answer}"',
      );
    }
  }
}
