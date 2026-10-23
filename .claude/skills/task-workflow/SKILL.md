---
name: task-workflow
description: Run Kerala PSC app project tasks from TASKS.md — pick the next unblocked task, start a task by ID (status, branch, plan), finish it (checks, Done-when boxes, review status, daily update), or add/split a task. Use when the user says "start CW-0XX", "what's next", "finish this task", "update the task sheet", or asks for project status.
---

# Task workflow

`TASKS.md` is the source of truth. **Status lives only in the status board**; cards hold scope and "Done when".

## "What's next?"

1. Read the status board.
2. Candidates = rows with status `todo` whose every `Depends` ID is `done` (a range like `CW-015…CW-022` means all of them).
3. Prefer the lowest milestone, then the lowest ID. Skip anything blocked by an **Open** decision (e.g. DEC-007).
4. Reply with the top 3: ID, title, estimate, why it's unblocked. Don't start until asked (or the user said "start the next one").

## "Start CW-0XX"

1. Read the card. If a dependency isn't `done`, say which and stop.
2. Board: set the row to `doing`.
3. Branch: `git checkout psc-dev && git pull && git checkout -b feat/CW-0XX-short-name` (use `chore/` for ops, `fix/` for bugs).
4. Write a 3–6 line plan: files to touch, skill to use (`flutter-feature`, `cloud-function`, `firestore-collection`, `crossword-content`), tests to add.
5. Do the work inside the card's scope. Found extra work? Add a new task (below), don't widen this one.

## "Finish" / before review

1. Run checks:
   - `fvm flutter analyze` and `fvm flutter test`
   - if `functions/` changed: `cd functions && venv/bin/ruff check . && venv/bin/ruff format --check . && venv/bin/pytest`
   - if rules changed: rules tests on the emulator
2. Tick each "Done when" box on the card that is truly done. If one can't be done, leave it unticked and explain in Notes.
3. Board: `review` (or `blocked` + reason in Notes).
4. Commit: `CW-0XX: <imperative summary>`; PR into `psc-dev` titled `CW-0XX: <task title>`, body = the card's Done-when list.
5. If the schema or a screen changed, confirm `docs/firebase/FIREBASE_DESIGN.md` / `design/screens/*.md` were updated.
6. Append to `docs/daily/YYYY-MM-DD.md` (create if missing):

```markdown
## CW-0XX — <title>

### Problem
<one or two lines>

### Solution
<what changed, key decisions>

**Files:** `path/a.dart`, `path/b.py`
```

After merge, the user (or Claude when told) sets the row to `done`.

## Adding or splitting a task

- Next free ID in that milestone's range (never reuse IDs; deleted tasks stay as `done` with Note "dropped").
- Add **both** a board row (ID, title, area, estimate, depends, `todo`) and a card with a "Done when" list.
- Areas: `app`, `admin`, `functions`, `rules`, `content`, `design`, `qa`, `ops`.
- A task bigger than 3d → split it.

## Status report ("where are we?")

Count rows per milestone by status and list anything `blocked` or `doing` for more than 3 days (check git log for the branch). Keep it to a small table.

## Decisions

When a choice affects other tasks, add a `DEC-00X` row (Proposed → Accepted / Open) and reference it from the affected cards.
