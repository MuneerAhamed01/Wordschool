import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/utils/valid_words.dart';
import 'package:wordshool/features/game/presentation/utils/constants.dart';
import 'package:wordshool/features/game/presentation/utils/letter.dart';
import 'package:wordshool/features/game/presentation/utils/word.dart';
import 'package:wordshool/core/enums/word_tile_type.dart';

class WordCubit extends Cubit<List<Word>> {
  WordCubit({required ValidWords validWords})
      : _validWords = validWords,
        super([]);

  final ValidWords _validWords;

  void addLetter(Letter letter) {
    // Find the current active word (first non-completed word)
    final activeWordIndex = state.indexWhere((word) => !word.isCompleted);

    // If no active word exists and we haven't reached max words, create a new word
    if (activeWordIndex == -1) {
      if (state.length < GameConstants.maxWords) {
        final newWord = Word(letters: [letter]);
        emit([...state, newWord]);
      }
      return;
    }

    final activeWord = state[activeWordIndex];

    // Check if the current word has space for more letters
    if (activeWord.letters.length < GameConstants.maxLetters) {
      final updatedLetters = [...activeWord.letters, letter];
      final updatedWord = activeWord.copyWith(letters: updatedLetters);

      // Update the state with the modified word
      final updatedState = List<Word>.from(state);
      updatedState[activeWordIndex] = updatedWord;
      emit(updatedState);
    }
  }

  void removeLastLetter() {
    if (state.isEmpty) return;

    // Find the first non-completed word, return if none found
    final nonCompletedWordIndex =
        state.indexWhere((element) => !element.isCompleted);
    if (nonCompletedWordIndex == -1) return;

    final nonCompletedWord = state[nonCompletedWordIndex];

    if (nonCompletedWord.letters.isEmpty) {
      emit(state.where((word) => word != nonCompletedWord).toList());
    } else {
      emit(state
          .map((word) => word == nonCompletedWord
              ? word.copyWith(
                  letters: word.letters.sublist(0, word.letters.length - 1))
              : word)
          .toList());
    }
  }

  void clearLetters() {
    emit([]);
  }

  void updateLetter(Letter letter) {
    // emit(state.map((element) => element == letter ? letter : element).toList());
  }

  // _completeWord removed; handled inside _checkAndUpdateTheWordStatus

  Future<bool> submitWordIfValid(String activatedWord) async {
    // Find the first non-completed word
    final activeWordIndex = state.indexWhere((word) => !word.isCompleted);

    if (activeWordIndex != -1) {
      final activeWord = state[activeWordIndex];

      // Only complete the word if it has exactly 5 letters
      if (activeWord.letters.length == GameConstants.maxLetters) {
        final word = activeWord.word;
        if (_validWords.checkIsValidWord(word)) {
          // Check and update the status of the word against today's word
          await _checkAndUpdateTheWordStatus(activatedWord);

          return true;
        } else {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _checkAndUpdateTheWordStatus(String word) async {
    final activeWordIndex = _findActiveWordIndex();
    if (activeWordIndex == -1) return;

    final activeWord = state[activeWordIndex];
    if (!_hasRequiredLetters(activeWord)) return;

    final targetChars = word.trim().toUpperCase().split('');
    final guessChars =
        activeWord.letters.map((l) => l.letter.toUpperCase()).toList();

    final types = _evaluateGuess(guessChars, targetChars);
    final updatedWord = _applyEvaluationToWord(activeWord, types);
    _emitUpdatedWordAt(activeWordIndex, updatedWord);
  }

  int _findActiveWordIndex() {
    return state.indexWhere((w) => !w.isCompleted);
  }

  bool _hasRequiredLetters(Word word) {
    return word.letters.length == GameConstants.maxLetters;
  }

  List<WordTileType> _evaluateGuess(
    List<String> guessChars,
    List<String> targetChars,
  ) {
    final int n = GameConstants.maxLetters;
    final List<WordTileType> types =
        List<WordTileType>.filled(n, WordTileType.error);

    final List<bool> targetTaken = List<bool>.filled(n, false);
    for (int i = 0; i < n; i++) {
      if (guessChars[i] == targetChars[i]) {
        types[i] = WordTileType.green;
        targetTaken[i] = true;
      }
    }

    final Map<String, int> remainingCounts = <String, int>{};
    for (int i = 0; i < n; i++) {
      if (!targetTaken[i]) {
        final ch = targetChars[i];
        remainingCounts[ch] = (remainingCounts[ch] ?? 0) + 1;
      }
    }

    for (int i = 0; i < n; i++) {
      if (types[i] == WordTileType.green) continue;
      final ch = guessChars[i];
      final available = remainingCounts[ch] ?? 0;
      if (available > 0) {
        types[i] = WordTileType.orange;
        remainingCounts[ch] = available - 1;
      } else {
        types[i] = WordTileType.none;
      }
    }

    return types;
  }

  Word _applyEvaluationToWord(Word activeWord, List<WordTileType> types) {
    final updatedLetters = List<Letter>.generate(
      GameConstants.maxLetters,
      (i) => activeWord.letters[i].copyWith(type: types[i]),
      growable: false,
    );
    return activeWord.copyWith(letters: updatedLetters, isCompleted: true);
  }

  void _emitUpdatedWordAt(int index, Word updatedWord) {
    final updatedState = List<Word>.from(state);
    updatedState[index] = updatedWord;
    emit(updatedState);
  }
}
