/// Player app paths. Pages navigate with these instead of importing another
/// module's page, so features and modules stay independent.
abstract final class AppRoutes {
  static const auth = '/auth';
  static const game = '/game';

  // Shell tabs.
  static const home = '/home';
  static const revise = '/revise';
  static const ranks = '/ranks';
  static const profile = '/profile';

  // Crossword, full screen over the bottom bar.
  static const category = '/crossword/category/:id';
  static const puzzle = '/crossword/puzzle/:id';
  static const result = '/crossword/puzzle/:id/result';

  static String categoryOf(String categoryId) =>
      '/crossword/category/$categoryId';

  static String puzzleOf(String puzzleId) => '/crossword/puzzle/$puzzleId';

  static String resultOf(String puzzleId) =>
      '/crossword/puzzle/$puzzleId/result';
}
