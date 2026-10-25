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

  static String editPuzzle(String puzzleId) => '$puzzles/$puzzleId/edit';

  static String puzzleDetail(String puzzleId) => '$puzzles/$puzzleId';
}
