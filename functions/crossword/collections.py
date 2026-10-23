"""Firestore collection names. Keep in sync with lib/core/firebase/collections.dart."""

GAMES = "games"
USERS = "users"

# Crossword content (written only by admin functions).
CROSSWORD_CATEGORIES = "crosswordCategories"
CROSSWORD_PUZZLES = "crosswordPuzzles"
CROSSWORD_SOLUTIONS = "crosswordSolutions"
CROSSWORD_DAILY = "crosswordDaily"
PSC_QUESTIONS = "pscQuestions"

# Subcollections of users/{uid}.
CROSSWORD_PROGRESS = "crosswordProgress"
REVISION_ITEMS = "revisionItems"

# leaderboards/{boardId}/entries/{uid}.
LEADERBOARDS = "leaderboards"
LEADERBOARD_ENTRIES = "entries"

CONTENT_REPORTS = "contentReports"
ADMIN_AUDIT_LOG = "adminAuditLog"
