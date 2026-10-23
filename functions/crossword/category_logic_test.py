from datetime import UTC, datetime

import pytest

from crossword.category_logic import category_doc, parse_category
from crossword.errors import InputError

NOW = datetime(2026, 10, 23, tzinfo=UTC)


def _input(**changes):
    data = {
        "id": "kerala-history",
        "name": {"en": "Kerala History", "ml": "കേരള ചരിത്രം"},
        "description": {"en": "Kings, ports and the renaissance"},
        "icon": "landmark",
        "color": "#6aaa64",
        "order": 10,
        "isActive": True,
    }
    data.update(changes)
    return {key: value for key, value in data.items() if value is not None}


def _problems(data):
    with pytest.raises(InputError) as error:
        parse_category(data)
    return error.value.problems


def test_parses_valid_input():
    category = parse_category(_input())
    assert category["id"] == "kerala-history"
    assert category["color"] == "#6AAA64"
    assert category["description"] == {"en": "Kings, ports and the renaissance"}


@pytest.mark.parametrize("slug", ["Kerala-History", "kerala history", "kerala_history", "കേരളം"])
def test_rejects_bad_slugs(slug):
    assert _problems(_input(id=slug)) == [f"id {slug!r} must match [a-z0-9-]+"]


def test_requires_name_en():
    assert _problems(_input(name={"ml": "കേരള ചരിത്രം"})) == ["name.en is required"]
    assert _problems(_input(name=None)) == ["name.en is required"]


@pytest.mark.parametrize("order", ["10", 1.5, True, None])
def test_order_must_be_an_int(order):
    assert len(_problems(_input(order=order))) == 1


def test_lists_every_problem():
    problems = _problems({"id": "Bad Slug", "color": "green"})
    assert len(problems) == 6


def test_new_category_doc():
    doc = category_doc(parse_category(_input()), admin_uid="admin1", existing=None, now=NOW)
    assert doc["publishedPuzzleCount"] == 0
    assert doc["lastPuzzleNumber"] == 0
    assert doc["createdBy"] == doc["updatedBy"] == "admin1"
    assert doc["createdAt"] == doc["updatedAt"] == NOW
    assert doc["schemaVersion"] == 1


def test_edit_keeps_counters_and_creation_fields():
    created = datetime(2026, 1, 1, tzinfo=UTC)
    existing = category_doc(parse_category(_input()), admin_uid="a0", existing=None, now=created)
    existing["publishedPuzzleCount"] = 7
    existing["lastPuzzleNumber"] = 12
    doc = category_doc(
        parse_category(_input(description=None, order=20)),
        admin_uid="admin1",
        existing=existing,
        now=NOW,
    )
    assert doc["publishedPuzzleCount"] == 7
    assert doc["lastPuzzleNumber"] == 12
    assert doc["createdAt"] == created
    assert doc["createdBy"] == "a0"
    assert doc["updatedBy"] == "admin1"
    assert doc["order"] == 20
    assert "description" not in doc
