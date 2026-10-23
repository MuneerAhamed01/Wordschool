"""Crossword grid validator (CW-013).

Same checks as `.claude/skills/crossword-content/scripts/validate_crossword.py`, so a
puzzle that passes there passes here. Pure: no Firestore.
"""

import re
from typing import NotRequired, TypedDict

from crossword.errors import InputError
from crossword.types import Direction, LocalizedText

ANSWER_RE = re.compile(r"[A-Z]{2,}")
MIN_SIZE = 3
MAX_SIZE = 15

type Cell = tuple[int, int]


class GridWord(TypedDict):
    """A word as the admin enters it: plain answer, not yet encoded."""

    id: str
    number: int
    direction: Direction
    row: int
    col: int
    length: int
    answer: str
    clue: LocalizedText
    extraClue: NotRequired[LocalizedText]
    fact: NotRequired[LocalizedText]
    questionId: NotRequired[str]


class Grid(TypedDict):
    """The parts of a puzzle the validator checks."""

    rows: int
    cols: int
    layout: str
    words: list[GridWord]


class PuzzleValidationError(InputError):
    """The grid is invalid; `problems` lists every reason."""


def implied_numbers(layout: str, rows: int, cols: int) -> dict[Cell, int]:
    """Standard crossword numbering.

    Row by row, a letter cell gets the next number when it starts an across or a down
    run of two or more letters.

    Returns:
        `{(row, col): number}` for every numbered cell.
    """

    def is_open(r: int, c: int) -> bool:
        return 0 <= r < rows and 0 <= c < cols and layout[r * cols + c] == "."

    numbers: dict[Cell, int] = {}
    for r in range(rows):
        for c in range(cols):
            if not is_open(r, c):
                continue
            starts_across = not is_open(r, c - 1) and is_open(r, c + 1)
            starts_down = not is_open(r - 1, c) and is_open(r + 1, c)
            if starts_across or starts_down:
                numbers[(r, c)] = len(numbers) + 1
    return numbers


def word_cells(word: GridWord) -> list[Cell]:
    """Cells a word covers, first letter first."""
    dr, dc = (0, 1) if word["direction"] == "across" else (1, 0)
    return [(word["row"] + dr * i, word["col"] + dc * i) for i in range(word["length"])]


def puzzle_problems(grid: Grid) -> list[str]:
    """Every problem with the grid, in a stable order; empty when it is valid."""
    rows, cols, layout = grid["rows"], grid["cols"], grid["layout"]
    if not (MIN_SIZE <= rows <= MAX_SIZE and MIN_SIZE <= cols <= MAX_SIZE):
        return [f"rows and cols must be between {MIN_SIZE} and {MAX_SIZE}"]
    if len(layout) != rows * cols:
        return [f"layout has {len(layout)} chars, expected rows*cols = {rows * cols}"]
    if set(layout) - {".", "#"}:
        return ["layout may only contain '.' (letter) and '#' (block)"]
    words = grid["words"]
    if not words:
        return ["puzzle has no words"]

    def is_open(r: int, c: int) -> bool:
        return 0 <= r < rows and 0 <= c < cols and layout[r * cols + c] == "."

    problems: list[str] = []
    numbers = implied_numbers(layout, rows, cols)
    letters: dict[Cell, tuple[str, str]] = {}
    covered: dict[Direction, set[Cell]] = {"across": set(), "down": set()}
    seen_ids: set[str] = set()

    for word in words:
        wid = word["id"]
        if wid in seen_ids:
            problems.append(f"{wid}: duplicate word id")
        seen_ids.add(wid)

        direction = word["direction"]
        answer = word["answer"]
        if not ANSWER_RE.fullmatch(answer):
            problems.append(f"{wid}: answer {answer!r} must be 2+ uppercase letters A-Z")
            continue
        if word["length"] != len(answer):
            problems.append(f"{wid}: length {word['length']} != len(answer) {len(answer)}")
            continue
        expected_id = f"{word['number']}{'A' if direction == 'across' else 'D'}"
        if wid != expected_id:
            problems.append(f"{wid}: id should be {expected_id} (number + A/D)")

        cells = word_cells(word)
        if not all(is_open(r, c) for r, c in cells):
            problems.append(f"{wid}: runs off the grid or over a block")
            continue
        dr, dc = (0, 1) if direction == "across" else (1, 0)
        (r0, c0), (r1, c1) = cells[0], cells[-1]
        if is_open(r0 - dr, c0 - dc) or is_open(r1 + dr, c1 + dc):
            problems.append(
                f"{wid}: does not fill its whole run (a letter cell touches its start or end)"
                " — extend the word or add a block"
            )
        start_number = numbers.get((r0, c0))
        if start_number != word["number"]:
            problems.append(
                f"{wid}: number should be {start_number} for a word starting at row {r0}, col {c0}"
            )

        for (r, c), letter in zip(cells, answer, strict=True):
            previous = letters.get((r, c))
            if previous and previous[0] != letter:
                problems.append(
                    f"{wid}: letter {letter!r} at row {r}, col {c} clashes with "
                    f"{previous[0]!r} from {previous[1]}"
                )
            else:
                letters[(r, c)] = (letter, wid)
            covered[direction].add((r, c))

    for r in range(rows):
        for c in range(cols):
            if not is_open(r, c):
                continue
            if (r, c) not in letters:
                problems.append(f"cell row {r}, col {c} is a letter cell but no word uses it")
            in_across_run = is_open(r, c - 1) or is_open(r, c + 1)
            if in_across_run and (r, c) not in covered["across"]:
                problems.append(f"row {r}, col {c}: across run of 2+ letters has no word")
            in_down_run = is_open(r - 1, c) or is_open(r + 1, c)
            if in_down_run and (r, c) not in covered["down"]:
                problems.append(f"row {r}, col {c}: down run of 2+ letters has no word")

    return list(dict.fromkeys(problems))


def validate_puzzle(grid: Grid) -> None:
    """Check a crossword grid.

    Checks: size; layout length = rows × cols; only `.`/`#`; answers `^[A-Z]{2,}$`;
    ids `{number}{A|D}`; every word fits and fills its whole run; numbering follows the
    standard order; crossing letters agree; every letter cell is in a word; every run
    of 2+ letters has a word.

    Raises:
        PuzzleValidationError: Listing every problem.
    """
    problems = puzzle_problems(grid)
    if problems:
        raise PuzzleValidationError(problems)
