"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST)."""

import inspect
from datetime import UTC, datetime, timedelta

import pytest
from firebase_functions import https_fn

from conftest import callable_request
from crossword.admin_reads import (
    adminGetPuzzle,
    adminGetQuestion,
    adminListCategories,
    adminListPuzzles,
    adminListQuestions,
    get_puzzle,
    get_question,
    list_puzzles,
    list_questions,
)
from crossword.collections import CROSSWORD_CATEGORIES, PSC_QUESTIONS
from crossword.errors import NotFoundError
from crossword.save_puzzle import save_puzzle

NOW = datetime(2026, 10, 23, tzinfo=UTC)


def _seed_questions(db, count):
    for i in range(count):
        db.collection(PSC_QUESTIONS).document(f"q{i:02d}").set(
            {
                "answer": "VAIKOM",
                "subject": "kerala_history" if i % 2 == 0 else "geography",
                "status": "verified" if i < 3 else "draft",
                "updatedAt": NOW + timedelta(minutes=i),
            }
        )


def test_pages_questions_newest_first(emulator_db):
    _seed_questions(emulator_db, 5)
    first = list_questions(emulator_db, {"limit": 2})
    assert [q["id"] for q in first["questions"]] == ["q04", "q03"]
    assert first["questions"][0]["updatedAt"].startswith("2026-10-23T00:04")
    second = list_questions(emulator_db, {"limit": 2, "startAfterId": first["nextStartAfterId"]})
    assert [q["id"] for q in second["questions"]] == ["q02", "q01"]
    last = list_questions(emulator_db, {"limit": 2, "startAfterId": second["nextStartAfterId"]})
    assert [q["id"] for q in last["questions"]] == ["q00"]
    assert last["nextStartAfterId"] is None


def test_filters_questions_by_subject_and_status(emulator_db):
    _seed_questions(emulator_db, 5)
    by_subject = list_questions(emulator_db, {"subject": "kerala_history"})
    assert [q["id"] for q in by_subject["questions"]] == ["q04", "q02", "q00"]
    both = list_questions(emulator_db, {"subject": "kerala_history", "status": "verified"})
    assert [q["id"] for q in both["questions"]] == ["q02", "q00"]
    by_status = list_questions(emulator_db, {"status": "draft"})
    assert [q["id"] for q in by_status["questions"]] == ["q04", "q03"]


def test_unknown_cursor(emulator_db):
    with pytest.raises(NotFoundError):
        list_questions(emulator_db, {"startAfterId": "missing"})


def test_get_question(emulator_db):
    _seed_questions(emulator_db, 2)
    question = get_question(emulator_db, {"id": "q01"})["question"]
    assert question["id"] == "q01"
    assert question["subject"] == "geography"
    assert question["updatedAt"].startswith("2026-10-23T00:01")
    with pytest.raises(NotFoundError):
        get_question(emulator_db, {"id": "missing"})


def test_open_puzzle_with_answers(seeded_example, example_puzzle_input):
    saved = save_puzzle(seeded_example, "admin1", example_puzzle_input, now=NOW)

    puzzle = get_puzzle(seeded_example, {"puzzleId": saved["id"]})["puzzle"]

    assert puzzle["id"] == saved["id"]
    assert puzzle["status"] == "draft"
    answers = {w["id"]: w["answer"] for w in example_puzzle_input["words"]}
    assert {w["id"]: w["answer"] for w in puzzle["words"]} == answers
    with pytest.raises(NotFoundError):
        get_puzzle(seeded_example, {"puzzleId": "kerala-history-0999"})


def test_lists_puzzles_without_grid(seeded_example, example_puzzle_input):
    first = save_puzzle(seeded_example, "admin1", example_puzzle_input, now=NOW)
    second = save_puzzle(seeded_example, "admin1", example_puzzle_input, now=NOW)

    page = list_puzzles(seeded_example, {"categoryId": "kerala-history", "limit": 1})
    assert [p["id"] for p in page["puzzles"]] == [second["id"]]
    assert "words" not in page["puzzles"][0]
    rest = list_puzzles(
        seeded_example,
        {
            "categoryId": "kerala-history",
            "status": "draft",
            "startAfterId": page["nextStartAfterId"],
        },
    )
    assert [p["id"] for p in rest["puzzles"]] == [first["id"]]
    assert list_puzzles(seeded_example, {"categoryId": "geography"})["puzzles"] == []


def test_lists_all_categories_in_order(emulator_db):
    for slug, order, active in [("b", 20, False), ("a", 10, True)]:
        emulator_db.collection(CROSSWORD_CATEGORIES).document(slug).set(
            {"order": order, "isActive": active, "updatedAt": NOW}
        )
    result = inspect.unwrap(adminListCategories)(callable_request(None))
    assert [c["id"] for c in result["categories"]] == ["a", "b"]


@pytest.mark.parametrize(
    "handler, data",
    [
        (adminListQuestions, {}),
        (adminListPuzzles, {"categoryId": "kerala-history"}),
        (adminGetPuzzle, {"puzzleId": "kerala-history-0001"}),
        (adminGetQuestion, {"id": "q00"}),
        (adminListCategories, None),
    ],
)
def test_players_are_refused(emulator_db, handler, data):
    with pytest.raises(https_fn.HttpsError) as error:
        inspect.unwrap(handler)(callable_request(data, uid="player1", admin=False))
    assert error.value.code == https_fn.FunctionsErrorCode.PERMISSION_DENIED
    with pytest.raises(https_fn.HttpsError) as error:
        inspect.unwrap(handler)(callable_request(data, uid=None))
    assert error.value.code == https_fn.FunctionsErrorCode.UNAUTHENTICATED
