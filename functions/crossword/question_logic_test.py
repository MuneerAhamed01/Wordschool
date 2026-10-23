from datetime import UTC, datetime

import pytest

from crossword.errors import InputError, PreconditionError
from crossword.question_logic import (
    normalize_answer,
    parse_question,
    question_doc,
    verify_updates,
)

NOW = datetime(2026, 10, 23, tzinfo=UTC)


def _input(**changes):
    data = {
        "answer": "Vaikom",
        "answerDisplay": {"en": "Vaikom", "ml": "വൈക്കം"},
        "clues": [{"en": "1924–25 satyagraha for temple road entry", "level": "medium"}],
        "fact": {"en": "The Vaikom Satyagraha (1924–25) protested a ban on using temple roads."},
        "subject": "kerala_history",
        "topic": "renaissance",
        "examTags": ["ldc", "lgs"],
        "difficulty": "medium",
        "source": {"type": "pyq", "ref": "LDC 2017, Q42"},
    }
    data.update(changes)
    return {key: value for key, value in data.items() if value is not None}


def _problems(data):
    with pytest.raises(InputError) as error:
        parse_question(data)
    return error.value.problems


def _doc(status="draft", **changes):
    doc = question_doc(parse_question(_input()), admin_uid="a0", existing=None, now=NOW)
    doc["status"] = status
    doc.update(changes)
    return doc


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("Vaikom", "VAIKOM"),
        ("vasco da gama", "VASCODAGAMA"),
        ("E. M. S.", "EMS"),
        ("Thiru-vananthapuram", "THIRUVANANTHAPURAM"),
        (" kappad\t", "KAPPAD"),
    ],
)
def test_normalize_answer(raw, expected):
    assert normalize_answer(raw) == expected


def test_parse_normalizes_answer():
    question = parse_question(_input(answer="E.M.S."))
    assert question["answer"] == "EMS"
    assert "id" not in question


@pytest.mark.parametrize("answer", ["A", "Kerala1", "O'Neil", "കേരളം", "..."])
def test_rejects_answers_outside_a_to_z(answer):
    assert len(_problems(_input(answer=answer))) == 1


def test_missing_source_rejected():
    assert _problems(_input(source=None)) == ["source is required (where the fact was checked)"]


def test_source_needs_type_and_ref():
    assert _problems(_input(source={"type": "rumour"})) == [
        "source.type must be one of pyq, book, website, other",
        "source.ref is required",
    ]


def test_needs_at_least_one_clue():
    assert _problems(_input(clues=[])) == ["clues must have 1–5 items, got 0"]


def test_new_question_is_draft_and_unused():
    doc = question_doc(parse_question(_input()), admin_uid="admin1", existing=None, now=NOW)
    assert doc["status"] == "draft"
    assert doc["usedInPuzzles"] == []
    assert doc["createdBy"] == "admin1"


def test_re_edit_resets_verified_to_draft():
    existing = _doc(
        "verified", verifiedBy="a0", verifiedAt=NOW, usedInPuzzles=["kerala-history-0012"]
    )
    doc = question_doc(
        parse_question(_input(id="q1", answer="Vaikkom")),
        admin_uid="admin1",
        existing=existing,
        now=NOW,
    )
    assert doc["status"] == "draft"
    assert "verifiedBy" not in doc
    assert "verifiedAt" not in doc
    assert doc["usedInPuzzles"] == ["kerala-history-0012"]
    assert doc["answer"] == "VAIKKOM"
    assert doc["createdBy"] == "a0"


def test_retired_question_cannot_be_edited():
    with pytest.raises(PreconditionError):
        question_doc(parse_question(_input()), admin_uid="a", existing=_doc("retired"), now=NOW)


def test_verify_draft():
    assert verify_updates(_doc(), admin_uid="admin2", now=NOW) == {
        "status": "verified",
        "verifiedBy": "admin2",
        "verifiedAt": NOW,
        "updatedAt": NOW,
        "updatedBy": "admin2",
    }


def test_verify_is_idempotent():
    assert verify_updates(_doc("verified"), admin_uid="admin2", now=NOW) is None


def test_verify_refuses_retired_and_placeholder_sources():
    with pytest.raises(PreconditionError):
        verify_updates(_doc("retired"), admin_uid="a", now=NOW)
    with pytest.raises(InputError):
        verify_updates(_doc(source={"type": "book", "ref": "TODO: page"}), admin_uid="a", now=NOW)
