import re

import pytest

from crossword.errors import InputError
from crossword.input_reader import InputReader


def test_reads_valid_fields():
    reader = InputReader(
        {
            "id": " kerala-history ",
            "order": 10,
            "isActive": True,
            "difficulty": "easy",
            "name": {"en": "Kerala History", "ml": "കേരള ചരിത്രം"},
            "tags": ["ldc", " lgs "],
        }
    )
    assert reader.string("id", pattern=re.compile(r"[a-z-]+")) == "kerala-history"
    assert reader.integer("order", minimum=0) == 10
    assert reader.boolean("isActive") is True
    assert reader.choice("difficulty", ("easy", "hard")) == "easy"
    assert reader.localized("name") == {"en": "Kerala History", "ml": "കേരള ചരിത്രം"}
    assert reader.string_list("tags") == ["ldc", "lgs"]
    reader.raise_if_problems()


def test_collects_every_problem():
    reader = InputReader({"order": "10", "isActive": 1, "name": {"ml": "x"}, "difficulty": "x"})
    reader.string("id")
    reader.integer("order")
    reader.boolean("isActive")
    reader.localized("name")
    reader.choice("difficulty", ("easy", "hard"))
    with pytest.raises(InputError) as error:
        reader.raise_if_problems()
    assert error.value.problems == [
        "id is required",
        "order must be a whole number",
        "isActive must be true or false",
        "name.en is required",
        "difficulty must be one of easy, hard",
    ]


def test_optional_fields_may_be_missing():
    reader = InputReader({})
    assert reader.string("note", required=False) is None
    assert reader.localized("extraClue", required=False) is None
    assert reader.integer("limit", required=False) is None
    reader.raise_if_problems()


def test_integer_bounds_and_bools():
    reader = InputReader({"a": True, "b": -1, "c": 5.0, "d": 101})
    assert reader.integer("a") is None
    assert reader.integer("b", minimum=0) is None
    assert reader.integer("c") == 5
    assert reader.integer("d", maximum=100) is None
    assert len(reader.problems) == 3


def test_children_use_indexed_paths():
    reader = InputReader({"words": [{"id": "1A"}, {"id": 3}, "x"]})
    items = reader.children("words")
    assert [item.string("id") for item in items] == ["1A", None, None]
    assert reader.problems == ["words[2] must be an object", "words[1].id must be a string"]


def test_non_object_data():
    reader = InputReader(None)
    assert reader.problems == ["request data must be an object"]


def test_blank_and_too_long_strings():
    reader = InputReader({"a": "   ", "b": "x" * 11})
    assert reader.string("a") is None
    assert reader.string("b", max_length=10) is None
    assert reader.problems == ["a is required", "b must be at most 10 characters"]
