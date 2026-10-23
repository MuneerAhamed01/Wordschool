from typing import Any, cast

from firebase_admin import firestore
from firebase_functions import https_fn
from google.cloud.firestore import ArrayRemove, ArrayUnion, Client, Transaction

from admin.assert_admin import assert_admin
from admin.audit_log import write_audit_log
from crossword.collections import (
    CROSSWORD_CATEGORIES,
    CROSSWORD_PUZZLES,
    CROSSWORD_SOLUTIONS,
    PSC_QUESTIONS,
)
from crossword.errors import NotFoundError
from crossword.puzzle_logic import (
    check_editable,
    check_questions,
    parse_puzzle,
    puzzle_doc,
    puzzle_id_for,
    question_ids,
    question_usage,
    solution_doc,
)
from crossword.types import CrosswordCategory, CrosswordPuzzle, PscQuestion, Timestamp
from firestore_client import db, run_transaction
from utils.callable_errors import callable_errors


def save_puzzle(
    client: Client, admin_uid: str, data: object, *, now: Timestamp = firestore.SERVER_TIMESTAMP
) -> dict[str, object]:
    """Validate and save a puzzle as `draft`, with its private solution, in one transaction.

    A new puzzle (no `id`) gets the next number in its category.

    Returns:
        `{"id", "number", "created", "status": "draft"}`.

    Raises:
        InputError: Invalid fields, grid, or questions (missing, unverified, other answer).
        NotFoundError: Unknown category or puzzle id.
        PreconditionError: The puzzle is no longer editable.
    """
    puzzle = parse_puzzle(data)
    category_ref = client.collection(CROSSWORD_CATEGORIES).document(puzzle["categoryId"])
    question_refs = [client.collection(PSC_QUESTIONS).document(qid) for qid in question_ids(puzzle)]

    def body(transaction: Transaction) -> dict[str, object]:
        category_snapshot = category_ref.get(transaction=transaction)
        if not category_snapshot.exists:
            raise NotFoundError(f"Category {puzzle['categoryId']} not found")
        category = cast(CrosswordCategory, category_snapshot.to_dict())

        existing: CrosswordPuzzle | None = None
        if "id" in puzzle:
            snapshot = (
                client.collection(CROSSWORD_PUZZLES)
                .document(puzzle["id"])
                .get(transaction=transaction)
            )
            if not snapshot.exists:
                raise NotFoundError(f"Puzzle {puzzle['id']} not found")
            existing = cast(CrosswordPuzzle, snapshot.to_dict())
            check_editable(existing)

        questions: dict[str, PscQuestion | None] = {ref.id: None for ref in question_refs}
        for snapshot in client.get_all(question_refs, transaction=transaction):
            if snapshot.exists:
                questions[snapshot.id] = cast(PscQuestion, snapshot.to_dict())
        check_questions(puzzle, questions)

        number = existing["number"] if existing else category.get("lastPuzzleNumber", 0) + 1
        puzzle_id = puzzle_id_for(puzzle["categoryId"], number)
        puzzle_ref = client.collection(CROSSWORD_PUZZLES).document(puzzle_id)
        doc = puzzle_doc(
            puzzle,
            puzzle_id=puzzle_id,
            number=number,
            questions=questions,
            admin_uid=admin_uid,
            existing=existing,
            now=now,
        )
        transaction.set(puzzle_ref, doc)
        transaction.set(
            client.collection(CROSSWORD_SOLUTIONS).document(puzzle_id),
            solution_doc(puzzle, now=now),
        )
        if existing is None:
            transaction.update(category_ref, {"lastPuzzleNumber": number})
        usage = question_usage(puzzle, existing)
        for qid in usage["added"]:
            transaction.update(
                client.collection(PSC_QUESTIONS).document(qid),
                {"usedInPuzzles": ArrayUnion([puzzle_id])},
            )
        for qid in usage["removed"]:
            transaction.update(
                client.collection(PSC_QUESTIONS).document(qid),
                {"usedInPuzzles": ArrayRemove([puzzle_id])},
            )
        return {"id": puzzle_id, "number": number, "created": existing is None, "status": "draft"}

    return run_transaction(client, body)


@https_fn.on_call()
def adminSaveCrosswordPuzzle(  # noqa: N802
    req: https_fn.CallableRequest[Any],
) -> dict[str, object]:
    """Admin: validate a grid and save the puzzle + solution as a draft (CW-017)."""
    admin_uid = assert_admin(req)
    with callable_errors():
        result = save_puzzle(db(), admin_uid, req.data)
    write_audit_log(
        action="crossword.savePuzzle",
        admin_uid=admin_uid,
        target_id=str(result["id"]),
        payload={"created": result["created"]},
    )
    return result
