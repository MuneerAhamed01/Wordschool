---
name: task-workflow
description: Run Kerala PSC app project tasks from TASKS.md and docs/STATUS.md — answer status questions, pick the next unblocked task, start a task by ID (status, branch, plan), finish it (checks, Done-when boxes, review status, daily update), close a milestone (done, commits, merge, deploy command), or add/split a task. Use when the user says "start CW-0XX", "what's next", "status of M3", "finish this task", "close M3", "update the task sheet", or asks for project status.
---

# Task workflow

`TASKS.md` is the source of truth. **Status lives only in the status board**; cards hold scope and "Done when".
`docs/STATUS.md` is the cheap snapshot (milestone counts, next up, deployed, code map). **Read it first and answer status questions from it**; open `TASKS.md` only for the rows/cards you need (search for the ID or the `### M3` heading — don't read the whole file), and code only when doing a task.
**Every time you change a board status, deploy something or close a milestone, update `docs/STATUS.md` in the same change.**

## "What's next?"

1. Read `docs/STATUS.md` → "Next up". Confirm against the board rows only if it looks stale (its "Last updated" is older than the last commit touching `TASKS.md`).
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
4. **Don't commit until the user asks.** Leave the changes in the working tree and report them. When asked: one commit per task (`CW-0XX: <imperative summary>`) on the current branch, push it (`git push -u origin <branch>`), merge into `psc-dev`, push `psc-dev`. No PR — the user reviews the pushed branch.
4a. Before committing, scan the diff for leftovers from local testing (hardcoded emails/passwords, `signInWithEmailAndPassword`, `print`, `tool/` harnesses) and revert them.
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

7. Update `docs/STATUS.md` (counts, next up, anything deployed or pending deploy).

After merge, the user (or Claude when told) sets the row to `done`.

## "Close M<n>" (user says review is complete)

1. Board: every row of the milestone → `done` (or `not-needed` with the reason on the card and when to revisit); add `· **closed YYYY-MM-DD**` to the milestone heading. Tick the remaining "Done when" boxes that the review covered and say so on the card ("checked in review YYYY-MM-DD").
2. Run the "Finish" checks once more and the leftover scan (4a).
3. Daily log entry for the close (what was closed, packages added and why, anything pending).
4. Update `docs/STATUS.md` (milestone row, next up, deployed).
5. Commits: one per task on the milestone branch, then one `docs:` commit for TASKS/STATUS/daily/CLAUDE changes. Push the branch, merge into `psc-dev` (`--no-ff`, message `Merge <branch> into psc-dev (M<n> closed)`), push `psc-dev`.
6. Give the user the exact deploy commands for anything not live yet (check with `firebase functions:list --project kerala-pcs-dev`). Don't deploy unless asked.

## Adding or splitting a task

- Next free ID in that milestone's range (never reuse IDs; deleted tasks stay as `done` with Note "dropped").
- Add **both** a board row (ID, title, area, estimate, depends, `todo`) and a card with a "Done when" list.
- Areas: `app`, `admin`, `functions`, `rules`, `content`, `design`, `qa`, `ops`.
- A task bigger than 3d → split it.

## Status report ("where are we?", "status of M3")

Answer from `docs/STATUS.md`. Only if it's stale, count the board rows for that milestone in `TASKS.md` (and `git status` / `git log -5` for uncommitted or unmerged work), then fix `docs/STATUS.md`. List anything `blocked` or `doing` for more than 3 days. `not-needed` rows count as closed, not open work. Keep it to a small table.

## Decisions

When a choice affects other tasks, add a `DEC-00X` row (Proposed → Accepted / Open) and reference it from the affected cards.
