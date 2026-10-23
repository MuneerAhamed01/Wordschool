from datetime import UTC, datetime

import pytest

from crossword.admin_read_logic import (
    doc_json,
    parse_list_puzzles,
    parse_list_questions,
    parse_puzzle_id,
    puzzle_summary_json,
    puzzle_with_answers_json,
)
from crossword.errors import InputError

NOW = datetime(2026, 10, 23, tzinfo=UTC)


def test_list_questions_defaults_and_filters():
    assert parse_list_questions(None) == {"limit": 20}
    assert parse_list_questions(
        {"subject": "kerala_history", "status": "verified", "limit": 5, "startAfterId": "q-1"}
    ) == {"subject": "kerala_history", "status": "verified", "limit": 5, "startAfterId": "q-1"}


def test_list_questions_rejects_bad_values():
    with pytest.raises(InputError) as error:
        parse_list_questions({"subject": "Kerala History", "status": "published", "limit": 0})
    assert len(error.value.problems) == 3


def test_list_puzzles_needs_category():
    assert parse_list_puzzles({"categoryId": "kerala-history"}) == {
        "categoryId": "kerala-history",
        "limit": 20,
    }
    assert parse_list_puzzles(
        {"categoryId": "kerala-history", "status": "draft", "startAfterId": "kerala-history-0003"}
    ) == {
        "categoryId": "kerala-history",
        "status": "draft",
        "limit": 20,
        "startAfterId": "kerala-history-0003",
    }
    with pytest.raises(InputError):
        parse_list_puzzles({})


def test_puzzle_id():
    assert parse_puzzle_id({"puzzleId": "kerala-history-0001"}) == "kerala-history-0001"
    with pytest.raises(InputError):
        parse_puzzle_id({"puzzleId": "../solutions"})


def test_doc_json_converts_nested_timestamps():
    assert doc_json("q1", {"verifiedAt": NOW, "source": {"at": NOW}, "tags": [NOW]}) == {
        "id": "q1",
        "verifiedAt": "2026-10-23T00:00:00+00:00",
        "source": {"at": "2026-10-23T00:00:00+00:00"},
        "tags": ["2026-10-23T00:00:00+00:00"],
    }


def _puzzle():
    return {
        "categoryId": "kerala-history",
        "number": 1,
        "status": "draft",
        "layout": "AB",
        "words": [{"id": "1A", "answerEnc": "x"}, {"id": "1D", "answerEnc": "y"}],
        "updatedAt": NOW,
    }


def test_puzzle_summary_drops_grid():
    summary = puzzle_summary_json("kerala-history-0001", _puzzle())
    assert "words" not in summary and "layout" not in summary
    assert summary["id"] == "kerala-history-0001"
    assert summary["updatedAt"] == "2026-10-23T00:00:00+00:00"


def test_puzzle_with_answers_adds_plain_answers():
    result = puzzle_with_answers_json("kerala-history-0001", _puzzle(), {"1A": "VAIKOM"})
    assert result["words"] == [
        {"id": "1A", "answerEnc": "x", "answer": "VAIKOM"},
        {"id": "1D", "answerEnc": "y", "answer": ""},
    ]
    assert result["layout"] == "AB"
