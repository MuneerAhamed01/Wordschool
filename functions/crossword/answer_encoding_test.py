import json
from pathlib import Path

import pytest

from crossword.answer_encoding import decode_answer, encode_answer

_FIXTURES = Path(__file__).parents[2] / "test" / "fixtures" / "answer_encoding.json"
CASES = json.loads(_FIXTURES.read_text())["cases"]


def test_design_doc_fixture():
    assert encode_answer("VAIKOM", "kerala-history-0012", "2D") == "PSQ7KiMs"


@pytest.mark.parametrize("case", CASES, ids=[case["answer"] for case in CASES])
def test_matches_shared_fixtures(case):
    assert encode_answer(case["answer"], case["puzzleId"], case["wordId"]) == case["answerEnc"]
    assert decode_answer(case["answerEnc"], case["puzzleId"], case["wordId"]) == case["answer"]
