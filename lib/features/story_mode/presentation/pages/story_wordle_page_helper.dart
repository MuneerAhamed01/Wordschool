part of 'story_wordle_page.dart';

mixin StoryWordlePageHelper on State<StoryWordlePage> {
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
    if (latestWord == null) {
      return;
    }

    final lastGuess = latestWord.word.trim().toUpperCase();
    final target = answer.trim().toUpperCase();

    context.read<StoryClueBloc>().add(SubmitGuess(latestWord.word));

    if (lastGuess == target) {
      context.read<StoryClueBloc>().add(const CompleteClue(solved: true));
      return;
    }

    final completedCount = context.read<WordCubit>().state
        .where(
          (word) =>
              word.isCompleted && word.letters.length == GameConstants.maxLetters,
        )
        .length;
    if (completedCount >= GameConstants.maxWords) {
      context.read<StoryClueBloc>().add(const CompleteClue(solved: false));
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
}
