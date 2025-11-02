part of 'game_page.dart';

mixin GamePageHelper on State<GamePage> {
  int _lastCompletedWordsCount = 0;
  bool _hasNavigated = false;

  Future<void> onSubmitWord(BuildContext context) async {
    final activeWord =
        context.read<GameBloc>().state.whenOrNull(loaded: (word) => word);

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

  Future<void> listenToWord(BuildContext context, List<Word> words) async {
    if (_hasNavigated) return;

    final todayWord =
        context.read<GameBloc>().state.whenOrNull(loaded: (w) => w);
    if (todayWord == null) return;

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
      await Future.delayed(const Duration(seconds: 2));
      _hasNavigated = true;
      if (context.mounted) {
        context.push(
          WinningPage.routeName,
          extra: WinningPageParam(word: todayWord, isLost: false),
        );
      }
      return;
    }

    if (currentCompletedCount >= GameConstants.maxWords) {
      await Future.delayed(const Duration(seconds: 1));
      _hasNavigated = true;
      if (context.mounted) {
        context.push(
          WinningPage.routeName,
          extra: WinningPageParam(word: todayWord, isLost: true),
        );
      }
    }
  }
}
