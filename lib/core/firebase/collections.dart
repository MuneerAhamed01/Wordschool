class FirebaseCollections {
  static const String games = 'games';
  static const String users = 'users';

  // Crossword content (written only by admin functions).
  static const String crosswordCategories = 'crosswordCategories';
  static const String crosswordPuzzles = 'crosswordPuzzles';
  static const String crosswordSolutions = 'crosswordSolutions';
  static const String crosswordDaily = 'crosswordDaily';
  static const String pscQuestions = 'pscQuestions';

  // Subcollections of users/{uid}.
  static const String crosswordProgress = 'crosswordProgress';
  static const String revisionItems = 'revisionItems';

  // leaderboards/{boardId}/entries/{uid}.
  static const String leaderboards = 'leaderboards';
  static const String leaderboardEntries = 'entries';

  static const String contentReports = 'contentReports';
  static const String adminAuditLog = 'adminAuditLog';
}
