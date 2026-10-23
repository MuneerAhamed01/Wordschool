"""Pure logic for `refreshLeaderboardTop` (CW-021)."""

from collections.abc import Iterable
from datetime import datetime, timedelta

from crossword.types import LeaderboardEntry, LeaderboardTopEntry
from utils.iso_week_id import ist_iso_week_id

TOP_SIZE = 50
REFRESH_INTERVAL = timedelta(minutes=15)
GAME = "crossword"


def board_id(now: datetime) -> str:
    """`crossword-{isoWeek}` for the IST week of `now`."""
    return f"{GAME}-{ist_iso_week_id(now)}"


def board_to_refresh(now: datetime) -> str:
    """The board this run refreshes.

    In the first 15 minutes of a new IST week, last week's board gets its final
    refresh (the new week has next to no entries yet and is refreshed next run).
    """
    previous = board_id(now - REFRESH_INTERVAL)
    return previous if previous != board_id(now) else board_id(now)


def top_entries(entries: Iterable[tuple[str, LeaderboardEntry]]) -> list[LeaderboardTopEntry]:
    """`top50` rows from entries already sorted by points (best first)."""
    return [
        {
            "uid": uid,
            "displayName": entry.get("displayName") or "Player",
            "photoUrl": entry.get("photoUrl"),
            "points": entry.get("points", 0),
            "puzzlesSolved": entry.get("puzzlesSolved", 0),
        }
        for uid, entry in list(entries)[:TOP_SIZE]
    ]
