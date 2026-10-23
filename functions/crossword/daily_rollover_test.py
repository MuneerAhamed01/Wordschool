"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST). Selection logic is tested in
status_logic_test.py (`select_due`)."""

from datetime import UTC, datetime, timedelta

from crossword.collections import CROSSWORD_CATEGORIES, CROSSWORD_DAILY, CROSSWORD_PUZZLES
from crossword.daily_rollover import publish_if_due, rollover
from crossword.puzzle_status import set_puzzle_status
from crossword.save_puzzle import save_puzzle

NOW = datetime(2026, 10, 23, 18, 35, tzinfo=UTC)  # 2026-10-24 00:05 IST


def _schedule(db, puzzle_input, publish_at):
    pid = save_puzzle(db, "admin1", puzzle_input)["id"]
    set_puzzle_status(
        db, "admin1", {"puzzleId": pid, "status": "in_review"}, now=NOW - timedelta(days=7)
    )
    set_puzzle_status(
        db,
        "admin1",
        {"puzzleId": pid, "status": "scheduled", "publishAt": publish_at.isoformat()},
        now=NOW - timedelta(days=7),
    )
    return pid


def test_publishes_due_puzzles_once(seeded_example, example_puzzle_input):
    db = seeded_example
    due = _schedule(db, example_puzzle_input, NOW - timedelta(minutes=5))
    later = _schedule(db, example_puzzle_input, NOW + timedelta(days=1))
    db.collection(CROSSWORD_DAILY).document("2026-10-24").set({"puzzleId": due})

    report = rollover(db, NOW)

    assert report["published"] == [due]
    assert report["todayMissing"] is False
    assert report["tomorrowMissing"] is True
    assert report["tomorrow"] == "2026-10-25"
    puzzles = db.collection(CROSSWORD_PUZZLES)
    assert puzzles.document(due).get().get("status") == "published"
    assert puzzles.document(later).get().get("status") == "scheduled"
    category = db.collection(CROSSWORD_CATEGORIES).document("kerala-history").get()
    assert category.get("publishedPuzzleCount") == 1

    assert rollover(db, NOW)["published"] == []
    assert publish_if_due(db, due, NOW) is False
    assert category.reference.get().get("publishedPuzzleCount") == 1
