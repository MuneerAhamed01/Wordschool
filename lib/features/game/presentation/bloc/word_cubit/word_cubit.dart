import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/utils/valid_words.dart';
import 'package:wordshool/features/game/presentation/utils/constants.dart';
import 'package:wordshool/features/game/presentation/utils/letter.dart';
import 'package:wordshool/features/game/presentation/utils/word.dart';

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

  void _completeWord(Word word) {
    emit(state
        .map((element) =>
            element == word ? word.copyWith(isCompleted: true) : element)
        .toList());
  }

  bool submitWordIfValid() {
    // Find the first non-completed word
    final activeWordIndex = state.indexWhere((word) => !word.isCompleted);

    if (activeWordIndex != -1) {
      final activeWord = state[activeWordIndex];

      // Only complete the word if it has exactly 5 letters
      if (activeWord.letters.length == GameConstants.maxLetters) {
        final word = activeWord.word;
        if (_validWords.checkIsValidWord(word)) {
          _completeWord(activeWord);
          return true;
        } else {
          return false;
        }
      }
    }
    return true;
  }
}
