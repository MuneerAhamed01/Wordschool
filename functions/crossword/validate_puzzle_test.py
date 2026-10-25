import copy
import json
from pathlib import Path

import pytest

from crossword.validate_puzzle import (
    PuzzleValidationError,
    implied_numbers,
    puzzle_problems,
    validate_puzzle,
)

EXAMPLE = (
    Path(__file__).parents[2]
    / ".claude/skills/crossword-content/examples/kerala-history-0012.puzzle.json"
)
# Made by the admin panel's auto-create generator (CW-038); the Dart test
# test/features/admin/puzzles/domain/utils/auto_puzzle_test.dart keeps it current.
GENERATED = Path(__file__).parents[2] / "test/fixtures/admin/auto_puzzle.puzzle.json"


def _word(wid, number, direction, row, col, answer):
    return {
        "id": wid,
        "number": number,
        "direction": direction,
        "row": row,
        "col": col,
        "length": len(answer),
        "answer": answer,
        "clue": {"en": "clue"},
    }


def _grid():
    # C A T
    # O # O
    # B E E
    return {
        "rows": 3,
        "cols": 3,
        "layout": "....#....",
        "words": [
            _word("1A", 1, "across", 0, 0, "CAT"),
            _word("1D", 1, "down", 0, 0, "COB"),
            _word("2D", 2, "down", 0, 2, "TOE"),
            _word("3A", 3, "across", 2, 0, "BEE"),
        ],
    }


def _with_word(index, **changes):
    grid = _grid()
    grid["words"][index].update(changes)
    return grid


def _problems(grid):
    with pytest.raises(PuzzleValidationError) as error:
        validate_puzzle(grid)
    return error.value.problems


def test_example_puzzle_passes():
    validate_puzzle(json.loads(EXAMPLE.read_text()))


def test_generated_puzzle_passes() -> None:
    validate_puzzle(json.loads(GENERATED.read_text()))


def test_small_grid_passes():
    validate_puzzle(_grid())


def test_implied_numbers_standard_order():
    assert implied_numbers("....#....", 3, 3) == {(0, 0): 1, (0, 2): 2, (2, 0): 3}


@pytest.mark.parametrize(
    ("changes", "expected"),
    [
        ({"rows": 2}, "rows and cols must be between 3 and 15"),
        ({"cols": 16}, "rows and cols must be between 3 and 15"),
        ({"layout": "....#..."}, "layout has 8 chars, expected rows*cols = 9"),
        ({"layout": "....X...."}, "layout may only contain '.' (letter) and '#' (block)"),
        ({"words": []}, "puzzle has no words"),
    ],
)
def test_grid_shape_problems(changes, expected):
    grid = _grid()
    grid.update(changes)
    assert _problems(grid) == [expected]


@pytest.mark.parametrize(
    ("index", "changes", "expected"),
    [
        (0, {"answer": "cat"}, "1A: answer 'cat' must be 2+ uppercase letters A-Z"),
        (0, {"answer": "C"}, "1A: answer 'C' must be 2+ uppercase letters A-Z"),
        (0, {"answer": "CA-T"}, "1A: answer 'CA-T' must be 2+ uppercase letters A-Z"),
        (0, {"length": 4}, "1A: length 4 != len(answer) 3"),
        (0, {"id": "1D"}, "1D: duplicate word id"),
        (3, {"id": "3D"}, "3D: id should be 3A (number + A/D)"),
        (3, {"col": 1, "answer": "EE", "length": 2}, "3A: does not fill its whole run"),
        (0, {"answer": "CA", "length": 2}, "1A: does not fill its whole run"),
        (0, {"row": 1, "answer": "OXO"}, "1A: runs off the grid or over a block"),
        (2, {"row": 1, "answer": "OEX"}, "2D: runs off the grid or over a block"),
        (2, {"number": 3, "id": "3D"}, "3D: number should be 2 for a word starting at row 0"),
        (2, {"answer": "XOE"}, "2D: letter 'X' at row 0, col 2 clashes with 'T' from 1A"),
    ],
)
def test_word_problems(index, changes, expected):
    problems = _problems(_with_word(index, **changes))
    assert any(problem.startswith(expected) for problem in problems), problems


def test_letter_cell_without_a_word():
    grid = _grid()
    del grid["words"][2]  # 2D
    assert sorted(_problems(grid)) == [
        "cell row 1, col 2 is a letter cell but no word uses it",
        "row 0, col 2: down run of 2+ letters has no word",
        "row 1, col 2: down run of 2+ letters has no word",
        "row 2, col 2: down run of 2+ letters has no word",
    ]


def test_run_without_a_word():
    grid = _grid()
    del grid["words"][3]  # 3A
    problems = _problems(grid)
    assert "row 2, col 0: across run of 2+ letters has no word" in problems
    assert "cell row 2, col 1 is a letter cell but no word uses it" in problems


def test_lists_every_problem_once():
    grid = _grid()
    grid["words"][0]["answer"] = "cat"
    grid["words"][3]["id"] = "3D"
    problems = puzzle_problems(grid)
    assert problems[0].startswith("1A: answer")
    assert "3D: id should be 3A (number + A/D)" in problems
    assert len(problems) == len(set(problems))


def test_example_detects_a_changed_letter():
    puzzle = copy.deepcopy(json.loads(EXAMPLE.read_text()))
    puzzle["words"][2]["answer"] = "VAIXOM"  # 2D crosses 5A at the K
    assert any("clashes" in problem for problem in puzzle_problems(puzzle))
