# Installing the Kerala PSC AI kit

Unzip into the root of the repo on the `psc-dev` branch. It only adds or replaces kit files (CLAUDE.md, TASKS.md, docs, design, skills, rules) — no app code.

> **Hidden folders:** `.claude/` and `.cursor/` start with a dot. macOS Finder hides them, and they were missing from commit 40b6343. Unzip from Terminal (`unzip -o kit.zip -d .`) or press Cmd+Shift+. in Finder to see them.

```
CLAUDE.md                 conventions for Claude Code (read automatically)
TASKS.md                  task sheet: status board + task cards
.cursor/rules/*.mdc       Cursor rules (always-on + scoped by file type)
.claude/settings.json     safe command allow-list for Claude Code
.claude/skills/           5 skills: task-workflow, flutter-feature, cloud-function,
                          firestore-collection, crossword-content
docs/firebase/            Firebase design for PSC Crossword
design/                   tokens, screen specs, components, prototypes, map data
content/                  where PSC question/puzzle drafts go
```

Then:

```bash
git checkout psc-dev && git pull
git checkout -b chore/CW-003-ai-kit
# unzip here
git add CLAUDE.md TASKS.md .cursor .claude docs design content
git commit -m "CW-003: Add AI kit skills and rules; re-baseline docs for psc-dev"
```

Try it in Claude Code (inside Cursor):

- "What's next?" → picks the next unblocked task
- "Start CW-004" → follows the card and the matching skill
- "/flutter-feature" or "/crossword-content" → runs a skill directly

Delete this file after installing if you like.
