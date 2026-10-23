"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST)."""

from datetime import UTC, datetime

import pytest

from crossword.collections import (
    CROSSWORD_PROGRESS,
    LEADERBOARD_ENTRIES,
    LEADERBOARDS,
    REVISION_ITEMS,
    USERS,
)
from crossword.errors import PermissionDeniedError, PreconditionError
from crossword.puzzle_status import set_puzzle_status
from crossword.save_puzzle import save_puzzle
from crossword.submit import submit_crossword
from crossword.validate_puzzle import word_cells

NOW = datetime(2026, 10, 23, 6, 30, tzinfo=UTC)  # IST week 2026-W43


def _letters(puzzle_input, overrides):
    cells = list(puzzle_input["layout"])
    for word in puzzle_input["words"]:
        answer = overrides.get(word["id"], word["answer"])
        for (r, c), letter in zip(word_cells(word), answer, strict=True):
            cells[r * puzzle_input["cols"] + c] = letter
    return "".join(cells)


def _publish(db, puzzle_input):
    pid = save_puzzle(db, "admin1", puzzle_input)["id"]
    set_puzzle_status(db, "admin1", {"puzzleId": pid, "status": "in_review"}, now=NOW)
    set_puzzle_status(db, "admin1", {"puzzleId": pid, "status": "published"}, now=NOW)
    return pid


def _data(pid, puzzle_input, overrides=None, revealed=None):
    return {
        "puzzleId": pid,
        "letters": _letters(puzzle_input, overrides or {}),
        "elapsedSec": 200,
        "hintsUsed": {"letter": 0, "word": 1, "clue": 2},
        "revealedWordIds": revealed or [],
    }


def test_full_submit_writes_all_four_places(seeded_example, example_puzzle_input):
    db = seeded_example
    pid = _publish(db, example_puzzle_input)
    user_ref = db.collection(USERS).document("alice")
    user_ref.set({"displayName": "Alice", "isAnonymous": False, "xp": 100})

    response = submit_crossword(
        db, "alice", _data(pid, example_puzzle_input, {"2D": "VAIKAM"}, ["3D"]), now=NOW
    )

    result = response["result"]
    assert result["wrongWordIds"] == ["2D", "3D"]
    assert result["xpEarned"] == round(50 * 5 / 7) - 15
    assert response["xp"] == 100 + result["xpEarned"]
    assert response["currentStreak"] == 1
    assert response["alreadySubmitted"] is False

    # 1. progress
    progress = user_ref.collection(CROSSWORD_PROGRESS).document(pid).get().to_dict()
    assert progress["status"] == "completed"
    assert progress["result"] == result
    # 2. user
    user = user_ref.get().to_dict()
    assert user["xp"] == response["xp"]
    assert user["crossword"]["played"] == 1
    assert user["crossword"]["lastSolvedDate"] == "2026-10-23"
    assert user["rateLimit"]["submitCount"] == 1
    # 3. leaderboard
    entry = (
        db.collection(LEADERBOARDS)
        .document("crossword-2026-W43")
        .collection(LEADERBOARD_ENTRIES)
        .document("alice")
        .get()
        .to_dict()
    )
    assert entry["points"] == result["xpEarned"]
    assert entry["puzzlesSolved"] == 1
    assert entry["displayName"] == "Alice"
    # 4. revision items
    items = {doc.id: doc.to_dict() for doc in user_ref.collection(REVISION_ITEMS).stream()}
    assert set(items) == {"q-vaikom", "q-gama"}
    assert items["q-vaikom"]["answer"] == "VAIKOM"
    assert items["q-vaikom"]["wrongCount"] == 1
    assert items["q-vaikom"]["mastered"] is False

    # Idempotent: the same result, no second XP or leaderboard points.
    again = submit_crossword(db, "alice", _data(pid, example_puzzle_input), now=NOW)
    assert again == {**response, "alreadySubmitted": True}
    assert user_ref.get().get("xp") == response["xp"]


def test_works_without_profile_or_saved_progress(seeded_example, example_puzzle_input):
    db = seeded_example
    pid = _publish(db, example_puzzle_input)
    response = submit_crossword(db, "guest", _data(pid, example_puzzle_input), now=NOW)
    assert response["result"]["correctWords"] == 7
    assert db.collection(USERS).document("guest").get().get("xp") == 50 - 15


def test_blocked_player_refused(seeded_example, example_puzzle_input):
    db = seeded_example
    pid = _publish(db, example_puzzle_input)
    db.collection(USERS).document("mallory").set({"blockedAt": NOW})
    with pytest.raises(PermissionDeniedError):
        submit_crossword(db, "mallory", _data(pid, example_puzzle_input), now=NOW)


def test_unpublished_puzzle_refused(seeded_example, example_puzzle_input):
    db = seeded_example
    pid = save_puzzle(db, "admin1", example_puzzle_input)["id"]
    with pytest.raises(PreconditionError):
        submit_crossword(db, "alice", _data(pid, example_puzzle_input), now=NOW)
