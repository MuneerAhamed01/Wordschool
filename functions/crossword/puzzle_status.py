from datetime import UTC, datetime
from typing import Any, cast

from firebase_functions import https_fn
from google.cloud.firestore import Client, Increment, Transaction

from admin.assert_admin import assert_admin
from admin.audit_log import write_audit_log
from crossword.collections import CROSSWORD_CATEGORIES, CROSSWORD_DAILY, CROSSWORD_PUZZLES
from crossword.errors import NotFoundError
from crossword.status_logic import daily_doc, parse_daily, parse_status, status_change
from crossword.types import CrosswordPuzzle
from firestore_client import db, run_transaction
from utils.callable_errors import callable_errors


def set_puzzle_status(
    client: Client, admin_uid: str, data: object, *, now: datetime | None = None
) -> dict[str, object]:
    """Move a puzzle through the status state machine.

    Publishing increments and archiving decrements the category's `publishedPuzzleCount`
    in the same transaction.

    Returns:
        `{"id", "status", "previousStatus"}`.

    Raises:
        InputError: Invalid data or `publishAt`.
        NotFoundError: No such puzzle.
        PreconditionError: Transition not allowed.
    """
    request = parse_status(data)
    at = now or datetime.now(UTC)
    ref = client.collection(CROSSWORD_PUZZLES).document(request["puzzleId"])

    def body(transaction: Transaction) -> str:
        snapshot = ref.get(transaction=transaction)
        if not snapshot.exists:
            raise NotFoundError(f"Puzzle {request['puzzleId']} not found")
        puzzle = cast(CrosswordPuzzle, snapshot.to_dict())
        change = status_change(puzzle["status"], request, admin_uid=admin_uid, now=at)
        transaction.update(ref, change["updates"])
        if change["countDelta"]:
            transaction.update(
                client.collection(CROSSWORD_CATEGORIES).document(puzzle["categoryId"]),
                {"publishedPuzzleCount": Increment(change["countDelta"])},
            )
        return puzzle["status"]

    previous = run_transaction(client, body)
    return {"id": request["puzzleId"], "status": request["status"], "previousStatus": previous}


def schedule_daily(
    client: Client, admin_uid: str, data: object, *, now: datetime | None = None
) -> dict[str, object]:
    """Point `crosswordDaily/{dateId}` at a scheduled or published puzzle.

    Returns:
        `{"dateId", "puzzleId", "previousPuzzleId"}`.

    Raises:
        InputError: Invalid data or a past date.
        NotFoundError: No such puzzle.
        PreconditionError: The puzzle can't be shown that day.
    """
    request = parse_daily(data)
    at = now or datetime.now(UTC)
    puzzle_ref = client.collection(CROSSWORD_PUZZLES).document(request["puzzleId"])
    daily_ref = client.collection(CROSSWORD_DAILY).document(request["dateId"])

    def body(transaction: Transaction) -> str | None:
        snapshot = puzzle_ref.get(transaction=transaction)
        if not snapshot.exists:
            raise NotFoundError(f"Puzzle {request['puzzleId']} not found")
        previous = daily_ref.get(transaction=transaction)
        doc = daily_doc(
            request, cast(CrosswordPuzzle, snapshot.to_dict()), admin_uid=admin_uid, now=at
        )
        transaction.set(daily_ref, doc)
        return cast(str, previous.get("puzzleId")) if previous.exists else None

    previous_id = run_transaction(client, body)
    return {**request, "previousPuzzleId": previous_id}


@https_fn.on_call()
def adminSetPuzzleStatus(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: review, schedule, publish or archive a puzzle (CW-018)."""
    admin_uid = assert_admin(req)
    with callable_errors():
        result = set_puzzle_status(db(), admin_uid, req.data)
    write_audit_log(
        action="crossword.setPuzzleStatus",
        admin_uid=admin_uid,
        target_id=str(result["id"]),
        payload={"from": result["previousStatus"], "to": result["status"]},
    )
    return result


@https_fn.on_call()
def adminScheduleDaily(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: choose the daily puzzle for an IST date (CW-018)."""
    admin_uid = assert_admin(req)
    with callable_errors():
        result = schedule_daily(db(), admin_uid, req.data)
    write_audit_log(
        action="crossword.scheduleDaily",
        admin_uid=admin_uid,
        target_id=str(result["dateId"]),
        payload={"puzzleId": result["puzzleId"], "previous": result["previousPuzzleId"]},
    )
    return result
