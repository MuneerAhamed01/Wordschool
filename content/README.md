# Content drafts

Draft PSC content as JSON before it goes into the admin panel (import: task CW-036).

- `questions/<subject>.json` — question-bank drafts (`subject`, `questions[]`)
- `puzzles/<puzzleId>.json` — crossword drafts (answers in plain text; the server encodes them)

Shapes and an example of each: `.claude/skills/crossword-content/examples/`.
Validate a puzzle: `python3 .claude/skills/crossword-content/scripts/validate_crossword.py content/puzzles/<id>.json --render`

Everything here is **draft** until a person verifies each fact in the admin panel. Don't put answers for live puzzles in a public repo if the repo is public.
