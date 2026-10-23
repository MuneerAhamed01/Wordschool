"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST)."""

from datetime import UTC, datetime

import pytest

from crossword.collections import CROSSWORD_CATEGORIES, CROSSWORD_DAILY, CROSSWORD_PUZZLES
from crossword.errors import PreconditionError
from crossword.puzzle_status import schedule_daily, set_puzzle_status
from crossword.save_puzzle import save_puzzle

NOW = datetime(2026, 10, 23, 6, 30, tzinfo=UTC)


def _count(db):
    return (
        db.collection(CROSSWORD_CATEGORIES)
        .document("kerala-history")
        .get()
        .get("publishedPuzzleCount")
    )


def test_publish_archive_counts_and_daily(seeded_example, example_puzzle_input):
    db = seeded_example
    pid = save_puzzle(db, "admin1", example_puzzle_input)["id"]

    with pytest.raises(PreconditionError):
        schedule_daily(db, "admin1", {"dateId": "2026-10-24", "puzzleId": pid}, now=NOW)

    set_puzzle_status(db, "admin1", {"puzzleId": pid, "status": "in_review"}, now=NOW)
    result = set_puzzle_status(db, "admin1", {"puzzleId": pid, "status": "published"}, now=NOW)
    assert result == {"id": pid, "status": "published", "previousStatus": "in_review"}
    assert _count(db) == 1
    puzzle = db.collection(CROSSWORD_PUZZLES).document(pid).get()
    assert puzzle.get("publishedAt") == NOW

    daily = schedule_daily(db, "admin1", {"dateId": "2026-10-24", "puzzleId": pid}, now=NOW)
    assert daily["previousPuzzleId"] is None
    doc = db.collection(CROSSWORD_DAILY).document("2026-10-24").get().to_dict()
    assert doc["puzzleId"] == pid
    assert doc["wordCount"] == 7

    set_puzzle_status(db, "admin1", {"puzzleId": pid, "status": "archived"}, now=NOW)
    assert _count(db) == 0
    with pytest.raises(PreconditionError):
        set_puzzle_status(db, "admin1", {"puzzleId": pid, "status": "published"}, now=NOW)
