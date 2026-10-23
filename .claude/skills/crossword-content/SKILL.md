---
name: crossword-content
description: Draft Kerala PSC question-bank entries and crossword puzzles as JSON, check grids with the validator (fit, crossings, coverage, numbering), and produce encoded answers. Use when creating or fixing PSC questions, building a crossword grid, or preparing content for the admin panel or seed scripts.
---

# PSC crossword content

Content is the product. A wrong answer in an exam-prep app costs more trust than any bug. So:

> **Claude drafts. A human verifies every fact before it is marked `verified`.** Never set `status: "verified"` yourself, never invent a source, and put any doubt in `draftNotes`.

## Files

| Path | What |
| --- | --- |
| `content/questions/<subject>.json` | Draft question-bank entries (shape: `examples/kerala-history.questions.json`) |
| `content/puzzles/<puzzleId>.json` | Draft puzzles (shape: `examples/kerala-history-0012.puzzle.json`) |
| `scripts/validate_crossword.py` | Grid validator, numbering, answer encoder |

The admin panel imports these files (task CW-036) or admins type them in. Field names match `docs/firebase/FIREBASE_DESIGN.md`.

## Writing questions

For each entry:

- `answer` — the crossword form: **uppercase A–Z only**, no spaces or dots (`EMS`, `KAPPAD`, `NAMBOODIRIPAD`). Keep the readable form in `answerDisplay`.
- `clues` — 1–3 wordings, each standalone and unambiguous, ≤ 80 characters. Mark `level`: `easy | medium | hard`. Avoid giving the answer's letters away.
- `fact` — one or two sentences a student should remember; include the key number/date.
- `subject` matches a category id with `_` (`kerala_history`); `topic` is a short slug.
- `examTags` from: `ldc`, `lgs`, `degree_level`, `police`, `secretariat_assistant`, `vfa`.
- `source` — `{type: "pyq" | "book" | "scert" | "gov_site", ref: "..."}`. Unknown → `"TODO: ..."`, never a guess.
- `draftNotes` — anything uncertain (conflicting dates, spelling variants). Remove before import.

Prefer facts that appear in previous PSC papers and SCERT textbooks. Where sources disagree (dates, spellings), say so in `draftNotes`.

## Building a puzzle

1. Pick 6–12 **verified** questions from one category; mix lengths (3–9 letters work best on 8×8 to 11×11).
2. Place the longest answer first, then cross others through shared letters. Every white cell should belong to a word; blocks (`#`) fill the rest.
3. Write `layout` row by row (`rows × cols` characters, `.` = letter cell, `#` = block).
4. Number words in standard order — run the validator with `--number` to see what the grid implies.
5. Copy `clue`, `extraClue` (the free hint) and `fact` from the question; set `questionId`.
6. Validate until clean:

```bash
python3 .claude/skills/crossword-content/scripts/validate_crossword.py content/puzzles/kerala-history-0013.json --render
```

It checks: layout size and characters; each word fits, starts/ends at a block or edge, and has the right length; crossing letters agree; every letter cell is used; every across/down run of 2+ letters has a word; ids are `{number}{A|D}`; numbers follow the grid; `clue.en` present.

Example output for the bundled puzzle:

```
M U Z I R I S #
A # # # # # # #
L # V # # # G #
A S A N # # A #
B # I # # # M #
A # K A P P A D
R # O # # # # #
# E M S # # # #
OK — kerala-history-0012: 7 words, 8x8
```

## Answer encoding

The published puzzle stores `answerEnc` instead of `answer` (DEC-003):

```
answerEnc = base64( utf8(answer) XOR utf8(puzzleId + ":" + wordId) )   # key repeated
```

`--encode` prints it. The server (`adminSaveCrosswordPuzzle`) does this for you; the script is for seed files and for checking the Python/Dart implementations (CW-014) — all three must produce the same strings. Fixtures: `VAIKOM` / `kerala-history-0012` / `2D` → `PSQ7KiMs`.

## Quality bar for a puzzle

- [ ] Validator passes
- [ ] Every word is from a verified question with a real source
- [ ] No two clues reveal each other's answers
- [ ] Clues read correctly for Malayalam-medium students (simple English)
- [ ] Difficulty label matches the clue levels used
