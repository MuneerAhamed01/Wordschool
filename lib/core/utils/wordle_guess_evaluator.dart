import 'package:wordshool/core/enums/word_tile_type.dart';
import 'package:wordshool/features/game/presentation/utils/constants.dart';

/// Shared Wordle guess evaluation for emoji grids and tile states.
class WordleGuessEvaluator {
  WordleGuessEvaluator._();

  static const greenEmoji = '🟩';
  static const yellowEmoji = '🟨';
  static const grayEmoji = '⬛';

  static List<WordTileType> evaluate(String guess, String answer) {
    final n = GameConstants.maxLetters;
    final guessChars = guess.trim().toUpperCase().split('');
    final targetChars = answer.trim().toUpperCase().split('');
    final types = List<WordTileType>.filled(n, WordTileType.error);
    final targetTaken = List<bool>.filled(n, false);

    for (var i = 0; i < n; i++) {
      if (guessChars[i] == targetChars[i]) {
        types[i] = WordTileType.green;
        targetTaken[i] = true;
      }
    }

    final remainingCounts = <String, int>{};
    for (var i = 0; i < n; i++) {
      if (!targetTaken[i]) {
        final ch = targetChars[i];
        remainingCounts[ch] = (remainingCounts[ch] ?? 0) + 1;
      }
    }

    for (var i = 0; i < n; i++) {
      if (types[i] == WordTileType.green) continue;
      final ch = guessChars[i];
      final available = remainingCounts[ch] ?? 0;
      if (available > 0) {
        types[i] = WordTileType.orange;
        remainingCounts[ch] = available - 1;
      }
    }

    return types;
  }

  static String guessToEmojiRow(String guess, String answer) {
    return evaluate(guess, answer).map(_tileTypeToEmoji).join();
  }

  static String _tileTypeToEmoji(WordTileType type) {
    return switch (type) {
      WordTileType.green => greenEmoji,
      WordTileType.orange => yellowEmoji,
      WordTileType.none || WordTileType.error => grayEmoji,
    };
  }
}
