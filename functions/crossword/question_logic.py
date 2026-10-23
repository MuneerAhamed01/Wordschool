"""Pure logic for `adminSaveQuestion` and `adminVerifyQuestion` (CW-016)."""

import re
from typing import NotRequired, TypedDict

from crossword.errors import InputError, PreconditionError
from crossword.input_reader import InputReader
from crossword.types import (
    CLUE_LEVELS,
    DIFFICULTIES,
    SCHEMA_VERSION,
    SOURCE_TYPES,
    Difficulty,
    LocalizedText,
    PscQuestion,
    QuestionClue,
    QuestionSource,
    Timestamp,
)
from crossword.validate_puzzle import ANSWER_RE

DOC_ID_RE = re.compile(r"[A-Za-z0-9_-]{1,100}")
SNAKE_RE = re.compile(r"[a-z0-9_]+")
_STRIPPED_FROM_ANSWERS = re.compile(r"[\s.\-]")


class QuestionInput(TypedDict):
    """Validated `adminSaveQuestion` input (`id` absent = new question)."""

    id: NotRequired[str]
    answer: str
    answerDisplay: LocalizedText
    clues: list[QuestionClue]
    fact: LocalizedText
    subject: str
    topic: NotRequired[str]
    examTags: list[str]
    difficulty: Difficulty
    source: QuestionSource


def normalize_answer(raw: str) -> str:
    """Uppercase and drop spaces, hyphens and dots: `"Vasco da-Gama."` → `"VASCODAGAMA"`."""
    return _STRIPPED_FROM_ANSWERS.sub("", raw).upper()


def parse_question(data: object) -> QuestionInput:
    """Validate the request data and normalize the answer.

    Raises:
        InputError: Listing every problem.
    """
    reader = InputReader(data)
    question_id = reader.string("id", required=False, pattern=DOC_ID_RE)
    raw_answer = reader.string("answer", max_length=60)
    answer = normalize_answer(raw_answer) if raw_answer is not None else None
    if answer is not None and not ANSWER_RE.fullmatch(answer):
        reader.problem(f"answer {answer!r} must be 2+ letters A-Z after removing spaces/-/.")
    answer_display = reader.localized("answerDisplay", max_length=60)
    clues: list[QuestionClue] = []
    for clue_reader in reader.children("clues", min_items=1, max_items=5):
        en = clue_reader.string("en", max_length=300)
        ml = clue_reader.string("ml", required=False, max_length=300)
        level = clue_reader.choice("level", CLUE_LEVELS)
        if en is not None and level is not None:
            clue: QuestionClue = {"en": en, "level": level}
            if ml:
                clue["ml"] = ml
            clues.append(clue)
    fact = reader.localized("fact", max_length=1000)
    subject = reader.string("subject", pattern=SNAKE_RE, max_length=60)
    topic = reader.string("topic", required=False, pattern=SNAKE_RE, max_length=60)
    exam_tags = reader.string_list("examTags", required=False, pattern=SNAKE_RE) or []
    difficulty = reader.choice("difficulty", DIFFICULTIES)
    source: QuestionSource | None = None
    if not reader.has("source"):
        reader.problem("source is required (where the fact was checked)")
    else:
        source_reader = reader.child("source")
        source_type = source_reader.choice("type", SOURCE_TYPES)
        ref = source_reader.string("ref", max_length=300)
        if source_type is not None and ref is not None:
            source = {"type": source_type, "ref": ref}
    reader.raise_if_problems()
    assert answer and answer_display and fact and subject and difficulty and source
    question: QuestionInput = {
        "answer": answer,
        "answerDisplay": answer_display,
        "clues": clues,
        "fact": fact,
        "subject": subject,
        "examTags": exam_tags,
        "difficulty": difficulty,
        "source": source,
    }
    if question_id:
        question["id"] = question_id
    if topic:
        question["topic"] = topic
    return question


def question_doc(
    question: QuestionInput,
    *,
    admin_uid: str,
    existing: PscQuestion | None,
    now: Timestamp,
) -> PscQuestion:
    """The full document to write. Any edit sets the status back to `draft`.

    Raises:
        PreconditionError: The question is retired.
    """
    if existing is not None and existing["status"] == "retired":
        raise PreconditionError("Retired questions can't be edited")
    doc: PscQuestion = {
        "answer": question["answer"],
        "answerDisplay": question["answerDisplay"],
        "clues": question["clues"],
        "fact": question["fact"],
        "subject": question["subject"],
        "examTags": question["examTags"],
        "difficulty": question["difficulty"],
        "source": question["source"],
        "status": "draft",
        "usedInPuzzles": existing["usedInPuzzles"] if existing else [],
        "schemaVersion": SCHEMA_VERSION,
        "createdAt": existing["createdAt"] if existing else now,
        "createdBy": existing["createdBy"] if existing else admin_uid,
        "updatedAt": now,
        "updatedBy": admin_uid,
    }
    if "topic" in question:
        doc["topic"] = question["topic"]
    return doc


def parse_question_id(data: object) -> str:
    """Read `{id}` for `adminVerifyQuestion`.

    Raises:
        InputError: Missing or malformed id.
    """
    reader = InputReader(data)
    question_id = reader.string("id", pattern=DOC_ID_RE)
    reader.raise_if_problems()
    assert question_id
    return question_id


def verify_updates(
    existing: PscQuestion, *, admin_uid: str, now: Timestamp
) -> dict[str, object] | None:
    """Fields to update to verify a question; `None` when it is already verified.

    Raises:
        PreconditionError: The question is retired or its source is still a placeholder.
    """
    if existing["status"] == "verified":
        return None
    if existing["status"] == "retired":
        raise PreconditionError("Retired questions can't be verified")
    if existing["source"]["ref"].upper().startswith("TODO"):
        raise InputError(["source.ref is still a TODO — add the real reference before verifying"])
    return {
        "status": "verified",
        "verifiedBy": admin_uid,
        "verifiedAt": now,
        "updatedAt": now,
        "updatedBy": admin_uid,
    }
