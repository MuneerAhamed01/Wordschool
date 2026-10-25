"""Entry point for the Kerala PSC Cloud Functions.

Every deployed function must be importable from this module.
"""

import firebase_admin
from firebase_functions.options import set_global_options

try:
    firebase_admin.get_app()
except ValueError:
    firebase_admin.initialize_app()

set_global_options(region="asia-south1", max_instances=10)

# PSC Crossword (deployed names are what the apps call).
from crossword.admin_reads import (  # noqa: E402
    adminGetPuzzle,
    adminGetQuestion,
    adminListCategories,
    adminListPuzzles,
    adminListQuestions,
)
from crossword.daily_rollover import crosswordDailyRollover  # noqa: E402
from crossword.leaderboard_top import refreshLeaderboardTop  # noqa: E402
from crossword.puzzle_status import adminScheduleDaily, adminSetPuzzleStatus  # noqa: E402
from crossword.questions import adminSaveQuestion, adminVerifyQuestion  # noqa: E402
from crossword.reports import adminListReports, adminResolveReport  # noqa: E402
from crossword.save_category import adminSaveCategory  # noqa: E402
from crossword.save_puzzle import adminSaveCrosswordPuzzle  # noqa: E402
from crossword.submit import submitCrossword  # noqa: E402

__all__ = [
    "adminGetPuzzle",
    "adminGetQuestion",
    "adminListCategories",
    "adminListPuzzles",
    "adminListQuestions",
    "adminListReports",
    "adminResolveReport",
    "adminSaveCategory",
    "adminSaveCrosswordPuzzle",
    "adminSaveQuestion",
    "adminScheduleDaily",
    "adminSetPuzzleStatus",
    "adminVerifyQuestion",
    "crosswordDailyRollover",
    "refreshLeaderboardTop",
    "submitCrossword",
]
