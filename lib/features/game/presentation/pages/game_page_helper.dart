part of 'game_page.dart';

mixin GamePageHelper on State<GamePage> {
  int _lastCompletedWordsCount = 0;
  bool _hasNavigated = false;

  Future<void> onSubmitWord(BuildContext context) async {
    final activeWord = context.read<GameBloc>().state.whenOrNull(
        loaded: (word, userGameState, userSpecificGameData) => word);

    if (activeWord == null) return;

    final isValid =
        await context.read<WordCubit>().submitWordIfValid(activeWord);

    if (!isValid) {
      // Shake the tiles of the current word
      _shakeCurrentWord();

      CustomSnackBar.show(
        // ignore: use_build_context_synchronously
        context,
        message: 'Not a valid word',
        type: SnackBarType.error,
      );
    } else {
      if (!context.mounted) return;

      context
          .read<GameBloc>()
          .add(GameEvent.addGuessedWord(_getLatestWord(context)?.word ?? ''));
    }
  }

  void _shakeCurrentWord() {
    final state = context.read<WordCubit>().state;
    final activeWordIndex = state.indexWhere((word) => !word.isCompleted);

    if (activeWordIndex != -1) {
      // Shake all tiles of the current word (5 tiles per word)
      for (int i = 0; i < 5; i++) {
        final tileIndex = activeWordIndex * 5 + i;
        (this as _GamePageState)._shakeFunctions[tileIndex]?.call();
      }
    }
  }

  /// Returns the latest (most recent) non-completed or completed word from the WordCubit state based on a condition.
  /// If [completed] is true, returns the latest completed word with 5 letters.
  /// Otherwise, returns the latest non-completed word.
  Word? _getLatestWord(BuildContext context) {
    final words = context.read<WordCubit>().state;
    return words.lastWhere(
        (w) => w.isCompleted && w.letters.length == GameConstants.maxLetters);
  }

  Future<void> listenToWord(BuildContext context, List<Word> words) async {
    if (_hasNavigated) return;

    final todayWord = context.read<GameBloc>().state.todayWord;

    final completedWords = words
        .where((w) =>
            w.isCompleted && w.letters.length == GameConstants.maxLetters)
        .toList();

    final currentCompletedCount = completedWords.length;
    if (currentCompletedCount == 0 ||
        currentCompletedCount == _lastCompletedWordsCount) {
      return;
    }

    _lastCompletedWordsCount = currentCompletedCount;

    final lastCompleted = completedWords.last;
    final lastGuess = lastCompleted.word.trim().toUpperCase();
    final target = todayWord.trim().toUpperCase();

    if (lastGuess == target) {
      await Future.delayed(const Duration(milliseconds: 800));
      _hasNavigated = true;
      if (context.mounted) {
        _onMarkGameCompleted(context, true);
        context.push(
          WinningPage.routeName,
          extra: WinningPageParam(word: todayWord, isLost: false),
        );
      }

      return;
    }

    if (currentCompletedCount >= GameConstants.maxWords) {
      await Future.delayed(const Duration(milliseconds: 800));
      _hasNavigated = true;
      if (context.mounted) {
        _onMarkGameCompleted(context, false);
        context.push(
          WinningPage.routeName,
          extra: WinningPageParam(word: todayWord, isLost: true),
        );
      }
    }
  }

  void _onMarkGameCompleted(BuildContext context, bool isCorrect) {
    context.read<GameBloc>().add(GameEvent.markGameCompleted(isCorrect));
  }
}
