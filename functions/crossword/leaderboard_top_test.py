"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST)."""

from datetime import datetime

from crossword.collections import LEADERBOARD_ENTRIES, LEADERBOARDS
from crossword.leaderboard_top import refresh_top

NOW = datetime.fromisoformat("2026-10-23T12:00:00+05:30")


def test_reads_at_most_50_and_writes_top50(emulator_db):
    board = emulator_db.collection(LEADERBOARDS).document("crossword-2026-W43")
    batch = emulator_db.batch()
    for i in range(55):
        batch.set(
            board.collection(LEADERBOARD_ENTRIES).document(f"u{i:02d}"),
            {"displayName": f"P{i}", "photoUrl": None, "points": i * 10, "puzzlesSolved": 1},
        )
    batch.commit()

    report = refresh_top(emulator_db, NOW)

    assert report == {"boardId": "crossword-2026-W43", "reads": 50}
    top50 = board.get().get("top50")
    assert len(top50) == 50
    assert top50[0]["uid"] == "u54"
    assert top50[0]["points"] == 540
    assert [row["points"] for row in top50] == sorted((r["points"] for r in top50), reverse=True)


def test_empty_board(emulator_db):
    assert refresh_top(emulator_db, NOW)["reads"] == 0
    board = emulator_db.collection(LEADERBOARDS).document("crossword-2026-W43").get()
    assert board.get("top50") == []
