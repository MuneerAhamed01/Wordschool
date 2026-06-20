part of 'game_page.dart';

mixin GamePageHelper on State<GamePage> {
  int _lastCompletedWordsCount = 0;
  bool _hasNavigated = false;

  Future<void> onSubmitWord(BuildContext context) async {
    final gameState = context.read<GameBloc>().state;
    if (gameState.isGameAlreadyCompleted) return;

    final activeWord = gameState.todayWord;
    if (activeWord.isEmpty) return;

    final isValid =
        await context.read<WordCubit>().submitWordIfValid(activeWord);

    if (!isValid) {
      _shakeCurrentWord();
      if (!context.mounted) return;

      CustomSnackBar.show(
        context,
        message: 'Not a valid word',
        type: SnackBarType.error,
      );
      return;
    }

    if (!context.mounted) return;

    context.read<GameBloc>().add(
          GameEvent.addGuessedWord(_getLatestWord(context)?.word ?? ''),
        );
  }

  void _shakeCurrentWord() {
    final state = context.read<WordCubit>().state;
    final activeWordIndex = state.indexWhere((word) => !word.isCompleted);

    if (activeWordIndex != -1) {
      for (int tileIndex = activeWordIndex * 5;
          tileIndex < activeWordIndex * 5 + 5;
          tileIndex++) {
        (this as _GamePageState)._shakeFunctions[tileIndex]?.call();
      }
    }
  }

  Word? _getLatestWord(BuildContext context) {
    final words = context.read<WordCubit>().state;
    return words.lastWhere(
      (word) =>
          word.isCompleted && word.letters.length == GameConstants.maxLetters,
    );
  }

  Future<void> listenToWord(BuildContext context, List<Word> words) async {
    if (_hasNavigated) return;

    final gameBlocState = context.read<GameBloc>().state;
    if (gameBlocState.isGameAlreadyCompleted) return;

    final todayWord = gameBlocState.todayWord;
    final completedWords = words
        .where(
          (word) =>
              word.isCompleted && word.letters.length == GameConstants.maxLetters,
        )
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
      await _navigateToWinning(context, isLost: false);
      return;
    }

    if (currentCompletedCount >= GameConstants.maxWords) {
      await _navigateToWinning(context, isLost: true);
    }
  }

  Future<void> _navigateToWinning(
    BuildContext context, {
    required bool isLost,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!context.mounted || _hasNavigated) return;

    _hasNavigated = true;
    final gameBlocState = context.read<GameBloc>().state;

    context.read<GameBloc>().add(GameEvent.markGameCompleted(!isLost));

    final attempts = context.read<WordCubit>().state
        .where((word) => word.isCompleted)
        .length;
    getIt<AnalyticsService>().logGameCompleted(
      gameMode: gameBlocState.gameMode.analyticsName,
      won: !isLost,
      attempts: attempts,
    );

    await Future.delayed(const Duration(milliseconds: 400));

    if (!context.mounted) return;

    final updatedState = context.read<GameBloc>().state;

    context.push(
      WinningPage.routeName,
      extra: WinningPageParam(
        word: gameBlocState.todayWord,
        isLost: isLost,
        isArchiveMode: gameBlocState.isArchiveMode,
        gameDateId: gameBlocState.gameDateId,
        updatedStreak: updatedState.userGameState?.streak,
      ),
    );
  }
}
