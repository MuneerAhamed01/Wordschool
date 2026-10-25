/// Admin panel paths. Pages navigate with these instead of importing another
/// module's page, so admin modules stay independent.
abstract final class AdminRoutes {
  static const login = '/login';
  static const home = '/';
  static const categories = '/categories';
  static const questions = '/questions';
  static const puzzles = '/puzzles';
  static const schedule = '/schedule';
  static const reports = '/reports';
  static const bulkUpload = '/bulk-upload';

  static String puzzlesOf({String? categoryId}) =>
      categoryId == null ? puzzles : '$puzzles?category=$categoryId';

  static String newPuzzle(String? categoryId) =>
      categoryId == null ? '$puzzles/new' : '$puzzles/new?category=$categoryId';

  /// The builder pre-filled from the category's checked questions (CW-038).
  /// [difficulty] is a wire value (`easy`, `medium`, `hard`).
  static String autoPuzzle(
    String categoryId, {
    int? size,
    int? words,
    String? difficulty,
  }) =>
      Uri(path: '$puzzles/new', queryParameters: {
        'category': categoryId,
        'auto': '1',
        if (size != null) 'size': '$size',
        if (words != null) 'words': '$words',
        if (difficulty != null) 'difficulty': difficulty,
      }).toString();

  static String questionsOf({String? subject}) =>
      subject == null ? questions : '$questions?subject=$subject';

  static String editPuzzle(String puzzleId) => '$puzzles/$puzzleId/edit';

  static String puzzleDetail(String puzzleId) => '$puzzles/$puzzleId';
}
