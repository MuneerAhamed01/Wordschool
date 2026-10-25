"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST)."""

import inspect

import pytest

from conftest import callable_request
from crossword.collections import ADMIN_AUDIT_LOG, CROSSWORD_CATEGORIES, PSC_QUESTIONS
from crossword.errors import NotFoundError
from crossword.questions import adminSaveQuestion, save_question, verify_question
from crossword.save_category import save_category

DATA = {
    "answer": "vaikom",
    "answerDisplay": {"en": "Vaikom"},
    "clues": [{"en": "1924–25 satyagraha for temple road entry", "level": "medium"}],
    "fact": {"en": "The Vaikom Satyagraha (1924–25)."},
    "subject": "kerala_history",
    "difficulty": "medium",
    "source": {"type": "pyq", "ref": "LDC 2017, Q42"},
}


def test_create_verify_edit(emulator_db):
    created = save_question(emulator_db, "admin1", DATA)
    assert created["created"] is True
    ref = emulator_db.collection(PSC_QUESTIONS).document(created["id"])
    assert ref.get().get("answer") == "VAIKOM"

    assert verify_question(emulator_db, "admin2", {"id": created["id"]})["changed"] is True
    assert ref.get().get("status") == "verified"
    assert verify_question(emulator_db, "admin2", {"id": created["id"]})["changed"] is False

    save_question(emulator_db, "admin1", {**DATA, "id": created["id"], "answer": "Vaikkom"})
    doc = ref.get().to_dict()
    assert doc["status"] == "draft"
    assert "verifiedBy" not in doc
    assert doc["answer"] == "VAIKKOM"


def test_edit_unknown_question(emulator_db):
    with pytest.raises(NotFoundError):
        save_question(emulator_db, "admin1", {**DATA, "id": "missing"})
    with pytest.raises(NotFoundError):
        verify_question(emulator_db, "admin1", {"id": "missing"})


def _save_via_handler(data):
    return inspect.unwrap(adminSaveQuestion)(callable_request(data))


def _audit_actions(emulator_db):
    return [entry.to_dict() for entry in emulator_db.collection(ADMIN_AUDIT_LOG).stream()]


def test_new_subject_creates_hidden_category_once(emulator_db):
    data = {**DATA, "subject": "general_knowledge"}
    first = _save_via_handler(data)
    assert first["createdCategoryId"] == "general-knowledge"
    category = emulator_db.collection(CROSSWORD_CATEGORIES).document("general-knowledge").get()
    doc = category.to_dict()
    assert doc["name"] == {"en": "General Knowledge", "ml": ""}
    assert doc["isActive"] is False
    assert doc["order"] == 1000
    assert doc["publishedPuzzleCount"] == 0
    assert doc["createdBy"] == "admin1"

    second = _save_via_handler({**data, "answer": "Kochi"})
    assert second["createdCategoryId"] is None
    assert len(list(emulator_db.collection(CROSSWORD_CATEGORIES).stream())) == 1
    assert len(list(emulator_db.collection(PSC_QUESTIONS).stream())) == 2

    auto = [e for e in _audit_actions(emulator_db) if e["action"] == "crossword.autoCreateCategory"]
    assert len(auto) == 1
    assert auto[0]["targetId"] == "general-knowledge"
    assert auto[0]["payload"] == {"subject": "general_knowledge", "questionId": first["id"]}


def test_existing_category_is_left_unchanged(emulator_db):
    save_category(
        emulator_db,
        "admin0",
        {
            "id": "kerala-history",
            "name": {"en": "Kerala History"},
            "icon": "landmark",
            "color": "#6AAA64",
            "order": 10,
            "isActive": True,
        },
    )
    ref = emulator_db.collection(CROSSWORD_CATEGORIES).document("kerala-history")
    before = ref.get().to_dict()

    result = _save_via_handler(DATA)

    assert result["createdCategoryId"] is None
    assert ref.get().to_dict() == before
    actions = [e["action"] for e in _audit_actions(emulator_db)]
    assert "crossword.autoCreateCategory" not in actions
