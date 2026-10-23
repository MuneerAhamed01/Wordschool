"""Pure logic for `submitCrossword` (CW-019): parse, score, XP, streaks, rate limit.

Scoring rules are DEC-011 in TASKS.md.
"""

import re
from datetime import date, datetime, timedelta
from typing import TypedDict

from crossword.errors import InputError, RateLimitError
from crossword.hint_penalties import DEFAULT_HINT_PENALTIES, HintPenalties
from crossword.input_reader import InputReader
from crossword.puzzle_logic import PUZZLE_ID_RE
from crossword.types import (
    CrosswordProgress,
    CrosswordPuzzle,
    CrosswordResult,
    CrosswordStats,
    CrosswordWord,
    HintCount,
    LocalizedText,
    PscQuestion,
    RateLimit,
    Timestamp,
)
from crossword.validate_puzzle import MAX_SIZE

MIN_SECONDS_PER_WORD = 2
RATE_LIMIT_CALLS = 30
RATE_LIMIT_WINDOW = timedelta(hours=1)

_LETTERS_RE = re.compile(r"[A-Z.#]*")
_WORD_ID_RE = re.compile(r"[0-9]{1,3}[AD]")
_MAX_ELAPSED_SEC = 24 * 60 * 60
_MAX_HINTS = 1000


class SubmitInput(TypedDict):
    """Validated `submitCrossword` input."""

    puzzleId: str
    letters: str
    elapsedSec: int
    hintsUsed: HintCount
    revealedWordIds: list[str]


class RevisionFields(TypedDict):
    """`revisionItems` fields set on every wrong answer (`wrongCount` is incremented)."""

    answer: str
    answerDisplay: LocalizedText
    clue: LocalizedText
    fact: LocalizedText
    subject: str
    source: dict[str, str]
    lastWrongAt: Timestamp
    mastered: bool
    updatedAt: Timestamp


def parse_submit(data: object) -> SubmitInput:
    """Validate `{puzzleId, letters, elapsedSec, hintsUsed, revealedWordIds?}`.

    Raises:
        InputError: Listing every problem.
    """
    reader = InputReader(data)
    puzzle_id = reader.string("puzzleId", pattern=PUZZLE_ID_RE, max_length=70)
    letters = reader.string("letters", max_length=MAX_SIZE * MAX_SIZE, strip=False)
    if letters is not None:
        letters = letters.upper()
        if not _LETTERS_RE.fullmatch(letters):
            reader.problem("letters may only contain A-Z, '.' (empty) and '#' (block)")
    elapsed = reader.integer("elapsedSec", minimum=0, maximum=_MAX_ELAPSED_SEC)
    hints_reader = reader.child("hintsUsed")
    hints = {
        kind: hints_reader.integer(kind, minimum=0, maximum=_MAX_HINTS)
        for kind in ("letter", "word", "clue")
    }
    revealed = reader.string_list("revealedWordIds", required=False, pattern=_WORD_ID_RE) or []
    reader.raise_if_problems()
    assert puzzle_id and letters is not None and elapsed is not None
    return {
        "puzzleId": puzzle_id,
        "letters": letters,
        "elapsedSec": elapsed,
        "hintsUsed": {
            "letter": hints["letter"] or 0,
            "word": hints["word"] or 0,
            "clue": hints["clue"] or 0,
        },
        "revealedWordIds": list(dict.fromkeys(revealed)),
    }


def merge_with_progress(submit: SubmitInput, progress: CrosswordProgress | None) -> SubmitInput:
    """Never trust less time or fewer hints than the saved progress already shows."""
    if progress is None:
        return submit
    saved = progress["hintsUsed"]
    hints = submit["hintsUsed"]
    return {
        **submit,
        "elapsedSec": max(submit["elapsedSec"], progress["elapsedSec"]),
        "hintsUsed": {
            "letter": max(hints["letter"], saved["letter"]),
            "word": max(hints["word"], saved["word"]),
            "clue": max(hints["clue"], saved["clue"]),
        },
    }


def typed_word(letters: str, cols: int, word: CrosswordWord) -> str:
    """What the player typed in a word's cells (`.` for empty)."""
    dr, dc = (0, 1) if word["direction"] == "across" else (1, 0)
    return "".join(
        letters[(word["row"] + dr * i) * cols + word["col"] + dc * i] for i in range(word["length"])
    )


def score_puzzle(
    puzzle: CrosswordPuzzle,
    answers: dict[str, str],
    submit: SubmitInput,
    penalties: HintPenalties = DEFAULT_HINT_PENALTIES,
) -> CrosswordResult:
    """Score a submission against the private answer key.

    `penalties` is the XP per revealed letter / word (Remote Config, CW-026).

    Raises:
        InputError: Letters don't fit the grid, or the time is implausibly short.
    """
    words = puzzle["words"]
    cells = puzzle["rows"] * puzzle["cols"]
    if len(submit["letters"]) != cells:
        raise InputError([f"letters has {len(submit['letters'])} chars, expected {cells}"])
    if submit["elapsedSec"] < len(words) * MIN_SECONDS_PER_WORD:
        raise InputError(["elapsedSec is too short for this puzzle"])

    word_ids = {word["id"] for word in words}
    revealed = [wid for wid in submit["revealedWordIds"] if wid in word_ids]
    wrong = [
        word["id"]
        for word in words
        if word["id"] in revealed
        or typed_word(submit["letters"], puzzle["cols"], word) != answers.get(word["id"])
    ]
    total = len(words)
    correct = total - len(wrong)
    hints = submit["hintsUsed"]
    penalty = hints["letter"] * penalties["letter"] + hints["word"] * penalties["word"]
    return {
        "score": round(100 * correct / total),
        "correctWords": correct,
        "totalWords": total,
        "xpEarned": max(0, round(puzzle["xpReward"] * correct / total) - penalty),
        "timeSec": submit["elapsedSec"],
        "wrongWordIds": wrong,
        "revealedWordIds": revealed,
    }


def next_rate_limit(current: RateLimit | None, now: datetime) -> RateLimit:
    """Count this call in the hourly window.

    Raises:
        RateLimitError: 30 calls already made in the current window.
    """
    start = current["submitWindowStart"] if current else None
    if current is None or not isinstance(start, datetime) or now - start >= RATE_LIMIT_WINDOW:
        return {"submitWindowStart": now, "submitCount": 1}
    if current["submitCount"] >= RATE_LIMIT_CALLS:
        raise RateLimitError("Too many submissions — try again in a while")
    return {"submitWindowStart": start, "submitCount": current["submitCount"] + 1}


def next_stats(
    current: CrosswordStats | None, result: CrosswordResult, today_id: str
) -> CrosswordStats:
    """Update `users/{uid}.crossword` after a completed puzzle (streak by IST day)."""
    stats: CrosswordStats = current or {
        "played": 0,
        "solved": 0,
        "currentStreak": 0,
        "longestStreak": 0,
        "lastSolvedDate": "",
        "bestTimeSec": None,
    }
    perfect = result["correctWords"] == result["totalWords"]
    yesterday = (date.fromisoformat(today_id) - timedelta(days=1)).isoformat()
    last = stats["lastSolvedDate"]
    if last == today_id:
        streak = stats["currentStreak"]
    elif last == yesterday:
        streak = stats["currentStreak"] + 1
    else:
        streak = 1
    best = stats["bestTimeSec"]
    if perfect and (best is None or result["timeSec"] < best):
        best = result["timeSec"]
    return {
        "played": stats["played"] + 1,
        "solved": stats["solved"] + (1 if perfect else 0),
        "currentStreak": streak,
        "longestStreak": max(stats["longestStreak"], streak),
        "lastSolvedDate": today_id,
        "bestTimeSec": best,
    }


def completed_progress(
    existing: CrosswordProgress | None,
    submit: SubmitInput,
    result: CrosswordResult,
    *,
    now: Timestamp,
) -> CrosswordProgress:
    """The progress document after a submit."""
    return {
        "status": "completed",
        "letters": submit["letters"],
        "elapsedSec": submit["elapsedSec"],
        "hintsUsed": submit["hintsUsed"],
        "checksUsed": existing["checksUsed"] if existing else 0,
        "startedAt": existing["startedAt"] if existing else now,
        "updatedAt": now,
        "completedAt": now,
        "result": result,
    }


def revision_fields(
    word: CrosswordWord,
    answer: str,
    question: PscQuestion | None,
    *,
    puzzle_id: str,
    now: Timestamp,
) -> RevisionFields:
    """Fields for the player's revision item of a wrong or revealed word."""
    return {
        "answer": answer,
        "answerDisplay": question["answerDisplay"] if question else {"en": answer.title()},
        "clue": word["clue"],
        "fact": word["fact"],
        "subject": question["subject"] if question else "",
        "source": {"game": "crossword", "puzzleId": puzzle_id},
        "lastWrongAt": now,
        "mastered": False,
        "updatedAt": now,
    }
