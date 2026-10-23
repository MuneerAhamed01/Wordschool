from datetime import UTC, datetime
from typing import cast

from firebase_functions import logger, scheduler_fn
from google.cloud.firestore import Client, FieldFilter, Increment, Transaction

from crossword.collections import CROSSWORD_CATEGORIES, CROSSWORD_DAILY, CROSSWORD_PUZZLES
from crossword.status_logic import is_due, publish_updates, select_due
from crossword.types import CrosswordPuzzle
from firestore_client import db, run_transaction
from utils.date_id import add_days, today_ist_date_id

# Scheduled puzzles are few (a few weeks ahead); this bounds the reads anyway.
MAX_SCHEDULED_READ = 200


def publish_if_due(client: Client, puzzle_id: str, now: datetime) -> bool:
    """Publish one scheduled puzzle and bump its category count, if it is still due.

    Returns:
        True when this call published it.
    """
    ref = client.collection(CROSSWORD_PUZZLES).document(puzzle_id)

    def body(transaction: Transaction) -> bool:
        snapshot = ref.get(transaction=transaction)
        puzzle = cast(CrosswordPuzzle, snapshot.to_dict()) if snapshot.exists else None
        if puzzle is None or not is_due(puzzle, now):
            return False
        transaction.update(ref, {**publish_updates(now), "updatedBy": "system"})
        transaction.update(
            client.collection(CROSSWORD_CATEGORIES).document(puzzle["categoryId"]),
            {"publishedPuzzleCount": Increment(1)},
        )
        return True

    return run_transaction(client, body)


def rollover(client: Client, now: datetime) -> dict[str, object]:
    """Publish due puzzles; report whether today's and tomorrow's daily pointers exist.

    Returns:
        `{"published": [ids], "todayMissing": bool, "tomorrowMissing": bool}`.
    """
    snapshots = (
        client.collection(CROSSWORD_PUZZLES)
        .where(filter=FieldFilter("status", "==", "scheduled"))
        .limit(MAX_SCHEDULED_READ)
        .stream()
    )
    scheduled = {snapshot.id: cast(CrosswordPuzzle, snapshot.to_dict()) for snapshot in snapshots}
    published = [pid for pid in select_due(scheduled, now) if publish_if_due(client, pid, now)]

    today = today_ist_date_id(now)
    tomorrow = add_days(today, 1)
    daily = client.collection(CROSSWORD_DAILY)
    return {
        "published": published,
        "todayMissing": not daily.document(today).get().exists,
        "tomorrowMissing": not daily.document(tomorrow).get().exists,
        "today": today,
        "tomorrow": tomorrow,
    }


@scheduler_fn.on_schedule(schedule="5 0 * * *", timezone=scheduler_fn.Timezone("Asia/Kolkata"))
def crosswordDailyRollover(event: scheduler_fn.ScheduledEvent) -> None:  # noqa: N802
    """00:05 IST: publish due puzzles; error if tomorrow has no daily puzzle (CW-020)."""
    report = rollover(db(), datetime.now(UTC))
    logger.info("crosswordDailyRollover", published=report["published"])
    if report["todayMissing"]:
        logger.error("No crosswordDaily doc for today", dateId=report["today"])
    if report["tomorrowMissing"]:
        logger.error("No crosswordDaily doc for tomorrow", dateId=report["tomorrow"])
