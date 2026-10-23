"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST)."""

import pytest

from crossword.collections import (
    CROSSWORD_CATEGORIES,
    CROSSWORD_PUZZLES,
    CROSSWORD_SOLUTIONS,
    PSC_QUESTIONS,
)
from crossword.errors import InputError, NotFoundError, PreconditionError
from crossword.save_puzzle import save_puzzle


def test_new_puzzles_get_next_number(seeded_example, example_puzzle_input):
    db = seeded_example
    first = save_puzzle(db, "admin1", example_puzzle_input)
    second = save_puzzle(db, "admin1", example_puzzle_input)

    assert first == {"id": "kerala-history-0001", "number": 1, "created": True, "status": "draft"}
    assert second["id"] == "kerala-history-0002"
    category = db.collection(CROSSWORD_CATEGORIES).document("kerala-history").get()
    assert category.get("lastPuzzleNumber") == 2
    solution = db.collection(CROSSWORD_SOLUTIONS).document("kerala-history-0001").get()
    assert solution.get("answers")["2D"] == "VAIKOM"
    question = db.collection(PSC_QUESTIONS).document("q-vaikom").get()
    assert question.get("usedInPuzzles") == ["kerala-history-0001", "kerala-history-0002"]
    puzzle = db.collection(CROSSWORD_PUZZLES).document("kerala-history-0001").get().to_dict()
    assert puzzle["status"] == "draft"
    assert all("answer" not in word for word in puzzle["words"])


def test_edit_keeps_number_and_refuses_published(seeded_example, example_puzzle_input):
    db = seeded_example
    saved = save_puzzle(db, "admin1", example_puzzle_input)
    example_puzzle_input["id"] = saved["id"]
    example_puzzle_input["title"] = {"en": "Renamed"}

    edited = save_puzzle(db, "admin2", example_puzzle_input)

    assert edited == {**saved, "created": False}
    ref = db.collection(CROSSWORD_PUZZLES).document(saved["id"])
    assert ref.get().get("title") == {"en": "Renamed"}
    assert ref.get().get("createdBy") == "admin1"

    ref.update({"status": "published"})
    with pytest.raises(PreconditionError):
        save_puzzle(db, "admin2", example_puzzle_input)


def test_rejects_unverified_question_without_writing(seeded_example, example_puzzle_input):
    db = seeded_example
    db.collection(PSC_QUESTIONS).document("q-gama").update({"status": "draft"})
    with pytest.raises(InputError) as error:
        save_puzzle(db, "admin1", example_puzzle_input)
    assert error.value.problems == ["3D: question q-gama is draft — verify it first"]
    assert list(db.collection(CROSSWORD_PUZZLES).stream()) == []
    category = db.collection(CROSSWORD_CATEGORIES).document("kerala-history").get()
    assert category.get("lastPuzzleNumber") == 0


def test_unknown_category_or_puzzle(seeded_example, example_puzzle_input):
    with pytest.raises(NotFoundError):
        save_puzzle(seeded_example, "admin1", {**example_puzzle_input, "categoryId": "nope"})
    with pytest.raises(NotFoundError):
        save_puzzle(seeded_example, "admin1", {**example_puzzle_input, "id": "kerala-history-0099"})
