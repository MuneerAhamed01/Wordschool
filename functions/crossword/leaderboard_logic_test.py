from datetime import datetime

from crossword.leaderboard_logic import board_id, board_to_refresh, top_entries


def _at(iso):
    return datetime.fromisoformat(iso)


def test_board_id_uses_ist_week():
    assert board_id(_at("2026-10-23T12:00:00+05:30")) == "crossword-2026-W43"


def test_refreshes_current_week_normally():
    assert board_to_refresh(_at("2026-10-23T12:00:00+05:30")) == "crossword-2026-W43"
    assert board_to_refresh(_at("2026-10-26T00:15:00+05:30")) == "crossword-2026-W44"


def test_first_run_of_a_week_finishes_last_week():
    # Monday 00:00 and 00:14 IST still belong to the previous board's final refresh.
    assert board_to_refresh(_at("2026-10-26T00:00:00+05:30")) == "crossword-2026-W43"
    assert board_to_refresh(_at("2026-10-26T00:14:59+05:30")) == "crossword-2026-W43"


def test_top_entries_caps_at_50_and_fills_defaults():
    entries = [(f"u{i}", {"displayName": f"P{i}", "points": 100 - i}) for i in range(60)]
    entries[0] = ("u0", {"points": 100})
    top = top_entries(iter(entries))
    assert len(top) == 50
    assert top[0] == {
        "uid": "u0",
        "displayName": "Player",
        "photoUrl": None,
        "points": 100,
        "puzzlesSolved": 0,
    }
    assert top[-1]["uid"] == "u49"
