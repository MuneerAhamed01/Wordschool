from datetime import UTC, datetime
from typing import Any, cast

from firebase_functions import https_fn
from google.cloud.firestore import Client, Increment, Transaction

from crossword.collections import (
    CROSSWORD_PROGRESS,
    CROSSWORD_PUZZLES,
    CROSSWORD_SOLUTIONS,
    LEADERBOARD_ENTRIES,
    LEADERBOARDS,
    PSC_QUESTIONS,
    REVISION_ITEMS,
    USERS,
)
from crossword.errors import NotFoundError, PermissionDeniedError, PreconditionError
from crossword.hint_penalties import DEFAULT_HINT_PENALTIES, HintPenalties
from crossword.leaderboard_logic import board_id
from crossword.remote_config import current_hint_penalties
from crossword.submit_logic import (
    completed_progress,
    merge_with_progress,
    next_rate_limit,
    next_stats,
    parse_submit,
    revision_fields,
    score_puzzle,
)
from crossword.types import (
    CrosswordProgress,
    CrosswordPuzzle,
    CrosswordResult,
    CrosswordSolution,
    PscQuestion,
    UserProfile,
)
from firestore_client import db, run_transaction
from utils.callable_errors import callable_errors
from utils.date_id import today_ist_date_id

DEFAULT_DISPLAY_NAME = "Player"


def submit_crossword(
    client: Client,
    uid: str,
    data: object,
    *,
    now: datetime | None = None,
    penalties: HintPenalties = DEFAULT_HINT_PENALTIES,
) -> dict[str, object]:
    """Score a finished puzzle and record it, in one transaction (idempotent).

    Writes the progress result, `users/{uid}` XP + stats + rate limit, the weekly
    leaderboard entry and a revision item per wrong or revealed word.

    Returns:
        `{"result", "xp", "currentStreak", "alreadySubmitted"}`.

    Raises:
        InputError: Bad input or implausible time.
        NotFoundError: Unknown puzzle.
        PreconditionError: Puzzle not published.
        PermissionDeniedError: Blocked player.
        RateLimitError: Over 30 submissions in an hour.
    """
    submit = parse_submit(data)
    at = now or datetime.now(UTC)
    user_ref = client.collection(USERS).document(uid)
    progress_ref = user_ref.collection(CROSSWORD_PROGRESS).document(submit["puzzleId"])
    puzzle_ref = client.collection(CROSSWORD_PUZZLES).document(submit["puzzleId"])
    solution_ref = client.collection(CROSSWORD_SOLUTIONS).document(submit["puzzleId"])

    def body(transaction: Transaction) -> dict[str, object]:
        user_snapshot = user_ref.get(transaction=transaction)
        user = cast(UserProfile, user_snapshot.to_dict() or {})
        if user.get("blockedAt") is not None:
            raise PermissionDeniedError("This account is blocked")

        progress_snapshot = progress_ref.get(transaction=transaction)
        progress = (
            cast(CrosswordProgress, progress_snapshot.to_dict())
            if progress_snapshot.exists
            else None
        )
        if progress is not None and progress["status"] == "completed" and "result" in progress:
            return {
                "result": progress["result"],
                "xp": user.get("xp", 0),
                "currentStreak": user.get("crossword", {}).get("currentStreak", 0),
                "alreadySubmitted": True,
            }

        rate_limit = next_rate_limit(user.get("rateLimit"), at)

        puzzle_snapshot = puzzle_ref.get(transaction=transaction)
        if not puzzle_snapshot.exists:
            raise NotFoundError(f"Puzzle {submit['puzzleId']} not found")
        puzzle = cast(CrosswordPuzzle, puzzle_snapshot.to_dict())
        if puzzle["status"] != "published":
            raise PreconditionError("This puzzle is not open for play")
        solution = cast(CrosswordSolution, solution_ref.get(transaction=transaction).to_dict())

        merged = merge_with_progress(submit, progress)
        result: CrosswordResult = score_puzzle(puzzle, solution["answers"], merged, penalties)

        words = {word["id"]: word for word in puzzle["words"]}
        question_refs = [
            client.collection(PSC_QUESTIONS).document(words[wid]["questionId"])
            for wid in result["wrongWordIds"]
        ]
        questions = {
            snapshot.id: cast(PscQuestion, snapshot.to_dict())
            for snapshot in client.get_all(question_refs, transaction=transaction)
            if snapshot.exists
        }

        stats = next_stats(user.get("crossword"), result, today_ist_date_id(at))
        transaction.set(progress_ref, completed_progress(progress, merged, result, now=at))
        transaction.set(
            user_ref,
            {"xp": Increment(result["xpEarned"]), "crossword": stats, "rateLimit": rate_limit},
            merge=True,
        )
        entry_ref = (
            client.collection(LEADERBOARDS)
            .document(board_id(at))
            .collection(LEADERBOARD_ENTRIES)
            .document(uid)
        )
        transaction.set(
            entry_ref,
            {
                "displayName": user.get("displayName") or DEFAULT_DISPLAY_NAME,
                "photoUrl": user.get("photoUrl"),
                "points": Increment(result["xpEarned"]),
                "puzzlesSolved": Increment(1),
                "updatedAt": at,
            },
            merge=True,
        )
        for wid in result["wrongWordIds"]:
            word = words[wid]
            fields = revision_fields(
                word,
                solution["answers"][wid],
                questions.get(word["questionId"]),
                puzzle_id=submit["puzzleId"],
                now=at,
            )
            transaction.set(
                user_ref.collection(REVISION_ITEMS).document(word["questionId"]),
                {**fields, "wrongCount": Increment(1)},
                merge=True,
            )
        return {
            "result": result,
            "xp": user.get("xp", 0) + result["xpEarned"],
            "currentStreak": stats["currentStreak"],
            "alreadySubmitted": False,
        }

    return run_transaction(client, body)


@https_fn.on_call()
def submitCrossword(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Player: score a finished crossword; XP, stats, leaderboard, mistakes (CW-019)."""
    if req.auth is None or not req.auth.uid:
        raise https_fn.HttpsError(https_fn.FunctionsErrorCode.UNAUTHENTICATED, "Sign in required")
    with callable_errors():
        return submit_crossword(db(), req.auth.uid, req.data, penalties=current_hint_penalties())
