from typing import Any, cast

from firebase_functions import https_fn
from google.cloud.firestore import Client, CollectionReference, FieldFilter, Query

from admin.assert_admin import assert_admin
from crossword.admin_read_logic import (
    doc_json,
    parse_list_puzzles,
    parse_list_questions,
    parse_puzzle_id,
    puzzle_summary_json,
    puzzle_with_answers_json,
)
from crossword.collections import (
    CROSSWORD_CATEGORIES,
    CROSSWORD_PUZZLES,
    CROSSWORD_SOLUTIONS,
    PSC_QUESTIONS,
)
from crossword.errors import NotFoundError
from crossword.question_logic import parse_question_id
from crossword.types import CrosswordPuzzle, CrosswordSolution
from firestore_client import db
from utils.callable_errors import callable_errors


def _page(
    collection: CollectionReference, query: Query, limit: int, start_after_id: str | None
) -> tuple[list[Any], str | None]:
    """Run `query` after the cursor doc; returns the snapshots and the next cursor id.

    Raises:
        NotFoundError: The cursor doc does not exist.
    """
    query = query.limit(limit)
    if start_after_id is not None:
        cursor = collection.document(start_after_id).get()
        if not cursor.exists:
            raise NotFoundError(f"{start_after_id} not found")
        query = query.start_after(cursor)
    snapshots = list(query.stream())
    return snapshots, snapshots[-1].id if len(snapshots) == limit else None


def list_questions(client: Client, data: object) -> dict[str, object]:
    """One page of questions, recently updated first, optionally by subject and status.

    Returns:
        `{"questions": [...], "nextStartAfterId": id | None}`.

    Raises:
        InputError: Invalid data.
        NotFoundError: `startAfterId` does not exist.
    """
    request = parse_list_questions(data)
    collection = client.collection(PSC_QUESTIONS)
    query: Query = collection.order_by("updatedAt", direction=Query.DESCENDING)
    if "subject" in request:
        query = query.where(filter=FieldFilter("subject", "==", request["subject"]))
    if "status" in request:
        query = query.where(filter=FieldFilter("status", "==", request["status"]))
    snapshots, next_id = _page(collection, query, request["limit"], request.get("startAfterId"))
    return {
        "questions": [doc_json(s.id, s.to_dict()) for s in snapshots],
        "nextStartAfterId": next_id,
    }


def list_puzzles(client: Client, data: object) -> dict[str, object]:
    """One page of a category's puzzles, newest number first, without their grids.

    Returns:
        `{"puzzles": [...], "nextStartAfterId": id | None}`.

    Raises:
        InputError: Invalid data.
        NotFoundError: `startAfterId` does not exist.
    """
    request = parse_list_puzzles(data)
    collection = client.collection(CROSSWORD_PUZZLES)
    query = collection.where(filter=FieldFilter("categoryId", "==", request["categoryId"]))
    if "status" in request:
        query = query.where(filter=FieldFilter("status", "==", request["status"]))
    query = query.order_by("number", direction=Query.DESCENDING)
    snapshots, next_id = _page(collection, query, request["limit"], request.get("startAfterId"))
    return {
        "puzzles": [
            puzzle_summary_json(s.id, cast(CrosswordPuzzle, s.to_dict())) for s in snapshots
        ],
        "nextStartAfterId": next_id,
    }


def get_puzzle(client: Client, data: object) -> dict[str, object]:
    """A puzzle with the plain answers from its private solution, for editing.

    Returns:
        `{"puzzle": {...}}`; each word has `answer`.

    Raises:
        InputError: Invalid data.
        NotFoundError: No such puzzle.
    """
    puzzle_id = parse_puzzle_id(data)
    puzzle_ref = client.collection(CROSSWORD_PUZZLES).document(puzzle_id)
    solution_ref = client.collection(CROSSWORD_SOLUTIONS).document(puzzle_id)
    snapshots = {s.reference.path: s for s in client.get_all([puzzle_ref, solution_ref])}
    puzzle_snapshot = snapshots[puzzle_ref.path]
    if not puzzle_snapshot.exists:
        raise NotFoundError(f"Puzzle {puzzle_id} not found")
    solution = cast(CrosswordSolution | None, snapshots[solution_ref.path].to_dict())
    answers = solution["answers"] if solution else {}
    puzzle = cast(CrosswordPuzzle, puzzle_snapshot.to_dict())
    return {"puzzle": puzzle_with_answers_json(puzzle_id, puzzle, answers)}


def get_question(client: Client, data: object) -> dict[str, object]:
    """One question, e.g. to fix it from a player report.

    Returns:
        `{"question": {...}}`.

    Raises:
        InputError: Invalid data.
        NotFoundError: No such question.
    """
    question_id = parse_question_id(data)
    snapshot = client.collection(PSC_QUESTIONS).document(question_id).get()
    if not snapshot.exists:
        raise NotFoundError(f"Question {question_id} not found")
    return {"question": doc_json(snapshot.id, snapshot.to_dict())}


def list_categories(client: Client) -> dict[str, object]:
    """Every category, active or not, in display order (a few dozen docs at most).

    Returns:
        `{"categories": [...]}`.
    """
    snapshots = client.collection(CROSSWORD_CATEGORIES).order_by("order").stream()
    return {"categories": [doc_json(s.id, s.to_dict()) for s in snapshots]}


@https_fn.on_call()
def adminListQuestions(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: page through the question bank (CW-025)."""
    assert_admin(req)
    with callable_errors():
        return list_questions(db(), req.data)


@https_fn.on_call()
def adminListPuzzles(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: page through a category's puzzles in any status (CW-025)."""
    assert_admin(req)
    with callable_errors():
        return list_puzzles(db(), req.data)


@https_fn.on_call()
def adminGetPuzzle(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: one puzzle with its answers, for the puzzle builder (CW-025)."""
    assert_admin(req)
    with callable_errors():
        return get_puzzle(db(), req.data)


@https_fn.on_call()
def adminGetQuestion(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: one question, for the reports page (CW-035)."""
    assert_admin(req)
    with callable_errors():
        return get_question(db(), req.data)


@https_fn.on_call()
def adminListCategories(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: every category, including inactive ones (CW-025)."""
    assert_admin(req)
    with callable_errors():
        return list_categories(db())
