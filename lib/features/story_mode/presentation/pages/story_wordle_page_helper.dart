part of 'story_wordle_page.dart';

mixin StoryWordlePageHelper on State<StoryWordlePage> {
  int _lastCompletedWordsCount = 0;

  Future<void> onSubmitWord(BuildContext context) async {
    final clueState = context.read<StoryClueBloc>().state;
    final isFinished = clueState.maybeWhen(
      ready: (_, __, ___, ____, _____, isCompleted) => isCompleted,
      orElse: () => true,
    );
    if (isFinished) {
      return;
    }

    final answer = clueState.maybeWhen(
      ready: (_, __, answer, ___, ____, _____) => answer,
      orElse: () => '',
    );
    if (answer.isEmpty) {
      return;
    }

    final isValid =
        await context.read<WordCubit>().submitWordIfValid(answer);

    if (!isValid) {
      _shakeCurrentWord();
      if (!context.mounted) {
        return;
      }

      CustomSnackBar.show(
        context,
        message: 'Not a valid word',
        type: SnackBarType.error,
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    final latestWord = _getLatestWord(context);
    if (latestWord != null) {
      context.read<StoryClueBloc>().add(SubmitGuess(latestWord.word));
    }
  }

  void _shakeCurrentWord() {
    final state = context.read<WordCubit>().state;
    final activeWordIndex = state.indexWhere((word) => !word.isCompleted);

    if (activeWordIndex != -1) {
      for (int tileIndex = activeWordIndex * GameConstants.maxLetters;
          tileIndex < activeWordIndex * GameConstants.maxLetters +
              GameConstants.maxLetters;
          tileIndex++) {
        (this as _StoryWordlePageState)._shakeFunctions[tileIndex]?.call();
      }
    }
  }

  Word? _getLatestWord(BuildContext context) {
    final words = context.read<WordCubit>().state;
    final completed = words.where(
      (word) =>
          word.isCompleted && word.letters.length == GameConstants.maxLetters,
    );
    if (completed.isEmpty) {
      return null;
    }
    return completed.last;
  }

  Future<void> listenToWord(
    BuildContext context,
    List<Word> words, {
    required String answer,
  }) async {
    final pageState = this as _StoryWordlePageState;
    if (pageState._hasNavigated) {
      return;
    }

    final clueState = context.read<StoryClueBloc>().state;
    final isFinished = clueState.maybeWhen(
      ready: (_, __, ___, ____, _____, isCompleted) => isCompleted,
      orElse: () => true,
    );
    if (isFinished) {
      return;
    }

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
    final target = answer.trim().toUpperCase();

    if (lastGuess == target) {
      context.read<StoryClueBloc>().add(const CompleteClue(solved: true));
      return;
    }

    if (currentCompletedCount >= GameConstants.maxWords) {
      context.read<StoryClueBloc>().add(const CompleteClue(solved: false));
    }
  }
}
