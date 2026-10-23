"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST)."""

import pytest

from crossword.collections import PSC_QUESTIONS
from crossword.errors import NotFoundError
from crossword.questions import save_question, verify_question

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
