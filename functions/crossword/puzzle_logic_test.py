from datetime import UTC, datetime

import pytest

from crossword.answer_encoding import decode_answer
from crossword.errors import InputError, PreconditionError
from crossword.puzzle_logic import (
    check_editable,
    check_questions,
    parse_puzzle,
    puzzle_doc,
    puzzle_id_for,
    question_usage,
    solution_doc,
)
from crossword.validate_puzzle import PuzzleValidationError

NOW = datetime(2026, 10, 23, tzinfo=UTC)


def _doc(puzzle, questions, puzzle_id="kerala-history-0012"):
    return puzzle_doc(
        puzzle,
        puzzle_id=puzzle_id,
        number=12,
        questions=questions,
        admin_uid="admin1",
        existing=None,
        now=NOW,
    )


def test_puzzle_id_for():
    assert puzzle_id_for("kerala-history", 12) == "kerala-history-0012"


def test_parses_example(example_puzzle_input):
    puzzle = parse_puzzle(example_puzzle_input)
    assert len(puzzle["words"]) == 7
    assert "id" not in puzzle


def test_normalizes_answers(example_puzzle_input):
    example_puzzle_input["words"][6]["answer"] = "E.M.S."
    assert parse_puzzle(example_puzzle_input)["words"][6]["answer"] == "EMS"


def test_field_problems_listed_before_grid_check(example_puzzle_input):
    example_puzzle_input["xpReward"] = 0
    example_puzzle_input["words"][0]["row"] = "0"
    del example_puzzle_input["words"][1]["questionId"]
    with pytest.raises(InputError) as error:
        parse_puzzle(example_puzzle_input)
    assert not isinstance(error.value, PuzzleValidationError)
    assert error.value.problems == [
        "xpReward must be at least 1",
        "words[0].row must be a whole number",
        "words[1].questionId is required",
    ]


def test_invalid_grid_is_rejected_with_readable_problems(example_puzzle_input):
    example_puzzle_input["words"][2]["answer"] = "VAIXOM"
    with pytest.raises(PuzzleValidationError) as error:
        parse_puzzle(example_puzzle_input)
    assert error.value.problems == [
        "5A: letter 'K' at row 5, col 2 clashes with 'X' from 2D",
    ]


def test_id_must_match_category(example_puzzle_input):
    example_puzzle_input["id"] = "kerala-geography-0001"
    with pytest.raises(InputError) as error:
        parse_puzzle(example_puzzle_input)
    assert "does not belong to category" in error.value.problems[0]


def test_verified_questions_pass(example_puzzle_input, example_questions):
    check_questions(parse_puzzle(example_puzzle_input), example_questions)


def test_rejects_unverified_missing_and_mismatched_questions(
    example_puzzle_input, example_questions
):
    example_questions["q-muziris"]["status"] = "draft"
    del example_questions["q-gama"]
    example_questions["q-ems"]["answer"] = "EMSN"
    with pytest.raises(InputError) as error:
        check_questions(parse_puzzle(example_puzzle_input), example_questions)
    assert error.value.problems == [
        "1A: question q-muziris is draft — verify it first",
        "3D: question q-gama not found",
        "6A: answer EMS does not match question q-ems (EMSN)",
    ]


@pytest.mark.parametrize("status", ["draft", "in_review"])
def test_draft_and_in_review_are_editable(status):
    check_editable({"status": status})


@pytest.mark.parametrize("status", ["scheduled", "published", "archived"])
def test_refuses_to_resave_live_puzzles(status):
    with pytest.raises(PreconditionError) as error:
        check_editable({"status": status})
    assert "archive it and save a copy" in str(error.value)


def test_puzzle_doc_encodes_answers_and_hides_plain_ones(example_puzzle_input, example_questions):
    puzzle = parse_puzzle(example_puzzle_input)
    doc = _doc(puzzle, example_questions)
    assert doc["status"] == "draft"
    assert doc["wordCount"] == 7
    assert "answer" not in str(doc["words"]).replace("answerEnc", "")
    by_id = {word["id"]: word for word in doc["words"]}
    assert by_id["2D"]["answerEnc"] == "PSQ7KiMs"
    assert decode_answer(by_id["1A"]["answerEnc"], "kerala-history-0012", "1A") == "MUZIRIS"


def test_fact_defaults_to_the_question(example_puzzle_input, example_questions):
    del example_puzzle_input["words"][0]["fact"]
    example_questions["q-muziris"]["fact"] = {"en": "From the question bank"}
    doc = _doc(parse_puzzle(example_puzzle_input), example_questions)
    assert doc["words"][0]["fact"] == {"en": "From the question bank"}


def test_solution_doc(example_puzzle_input):
    answers = solution_doc(parse_puzzle(example_puzzle_input), now=NOW)["answers"]
    assert answers["2D"] == "VAIKOM"
    assert len(answers) == 7


def test_question_usage(example_puzzle_input, example_questions):
    puzzle = parse_puzzle(example_puzzle_input)
    assert question_usage(puzzle, None)["added"] == list(example_questions)

    existing = _doc(puzzle, example_questions)
    existing["words"][0]["questionId"] = "q-old"
    assert question_usage(puzzle, existing) == {"added": ["q-muziris"], "removed": ["q-old"]}
