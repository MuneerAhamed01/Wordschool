"""Pure logic for the admin read callables (CW-025): parse inputs, shape JSON."""

from collections.abc import Mapping
from datetime import datetime
from typing import NotRequired, TypedDict

from crossword.category_logic import SLUG_RE
from crossword.input_reader import InputReader
from crossword.puzzle_logic import PUZZLE_ID_RE
from crossword.question_logic import DOC_ID_RE, SNAKE_RE
from crossword.types import (
    PUZZLE_STATUSES,
    QUESTION_STATUSES,
    CrosswordPuzzle,
    PuzzleStatus,
    QuestionStatus,
)

DEFAULT_PAGE_SIZE = 20
MAX_PAGE_SIZE = 100
# Left out of puzzle list rows: the grid itself, only needed to edit one puzzle.
_PUZZLE_DETAIL_FIELDS = ("words", "layout")


class ListQuestionsInput(TypedDict):
    """Validated `adminListQuestions` input."""

    limit: int
    subject: NotRequired[str]
    status: NotRequired[QuestionStatus]
    startAfterId: NotRequired[str]


class ListPuzzlesInput(TypedDict):
    """Validated `adminListPuzzles` input."""

    categoryId: str
    limit: int
    status: NotRequired[PuzzleStatus]
    startAfterId: NotRequired[str]


def parse_list_questions(data: object) -> ListQuestionsInput:
    """Validate `{subject?, status?, limit?, startAfterId?}` (default limit 20).

    Raises:
        InputError: Listing every problem.
    """
    reader = InputReader(data if data is not None else {})
    subject = reader.string("subject", required=False, pattern=SNAKE_RE, max_length=100)
    status = reader.choice("status", QUESTION_STATUSES, required=False)
    limit = reader.integer("limit", required=False, minimum=1, maximum=MAX_PAGE_SIZE)
    start_after = reader.string("startAfterId", required=False, pattern=DOC_ID_RE)
    reader.raise_if_problems()
    request: ListQuestionsInput = {"limit": limit or DEFAULT_PAGE_SIZE}
    if subject:
        request["subject"] = subject
    if status:
        request["status"] = status
    if start_after:
        request["startAfterId"] = start_after
    return request


def parse_list_puzzles(data: object) -> ListPuzzlesInput:
    """Validate `{categoryId, status?, limit?, startAfterId?}` (default limit 20).

    Raises:
        InputError: Listing every problem.
    """
    reader = InputReader(data)
    category_id = reader.string("categoryId", pattern=SLUG_RE, max_length=100)
    status = reader.choice("status", PUZZLE_STATUSES, required=False)
    limit = reader.integer("limit", required=False, minimum=1, maximum=MAX_PAGE_SIZE)
    start_after = reader.string("startAfterId", required=False, pattern=PUZZLE_ID_RE)
    reader.raise_if_problems()
    assert category_id
    request: ListPuzzlesInput = {"categoryId": category_id, "limit": limit or DEFAULT_PAGE_SIZE}
    if status:
        request["status"] = status
    if start_after:
        request["startAfterId"] = start_after
    return request


def parse_puzzle_id(data: object) -> str:
    """Validate `{puzzleId}`.

    Raises:
        InputError: Missing or malformed id.
    """
    reader = InputReader(data)
    puzzle_id = reader.string("puzzleId", pattern=PUZZLE_ID_RE)
    reader.raise_if_problems()
    assert puzzle_id
    return puzzle_id


def _json_value(value: object) -> object:
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, Mapping):
        return {key: _json_value(item) for key, item in value.items()}
    if isinstance(value, list):
        return [_json_value(item) for item in value]
    return value


def doc_json(doc_id: str, doc: Mapping[str, object]) -> dict[str, object]:
    """A document as JSON for the admin panel (timestamps as ISO 8601 strings)."""
    return {"id": doc_id, **{key: _json_value(value) for key, value in doc.items()}}


def puzzle_summary_json(puzzle_id: str, puzzle: CrosswordPuzzle) -> dict[str, object]:
    """A puzzle list row: everything but the grid."""
    summary = {k: v for k, v in puzzle.items() if k not in _PUZZLE_DETAIL_FIELDS}
    return doc_json(puzzle_id, summary)


def puzzle_with_answers_json(
    puzzle_id: str, puzzle: CrosswordPuzzle, answers: Mapping[str, str]
) -> dict[str, object]:
    """The full puzzle with each word's plain `answer`, ready to edit and re-save."""
    result = doc_json(puzzle_id, puzzle)
    result["words"] = [
        {**doc_json(word["id"], word), "answer": answers.get(word["id"], "")}
        for word in puzzle["words"]
    ]
    return result
