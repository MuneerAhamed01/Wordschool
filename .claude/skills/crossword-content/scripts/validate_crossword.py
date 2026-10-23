#!/usr/bin/env python3
"""Validate (and optionally number / encode / render) a PSC crossword puzzle JSON.

The checks mirror functions/crossword/validate_puzzle.py (task CW-013), so a
puzzle that passes here will pass on the server (which also checks each word's
question is verified and has the same answer).

Usage:
  python3 validate_crossword.py puzzle.json            # validate, exit 1 on problems
  python3 validate_crossword.py puzzle.json --render   # also print the solved grid
  python3 validate_crossword.py puzzle.json --number   # print the numbering the grid implies
  python3 validate_crossword.py puzzle.json --encode   # print answerEnc for each word

Puzzle shape (admin input — answers in plain text; the server encodes them):
{
  "id": "kerala-history-0012", "categoryId": "kerala-history",
  "rows": 8, "cols": 8, "layout": "........#...",   # '.' letter cell, '#' block
  "words": [{"id": "1A", "number": 1, "direction": "across", "row": 0, "col": 0,
             "length": 7, "answer": "MUZIRIS", "clue": {"en": "..."},
             "fact": {"en": "..."}, "questionId": "..."}]
}
"""

from __future__ import annotations

import argparse
import base64
import json
import re
import sys

ANSWER_RE = re.compile(r"^[A-Z]{2,}$")


def encode_answer(answer: str, puzzle_id: str, word_id: str) -> str:
    """answerEnc = base64(utf8(answer) XOR utf8(puzzleId + ':' + wordId), key repeated).

    Obfuscation only — not security. Same algorithm in Python and Dart (CW-014).
    """
    data = answer.encode("utf-8")
    key = f"{puzzle_id}:{word_id}".encode("utf-8")
    out = bytes(b ^ key[i % len(key)] for i, b in enumerate(data))
    return base64.b64encode(out).decode("ascii")


def decode_answer(enc: str, puzzle_id: str, word_id: str) -> str:
    data = base64.b64decode(enc)
    key = f"{puzzle_id}:{word_id}".encode("utf-8")
    return bytes(b ^ key[i % len(key)] for i, b in enumerate(data)).decode("utf-8")


def implied_numbers(layout: str, rows: int, cols: int) -> dict[tuple[int, int], int]:
    """Standard crossword numbering: row-major, a cell gets a number if it starts
    an across run or a down run of length >= 2."""
    def open_(r: int, c: int) -> bool:
        return 0 <= r < rows and 0 <= c < cols and layout[r * cols + c] == "."

    nums: dict[tuple[int, int], int] = {}
    n = 0
    for r in range(rows):
        for c in range(cols):
            if not open_(r, c):
                continue
            starts_across = not open_(r, c - 1) and open_(r, c + 1)
            starts_down = not open_(r - 1, c) and open_(r + 1, c)
            if starts_across or starts_down:
                n += 1
                nums[(r, c)] = n
    return nums


def word_cells(w: dict) -> list[tuple[int, int]]:
    dr, dc = (0, 1) if w["direction"] == "across" else (1, 0)
    return [(w["row"] + dr * i, w["col"] + dc * i) for i in range(w["length"])]


def validate(p: dict) -> list[str]:
    problems: list[str] = []
    rows, cols, layout = p.get("rows"), p.get("cols"), p.get("layout", "")
    if not isinstance(rows, int) or not isinstance(cols, int) or not (3 <= rows <= 15) \
            or not (3 <= cols <= 15):
        return ["rows and cols must be integers between 3 and 15"]
    if len(layout) != rows * cols:
        return [f"layout has {len(layout)} chars, expected rows*cols = {rows * cols}"]
    if set(layout) - {".", "#"}:
        return ["layout may only contain '.' (letter) and '#' (block)"]

    def is_open(r: int, c: int) -> bool:
        return 0 <= r < rows and 0 <= c < cols and layout[r * cols + c] == "."

    words = p.get("words") or []
    if not words:
        return ["puzzle has no words"]

    numbers = implied_numbers(layout, rows, cols)
    letters: dict[tuple[int, int], tuple[str, str]] = {}
    covered_across: set[tuple[int, int]] = set()
    covered_down: set[tuple[int, int]] = set()
    seen_ids: set[str] = set()

    for w in words:
        wid = w.get("id", "?")
        if wid in seen_ids:
            problems.append(f"{wid}: duplicate word id")
        seen_ids.add(wid)

        d = w.get("direction")
        if d not in ("across", "down"):
            problems.append(f"{wid}: direction must be 'across' or 'down'")
            continue
        answer = w.get("answer", "")
        if not ANSWER_RE.match(answer):
            problems.append(f"{wid}: answer {answer!r} must be 2+ uppercase letters A-Z")
            continue
        if w.get("length") != len(answer):
            problems.append(f"{wid}: length {w.get('length')} != len(answer) {len(answer)}")
            continue
        expected_id = f"{w.get('number')}{'A' if d == 'across' else 'D'}"
        if wid != expected_id:
            problems.append(f"{wid}: id should be {expected_id} (number + A/D)")
        if not (w.get("clue") or {}).get("en"):
            problems.append(f"{wid}: clue.en is required")

        cells = word_cells(w)
        if not all(is_open(r, c) for r, c in cells):
            problems.append(f"{wid}: runs off the grid or over a block")
            continue
        dr, dc = (0, 1) if d == "across" else (1, 0)
        (r0, c0), (r1, c1) = cells[0], cells[-1]
        if is_open(r0 - dr, c0 - dc) or is_open(r1 + dr, c1 + dc):
            problems.append(f"{wid}: does not fill its whole run (a letter cell touches its "
                            f"start or end) — extend the word or add a block")
        start_no = numbers.get((r0, c0))
        if start_no != w.get("number"):
            problems.append(f"{wid}: number should be {start_no} for a word starting at "
                            f"row {r0}, col {c0}")

        for (r, c), ch in zip(cells, answer):
            prev = letters.get((r, c))
            if prev and prev[0] != ch:
                problems.append(f"{wid}: letter {ch!r} at row {r}, col {c} clashes with "
                                f"{prev[0]!r} from {prev[1]}")
            else:
                letters[(r, c)] = (ch, wid)
            (covered_across if d == "across" else covered_down).add((r, c))

    for r in range(rows):
        for c in range(cols):
            if not is_open(r, c):
                continue
            if (r, c) not in letters:
                problems.append(f"cell row {r}, col {c} is a letter cell but no word uses it")
            if is_open(r, c - 1) or is_open(r, c + 1):
                if (r, c) not in covered_across:
                    problems.append(f"row {r}, col {c}: across run of 2+ letters has no word")
            if is_open(r - 1, c) or is_open(r + 1, c):
                if (r, c) not in covered_down:
                    problems.append(f"row {r}, col {c}: down run of 2+ letters has no word")

    # de-duplicate run messages (every cell of a missing run reports it)
    seen: set[str] = set()
    unique = []
    for msg in problems:
        if msg not in seen:
            unique.append(msg)
            seen.add(msg)
    return unique


def render(p: dict) -> str:
    rows, cols, layout = p["rows"], p["cols"], p["layout"]
    grid = [["#" if layout[r * cols + c] == "#" else "." for c in range(cols)]
            for r in range(rows)]
    for w in p["words"]:
        for (r, c), ch in zip(word_cells(w), w.get("answer", "")):
            if 0 <= r < rows and 0 <= c < cols:
                grid[r][c] = ch
    return "\n".join(" ".join(row) for row in grid)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("puzzle", help="path to puzzle JSON")
    ap.add_argument("--render", action="store_true", help="print the solved grid")
    ap.add_argument("--number", action="store_true", help="print implied numbering")
    ap.add_argument("--encode", action="store_true", help="print answerEnc per word")
    a = ap.parse_args()

    with open(a.puzzle, encoding="utf-8") as fh:
        p = json.load(fh)

    problems = validate(p)
    if a.number and isinstance(p.get("layout"), str):
        nums = implied_numbers(p["layout"], p["rows"], p["cols"])
        print("Implied numbering (number: row, col):")
        for (r, c), n in sorted(nums.items(), key=lambda kv: kv[1]):
            print(f"  {n}: row {r}, col {c}")
    if a.render and not problems:
        print(render(p))
    if a.encode and not problems:
        for w in p["words"]:
            print(f"{w['id']}: {encode_answer(w['answer'], p['id'], w['id'])}")

    if problems:
        print(f"INVALID — {len(problems)} problem(s):")
        for msg in problems:
            print("  -", msg)
        sys.exit(1)
    print(f"OK — {p.get('id', '?')}: {len(p['words'])} words, {p['rows']}x{p['cols']}")


if __name__ == "__main__":
    main()
