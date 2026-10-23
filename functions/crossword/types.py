"""Firestore document shapes for PSC Crossword (docs/firebase/FIREBASE_DESIGN.md).

Keys are the Firestore field names (camelCase). `NotRequired` marks fields that are
missing on some documents (optional input, or set only later in the document's life).
"""

from datetime import datetime
from typing import Literal, NotRequired, TypedDict, get_args

from google.cloud.firestore_v1.transforms import Sentinel

# Read back as `datetime`; written as `SERVER_TIMESTAMP` (a `Sentinel`).
type Timestamp = datetime | Sentinel

Difficulty = Literal["easy", "medium", "hard"]
Direction = Literal["across", "down"]
ClueLevel = Literal["easy", "medium", "hard"]
QuestionStatus = Literal["draft", "verified", "retired"]
SourceType = Literal["pyq", "book", "website", "other"]
PuzzleStatus = Literal["draft", "in_review", "scheduled", "published", "archived"]
ProgressStatus = Literal["in_progress", "completed"]
ReportReason = Literal["wrong_answer", "typo", "other"]
ReportStatus = Literal["open", "fixed", "rejected"]
GameName = Literal["crossword"]

DIFFICULTIES: tuple[Difficulty, ...] = get_args(Difficulty)
DIRECTIONS: tuple[Direction, ...] = get_args(Direction)
CLUE_LEVELS: tuple[ClueLevel, ...] = get_args(ClueLevel)
QUESTION_STATUSES: tuple[QuestionStatus, ...] = get_args(QuestionStatus)
SOURCE_TYPES: tuple[SourceType, ...] = get_args(SourceType)
PUZZLE_STATUSES: tuple[PuzzleStatus, ...] = get_args(PuzzleStatus)
PROGRESS_STATUSES: tuple[ProgressStatus, ...] = get_args(ProgressStatus)
REPORT_REASONS: tuple[ReportReason, ...] = get_args(ReportReason)
REPORT_STATUSES: tuple[ReportStatus, ...] = get_args(ReportStatus)

SCHEMA_VERSION = 1


class LocalizedText(TypedDict):
    """Visible text in English and (later) Malayalam."""

    en: str
    ml: NotRequired[str]


class ContentMeta(TypedDict):
    """Standard fields on every content document."""

    schemaVersion: int
    createdAt: Timestamp
    updatedAt: Timestamp
    createdBy: str
    updatedBy: str


class CrosswordCategory(ContentMeta):
    """`crosswordCategories/{categoryId}`; the id is the slug."""

    name: LocalizedText
    description: NotRequired[LocalizedText]
    icon: str
    color: str
    order: int
    isActive: bool
    publishedPuzzleCount: int
    lastPuzzleNumber: int


class QuestionClue(TypedDict):
    """One clue for a question, at a difficulty level."""

    en: str
    ml: NotRequired[str]
    level: ClueLevel


class QuestionSource(TypedDict):
    """Where a fact was checked."""

    type: SourceType
    ref: str


class PscQuestion(ContentMeta):
    """`pscQuestions/{questionId}` (private fact bank)."""

    answer: str
    answerDisplay: LocalizedText
    clues: list[QuestionClue]
    fact: LocalizedText
    subject: str
    topic: NotRequired[str]
    examTags: list[str]
    difficulty: Difficulty
    source: QuestionSource
    status: QuestionStatus
    verifiedBy: NotRequired[str]
    verifiedAt: NotRequired[Timestamp]
    usedInPuzzles: list[str]


class CrosswordWord(TypedDict):
    """One item of `crosswordPuzzles.words`."""

    id: str
    number: int
    direction: Direction
    row: int
    col: int
    length: int
    clue: LocalizedText
    extraClue: NotRequired[LocalizedText]
    fact: LocalizedText
    answerEnc: str
    questionId: str


class CrosswordPuzzle(ContentMeta):
    """`crosswordPuzzles/{categoryId}-{0000}`."""

    categoryId: str
    number: int
    title: LocalizedText
    difficulty: Difficulty
    rows: int
    cols: int
    layout: str
    words: list[CrosswordWord]
    wordCount: int
    xpReward: int
    estimatedMinutes: int
    status: PuzzleStatus
    publishAt: NotRequired[Timestamp]
    publishedAt: NotRequired[Timestamp]


class CrosswordSolution(TypedDict):
    """`crosswordSolutions/{puzzleId}` (private answer key)."""

    answers: dict[str, str]
    schemaVersion: int
    updatedAt: Timestamp


class CrosswordDaily(TypedDict):
    """`crosswordDaily/{YYYY-MM-DD}` (IST date) — pointer to the day's puzzle."""

    puzzleId: str
    categoryId: str
    title: LocalizedText
    difficulty: Difficulty
    wordCount: int
    xpReward: int
    estimatedMinutes: int
    schemaVersion: int
    updatedAt: Timestamp
    updatedBy: str


class HintCount(TypedDict):
    """Hints used in one puzzle; every count only goes up."""

    letter: int
    word: int
    clue: int


class CrosswordResult(TypedDict):
    """`crosswordProgress.result`, written by `submitCrossword`."""

    score: int
    correctWords: int
    totalWords: int
    xpEarned: int
    timeSec: int
    wrongWordIds: list[str]
    revealedWordIds: list[str]


class CrosswordProgress(TypedDict):
    """`users/{uid}/crosswordProgress/{puzzleId}`."""

    status: ProgressStatus
    letters: str
    elapsedSec: int
    hintsUsed: HintCount
    checksUsed: int
    startedAt: Timestamp
    updatedAt: Timestamp
    result: NotRequired[CrosswordResult]
    completedAt: NotRequired[Timestamp]


class RevisionSource(TypedDict):
    """Where a revision item came from."""

    game: GameName
    puzzleId: str


class RevisionItem(TypedDict):
    """`users/{uid}/revisionItems/{questionId}` ("My mistakes")."""

    answer: str
    answerDisplay: LocalizedText
    clue: LocalizedText
    fact: LocalizedText
    subject: str
    source: RevisionSource
    wrongCount: int
    lastWrongAt: Timestamp
    mastered: bool
    nextReviewAt: NotRequired[Timestamp]
    updatedAt: Timestamp


class LeaderboardEntry(TypedDict):
    """`leaderboards/{boardId}/entries/{uid}`."""

    displayName: str
    photoUrl: str | None
    points: int
    puzzlesSolved: int
    updatedAt: Timestamp


class LeaderboardTopEntry(TypedDict):
    """One row of a board's `top50`, best first."""

    uid: str
    displayName: str
    photoUrl: str | None
    points: int
    puzzlesSolved: int


class LeaderboardBoard(TypedDict):
    """`leaderboards/{game}-{isoWeek}` — summary doc read by the Ranks screen."""

    top50: list[LeaderboardTopEntry]
    updatedAt: Timestamp


class ContentReport(TypedDict):
    """`contentReports/{reportId}` — created by players, resolved by admins."""

    uid: str
    puzzleId: str
    wordId: str
    questionId: str
    reason: ReportReason
    message: str
    status: ReportStatus
    createdAt: Timestamp
    resolvedBy: NotRequired[str]
    resolvedAt: NotRequired[Timestamp]
    resolutionNote: NotRequired[str]


class CrosswordStats(TypedDict):
    """`users/{uid}.crossword` (server-only)."""

    played: int
    solved: int
    currentStreak: int
    longestStreak: int
    lastSolvedDate: str
    bestTimeSec: int | None


class RateLimit(TypedDict):
    """`users/{uid}.rateLimit` for `submitCrossword` (server-only)."""

    submitWindowStart: Timestamp
    submitCount: int


class UserProfile(TypedDict):
    """`users/{uid}` — profile fields from the app, the rest server-only (DEC-006)."""

    displayName: NotRequired[str]
    photoUrl: NotRequired[str | None]
    isAnonymous: NotRequired[bool]
    createdAt: NotRequired[Timestamp]
    lastSeenAt: NotRequired[Timestamp]
    xp: NotRequired[int]
    crossword: NotRequired[CrosswordStats]
    rateLimit: NotRequired[RateLimit]
    blockedAt: NotRequired[Timestamp | None]


class AuditLogEntry(TypedDict):
    """`adminAuditLog/{autoId}`."""

    action: str
    adminUid: str
    timestamp: Timestamp
    targetId: NotRequired[str]
    payload: NotRequired[dict[str, str | int | bool | None]]
