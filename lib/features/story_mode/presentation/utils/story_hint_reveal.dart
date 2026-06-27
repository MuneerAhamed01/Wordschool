import 'package:wordshool/features/game/presentation/utils/constants.dart';

/// Helpers for paid/extra hint letter reveals during story clues.
class StoryHintReveal {
  StoryHintReveal._();

  static int nextUnrevealedIndex(Set<int> revealed) {
    for (var index = 0; index < GameConstants.maxLetters; index++) {
      if (!revealed.contains(index)) {
        return index;
      }
    }
    return -1;
  }

  static String letterAt(String answer, int index) {
    final letters = answer.trim().toUpperCase().split('');
    if (index < 0 || index >= letters.length) {
      return '';
    }
    return letters[index];
  }

  static String revealLabel(String answer, int index) {
    final letter = letterAt(answer, index);
    if (letter.isEmpty) {
      return 'All letters revealed';
    }
    return 'Letter ${index + 1} is $letter';
  }
}
