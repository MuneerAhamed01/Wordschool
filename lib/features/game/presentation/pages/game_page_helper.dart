part of 'game_page.dart';

mixin GamePageHelper on State<GamePage> {
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

  void listenToWord(BuildContext context, List<Word> word) {}
}
