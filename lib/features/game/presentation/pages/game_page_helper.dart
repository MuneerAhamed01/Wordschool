part of 'game_page.dart';

mixin GamePageHelper on State<GamePage> {
  void onSubmitWord(BuildContext context) {
    final isValid = context.read<WordCubit>().submitWordIfValid();

    if (!isValid) {
      // Shake the tiles of the current word
      _shakeCurrentWord();

      CustomSnackBar.show(
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
}
