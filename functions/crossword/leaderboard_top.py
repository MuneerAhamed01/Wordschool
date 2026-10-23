from datetime import UTC, datetime
from typing import cast

from firebase_functions import logger, scheduler_fn
from google.cloud.firestore import Client, Query

from crossword.collections import LEADERBOARD_ENTRIES, LEADERBOARDS
from crossword.leaderboard_logic import TOP_SIZE, board_to_refresh, top_entries
from crossword.types import LeaderboardEntry
from firestore_client import db


def refresh_top(client: Client, now: datetime) -> dict[str, object]:
    """Copy the board's best 50 entries into its parent doc (`top50`, `updatedAt`).

    Returns:
        `{"boardId", "reads"}` — reads are the entry docs read (≤ 50).
    """
    board = board_to_refresh(now)
    board_ref = client.collection(LEADERBOARDS).document(board)
    snapshots = list(
        board_ref.collection(LEADERBOARD_ENTRIES)
        .order_by("points", direction=Query.DESCENDING)
        .limit(TOP_SIZE)
        .stream()
    )
    top = top_entries((s.id, cast(LeaderboardEntry, s.to_dict())) for s in snapshots)
    board_ref.set({"top50": top, "updatedAt": now}, merge=True)
    return {"boardId": board, "reads": len(snapshots)}


@scheduler_fn.on_schedule(
    schedule="every 15 minutes", timezone=scheduler_fn.Timezone("Asia/Kolkata")
)
def refreshLeaderboardTop(event: scheduler_fn.ScheduledEvent) -> None:  # noqa: N802
    """Every 15 min: refresh the weekly board's `top50` summary (CW-021)."""
    report = refresh_top(db(), datetime.now(UTC))
    logger.info("refreshLeaderboardTop", boardId=report["boardId"], reads=report["reads"])
