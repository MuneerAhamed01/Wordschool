import json

import pytest

from crossword.hint_penalties import (
    DEFAULT_HINT_PENALTIES,
    parse_hint_penalties,
    penalties_from_template,
)


def _template(value, *, grouped=False):
    parameters = {"crossword_hint_penalties": {"defaultValue": {"value": value}}}
    if grouped:
        return {"parameterGroups": {"Crossword": {"parameters": parameters}}}
    return {"parameters": parameters}


def test_parses_like_the_app():
    assert parse_hint_penalties('{"letter":2,"word":8}') == {"letter": 2, "word": 8}
    assert parse_hint_penalties('{"letter":0,"word":0}') == {"letter": 0, "word": 0}


@pytest.mark.parametrize(
    "raw",
    [
        None,
        "",
        "not json",
        "[1, 2]",
        '{"letter":5}',
        '{"letter":-1,"word":15}',
        '{"letter":5.5,"word":15}',
        '{"letter":true,"word":15}',
        5,
    ],
)
def test_bad_values_fall_back(raw):
    assert parse_hint_penalties(raw) == DEFAULT_HINT_PENALTIES


def test_reads_default_value_from_template():
    value = json.dumps({"letter": 3, "word": 9})
    assert penalties_from_template(_template(value)) == {"letter": 3, "word": 9}
    assert penalties_from_template(_template(value, grouped=True)) == {"letter": 3, "word": 9}


@pytest.mark.parametrize(
    "template",
    [
        None,
        {},
        {"parameters": {}},
        {"parameters": {"crossword_hint_penalties": {}}},
        {"parameters": {"crossword_hint_penalties": {"defaultValue": {"useInAppDefault": True}}}},
    ],
)
def test_missing_parameter_falls_back(template):
    assert penalties_from_template(template) == DEFAULT_HINT_PENALTIES
