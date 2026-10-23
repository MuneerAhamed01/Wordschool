"""Pure logic for `adminSaveCrosswordPuzzle` (CW-017)."""

import re
from collections.abc import Mapping
from typing import NotRequired, TypedDict

from crossword.answer_encoding import encode_answer
from crossword.category_logic import SLUG_RE
from crossword.errors import InputError, PreconditionError
from crossword.input_reader import InputReader
from crossword.question_logic import DOC_ID_RE, normalize_answer
from crossword.types import (
    DIFFICULTIES,
    DIRECTIONS,
    SCHEMA_VERSION,
    CrosswordPuzzle,
    CrosswordSolution,
    CrosswordWord,
    Difficulty,
    LocalizedText,
    PscQuestion,
    Timestamp,
)
from crossword.validate_puzzle import MAX_SIZE, MIN_SIZE, Grid, GridWord, validate_puzzle

PUZZLE_ID_RE = re.compile(r"[a-z0-9-]+-[0-9]{4}")
EDITABLE_STATUSES = ("draft", "in_review")


class PuzzleInput(TypedDict):
    """Validated `adminSaveCrosswordPuzzle` input (`id` absent = new puzzle); also a `Grid`."""

    id: NotRequired[str]
    rows: int
    cols: int
    layout: str
    words: list[GridWord]
    categoryId: str
    title: LocalizedText
    difficulty: Difficulty
    xpReward: int
    estimatedMinutes: int


class QuestionUsage(TypedDict):
    """Question ids whose `usedInPuzzles` must gain or lose this puzzle."""

    added: list[str]
    removed: list[str]


def puzzle_id_for(category_id: str, number: int) -> str:
    """`kerala-history` + 12 → `kerala-history-0012`."""
    return f"{category_id}-{number:04d}"


def _parse_word(reader: InputReader) -> GridWord | None:
    wid = reader.string("id", max_length=5)
    number = reader.integer("number", minimum=1, maximum=MAX_SIZE * MAX_SIZE)
    direction = reader.choice("direction", DIRECTIONS)
    row = reader.integer("row", minimum=0, maximum=MAX_SIZE - 1)
    col = reader.integer("col", minimum=0, maximum=MAX_SIZE - 1)
    length = reader.integer("length", minimum=2, maximum=MAX_SIZE)
    raw_answer = reader.string("answer", max_length=MAX_SIZE)
    clue = reader.localized("clue", max_length=300)
    extra_clue = reader.localized("extraClue", required=False, max_length=300)
    fact = reader.localized("fact", required=False, max_length=1000)
    question_id = reader.string("questionId", pattern=DOC_ID_RE)
    if (
        wid is None
        or number is None
        or direction is None
        or row is None
        or col is None
        or length is None
        or raw_answer is None
        or clue is None
        or question_id is None
    ):
        return None
    word: GridWord = {
        "id": wid,
        "number": number,
        "direction": direction,
        "row": row,
        "col": col,
        "length": length,
        "answer": normalize_answer(raw_answer),
        "clue": clue,
        "questionId": question_id,
    }
    if extra_clue:
        word["extraClue"] = extra_clue
    if fact:
        word["fact"] = fact
    return word


def parse_puzzle(data: object) -> PuzzleInput:
    """Validate the request data, then the grid.

    Raises:
        InputError: Listing every field problem.
        PuzzleValidationError: Listing every grid problem (fields were fine).
    """
    reader = InputReader(data)
    puzzle_id = reader.string("id", required=False, pattern=PUZZLE_ID_RE, max_length=70)
    category_id = reader.string("categoryId", pattern=SLUG_RE, max_length=60)
    title = reader.localized("title", max_length=80)
    difficulty = reader.choice("difficulty", DIFFICULTIES)
    rows = reader.integer("rows", minimum=MIN_SIZE, maximum=MAX_SIZE)
    cols = reader.integer("cols", minimum=MIN_SIZE, maximum=MAX_SIZE)
    layout = reader.string("layout", max_length=MAX_SIZE * MAX_SIZE)
    xp_reward = reader.integer("xpReward", minimum=1, maximum=1000)
    estimated_minutes = reader.integer("estimatedMinutes", minimum=1, maximum=120)
    words = [_parse_word(item) for item in reader.children("words", min_items=2, max_items=60)]
    if puzzle_id and category_id and not puzzle_id.startswith(f"{category_id}-"):
        reader.problem(f"id {puzzle_id!r} does not belong to category {category_id!r}")
    reader.raise_if_problems()
    assert category_id and title and difficulty and rows and cols and layout
    assert xp_reward and estimated_minutes
    puzzle: PuzzleInput = {
        "categoryId": category_id,
        "title": title,
        "difficulty": difficulty,
        "rows": rows,
        "cols": cols,
        "layout": layout,
        "words": [word for word in words if word is not None],
        "xpReward": xp_reward,
        "estimatedMinutes": estimated_minutes,
    }
    if puzzle_id:
        puzzle["id"] = puzzle_id
    validate_puzzle(puzzle)
    return puzzle


def question_ids(puzzle: Grid) -> list[str]:
    """Distinct question ids of the words, in word order."""
    return list(dict.fromkeys(word.get("questionId", "") for word in puzzle["words"]))


def check_questions(puzzle: PuzzleInput, questions: Mapping[str, PscQuestion | None]) -> None:
    """Every word must use a verified question with the same answer.

    Raises:
        InputError: Listing every word with a missing, unverified or mismatched question.
    """
    problems: list[str] = []
    for word in puzzle["words"]:
        qid = word.get("questionId", "")
        question = questions.get(qid)
        if question is None:
            problems.append(f"{word['id']}: question {qid} not found")
        elif question["status"] != "verified":
            problems.append(
                f"{word['id']}: question {qid} is {question['status']} — verify it first"
            )
        elif question["answer"] != word["answer"]:
            problems.append(
                f"{word['id']}: answer {word['answer']} does not match question {qid} "
                f"({question['answer']})"
            )
    if problems:
        raise InputError(problems)


def check_editable(existing: CrosswordPuzzle) -> None:
    """Only draft and in-review puzzles may be re-saved.

    Raises:
        PreconditionError: Scheduled, published or archived.
    """
    if existing["status"] not in EDITABLE_STATUSES:
        raise PreconditionError(
            f"Puzzle is {existing['status']} and can't be edited — archive it and save a copy"
            " as a new puzzle instead"
        )


def puzzle_doc(
    puzzle: PuzzleInput,
    *,
    puzzle_id: str,
    number: int,
    questions: Mapping[str, PscQuestion | None],
    admin_uid: str,
    existing: CrosswordPuzzle | None,
    now: Timestamp,
) -> CrosswordPuzzle:
    """The puzzle document (status `draft`) with encoded answers and no plain answers."""
    words: list[CrosswordWord] = []
    for word in puzzle["words"]:
        question = questions.get(word.get("questionId", ""))
        fact = word.get("fact") or (question["fact"] if question else None)
        stored: CrosswordWord = {
            "id": word["id"],
            "number": word["number"],
            "direction": word["direction"],
            "row": word["row"],
            "col": word["col"],
            "length": word["length"],
            "clue": word["clue"],
            "fact": fact or {"en": ""},
            "answerEnc": encode_answer(word["answer"], puzzle_id, word["id"]),
            "questionId": word.get("questionId", ""),
        }
        if "extraClue" in word:
            stored["extraClue"] = word["extraClue"]
        words.append(stored)
    return {
        "categoryId": puzzle["categoryId"],
        "number": number,
        "title": puzzle["title"],
        "difficulty": puzzle["difficulty"],
        "rows": puzzle["rows"],
        "cols": puzzle["cols"],
        "layout": puzzle["layout"],
        "words": words,
        "wordCount": len(words),
        "xpReward": puzzle["xpReward"],
        "estimatedMinutes": puzzle["estimatedMinutes"],
        "status": "draft",
        "schemaVersion": SCHEMA_VERSION,
        "createdAt": existing["createdAt"] if existing else now,
        "createdBy": existing["createdBy"] if existing else admin_uid,
        "updatedAt": now,
        "updatedBy": admin_uid,
    }


def solution_doc(puzzle: Grid, *, now: Timestamp) -> CrosswordSolution:
    """The private answer key."""
    return {
        "answers": {word["id"]: word["answer"] for word in puzzle["words"]},
        "schemaVersion": SCHEMA_VERSION,
        "updatedAt": now,
    }


def question_usage(puzzle: Grid, existing: CrosswordPuzzle | None) -> QuestionUsage:
    """Questions newly used by this puzzle, and ones it no longer uses."""
    new_ids = question_ids(puzzle)
    old_ids = (
        list(dict.fromkeys(word["questionId"] for word in existing["words"])) if existing else []
    )
    return {
        "added": [qid for qid in new_ids if qid not in old_ids],
        "removed": [qid for qid in old_ids if qid not in new_ids],
    }
