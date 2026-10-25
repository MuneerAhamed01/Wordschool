# M3 · Player app — manual test (QA)

> Branch `module/m3`, Firebase **`kerala-pcs-dev`**. Automated: `scripts/check.sh` (198 tests).
> Tick each box; note the device and anything odd next to it.

## Before testing — manual configuration (do once)

| # | What | How | Why |
| --- | --- | --- | --- |
| 1 | Deploy `adminGetQuestion` (left over from M2) | `firebase deploy --only functions:adminGetQuestion --project kerala-pcs-dev` | Admin Reports → "Open question" |
| 2 | Check indexes are live | `firebase deploy --only firestore:indexes --project kerala-pcs-dev` (no-op if unchanged) | Revise (`mastered` + `lastWrongAt`) and category lists (`categoryId` + `status` + `number`) |
| 3 | Seed test content in the admin panel | `fvm flutter run -t lib/main_admin.dart -d chrome` → Categories: add 1–2 · Bulk upload: `.claude/skills/crossword-content/examples/kerala-history.questions.json` → Questions: **Mark as checked** each · Bulk upload the example puzzle → Puzzles: send for review → **Publish now** → **Make puzzle of the day** | The app shows only published content |
| 4 | (Optional) Remote Config template | Firebase console → Remote Config: `crossword_hint_penalties` `{"letter":5,"word":15}`, `crossword_reveals_per_puzzle` 3, `crossword_autosave_seconds` 30, `xp_level_formula` `{"base":100,"growth":1.25}` → Publish | The app has the same defaults built in; publishing lets you change them without a release |
| 5 | Phone ready | Android: `fvm flutter run` (debug). iOS (first time on this branch): `cd ios && pod install` then run from Xcode/`fvm flutter run` | — |
| 6 | Two accounts | One Google account + one guest (second device or reinstall) | Leaderboard and profile names |

The leaderboard's `top50` refreshes every 15 min (`refreshLeaderboardTop`), so a new score shows on Ranks within 15 min; your own row (pinned at the bottom) is live.

## Scenarios

### A. Sign-in and profile (CW-055)
- [ ] New Google user → lands on Play. Firestore `users/{uid}` has `displayName` (Google name), `photoUrl`, `isAnonymous: false`, `createdAt`, `lastSeenAt` — nothing else.
- [ ] New guest → `displayName` is `Guest ####`, `isAnonymous: true`.
- [ ] Kill and reopen the app → `lastSeenAt` changes; `createdAt` doesn't.

### B. Home (CW-044)
- [ ] Skeletons, then: top bar (logo, `EN / മല`, streak), title, daily card, categories, "My mistakes" tile, then the daily word card.
- [ ] Daily card: "Start puzzle" → after typing a few letters and going back: "Continue · n / 31" → after submitting: "View result · NN%".
- [ ] With no `crosswordDaily` for today: "Today's puzzle is on its way" + "Play a category".
- [ ] Category tile shows `played / published` and a coloured bar; pull to refresh works.
- [ ] 360 px wide phone (or smallest you have) and system font size at max: nothing cut off.

### C. Category list (CW-045)
- [ ] Opens from a tile; header shows the name and `n / N played`.
- [ ] Rows: number tile, title, difficulty, clue count, New / In progress / Done · score.
- [ ] With > 20 puzzles: scrolling loads more (spinner row at the end).

### D. Puzzle (CW-046, CW-047)
- [ ] Tap a square → cursor; tap again on a crossing → switches across/down. Clue bar and chips follow.
- [ ] Typing moves forward; delete clears, then steps back. Chips/chevrons jump to the first empty square.
- [ ] CHECK: right squares green, wrong red ("2 to fix"); editing a square clears its colour.
- [ ] Timer runs; home button → timer pauses; back to the app → continues.
- [ ] Autosave: `adb logcat | grep CROSSWORD_AUTOSAVE` while typing for 2 minutes → **at most one line every 30 s**; also one on pause and one on back.
- [ ] Open a puzzle and leave without typing → no progress doc is created.
- [ ] Kill the app mid-puzzle, reopen → letters, time and hints are back.
- [ ] (Optional) Bluetooth/USB keyboard: letters type, Backspace deletes, Enter checks, Tab = next word.

### E. Hints (CW-048)
- [ ] Hints sheet: "3 reveals left in this puzzle". Show a clue → the extra clue opens; the badge doesn't change.
- [ ] Reveal a letter → square filled in blue text, badge 2. Reveal the word with 2 left → "Not enough reveals".
- [ ] A revealed word appears as "Revealed" on Results and in My mistakes.

### F. Submit and Results (CW-049)
- [ ] Fill every square → banner "Solved! View results" (all right) or "All squares filled · Submit".
- [ ] Menu → Finish puzzle with empty squares → confirm dialog → Results.
- [ ] Results: score, time, `correct/total`, `+XP`, day streak, level bar, mistakes with "You typed …" or "Revealed" and the fact.
- [ ] Share icon → "Result copied"; paste somewhere.
- [ ] "Revise N mistakes" → Revise tab; "Next puzzle" → category list. Close (×) → Home with updated counts.
- [ ] Reopen the same puzzle from the list → goes straight to its result (no second score).
- [ ] Firestore: progress `status: completed` with `result`; `users/{uid}.xp` and `crossword` updated.

### G. Revise (CW-050)
- [ ] After a puzzle with mistakes: items newest first; "Mark as learned" removes one (doc `mastered: true`).
- [ ] Empty state "Nothing to revise" when all are learned.

### H. Ranks (CW-051)
- [ ] Before any puzzle this week: "Finish a puzzle this week to get a rank."
- [ ] After one: own row pinned at the bottom with rank and XP; after ≤ 15 min the top list includes you, marked "(you)".

### I. Report (CW-052)
- [ ] Clue bar ⋯ (or long press, or header menu → Report) → pick a reason, type a note → "Thanks — we'll check 2 Down."
- [ ] Admin panel → Reports → it's listed under Open with the puzzle and word.

### J. Errors and offline
- [ ] Airplane mode on Home → error card with "Try again" (if nothing cached) or cached content.
- [ ] Airplane mode while playing → typing still works; on submit → "You're offline…" snackbar; reconnect → submit works.

## Known limits (by design, phase 1)

- No offline banner or Remote Config feature gate yet (CW-056).
- Home reads all of the player's progress docs once per session (CW-057).
- Analytics is not planned (CW-053).
- Malayalam toggle is visible but disabled (NEXT-002).
