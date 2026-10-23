# PSC Crossword — Screen Specs (Phase 1)

> Frame **390 × 844** (design) — must also work at **360 px** wide. Dark theme. Tokens: `design/tokens/psc-crossword.tokens.json` (prefix `crossword.`).
> Prototype (live, clickable): https://claude.ai/artifact/StzcyAzABQDwkWv9oPxG5H · Source: `design/prototypes/psc-crossword/`
> Data: `docs/firebase/FIREBASE_DESIGN.md` · Tasks: CW-044 – CW-052

Flow: **Home → (category list) → Puzzle → Hints sheet ↔ Puzzle → Results → Revise / Next puzzle**

Global rules: side gutter 16; touch targets ≥ 44 × 44; icons are 1.8–2 px stroke line icons (no emoji); all text from `LocalizedText` (EN in phase 1); numbers use tabular figures.

---

## 1. Home

**Goal:** start today's puzzle in one tap, or pick a category.

**Layout (top → bottom)**

| Block | Spec | Data |
| --- | --- | --- |
| Top bar (48) | Logo mark 36 (2×2 tile grid) + "WordSchool **PSC**" · right: language toggle chip `EN / മല` (32 high) · streak chip (flame + number, `accent.streak` on `accent.streakBg`) | `userGameStates.crossword.currentStreak` |
| Title | "PSC Crossword" `title` · subline "Revise Kerala PSC facts, one grid at a time." `body` muted | static |
| Daily card | `bg.surface`, radius 20, padding 18. Overline "● DAILY · 22 OCT" (`accent.glow`) · puzzle title `heading` · "7 clues · 8×8 grid · about 6 min" caption · mini 4×4 tile preview (64) · **Start puzzle** button (48, `accent.button`) + "+50 XP on solve" | `crosswordDaily/{today IST}` |
| Categories | Header "Categories" + "See all" link · 2-column grid, gap 10 · card min 104: icon well 36 (tinted icon), progress text "18 / 42", name `body` 600, 4 px progress bar in category colour | `crosswordCategories` + player's solved counts |
| "My mistakes" tile | 6th grid card, links to Revise | `revisionItems` count |
| Bottom nav (76) | Play · Revise · Ranks · Profile (existing app shell) | — |

**States**

| State | Shows |
| --- | --- |
| Loading | Skeleton daily card + 6 skeleton tiles (shimmer, existing `shimmer` package) |
| No daily today | Daily card replaced by "Today's puzzle is on its way" + "Play a category" |
| Daily solved | Button becomes "View result" (secondary), card shows score |
| Daily in progress | Button "Continue · 4 / 7" |
| Offline | Cached content + banner "Offline — progress saves when you're back" |
| Feature off | Entry hidden (Remote Config gate) |

## 1b. Category list (no prototype — follow Home styling)

Header with back + category name + "18 / 42 solved". List rows (72): puzzle number tile (44, `bg.surfaceRaised`), title, difficulty chip, status icon (solved ✓ / in progress ring / new). Paged 20; spinner row at the end; empty state "No puzzles yet".

---

## 2. Puzzle

**Goal:** solve the grid fast on a phone keyboard.

| Block | Spec |
| --- | --- |
| Header (48) | Back (44) · centre: category `section` + "Puzzle 12 · Medium" caption · timer chip (`mm:ss`, tabular) · Hints button (44) with count badge (16, `accent.hintStrong`) |
| Progress row | "18 of 24 letters filled" left · check status right ("2 to fix" / "All correct so far") caption muted |
| Grid | Square, width = screen − 40. Gap 2. Cell radius 4. Letter `cellLetter`; number `cellNumber` at top-left (3, 1). Blocks `grid.block` |
| Clue bar (≥ 64) | `clueBar.bg` + border, radius 14. Prev / next chevrons (40 × 44). Overline "2 DOWN · 6 LETTERS" (`clueBar.label`), clue `body`. Long press → "Report a wrong answer" (CW-052) |
| Clue chips | Row of chips (30 high): `1A 4A 5A 6A 1D 2D 3D`; states: default / filled (`status.success*`) / active (`accent.hint`). Scrolls horizontally if more than fit |
| Solved banner | When every letter matches: "Solved! View results" button above keyboard |
| Keyboard | QWERTY, 3 rows, key 52 high, gap 5–7, `key.bg`. Row 3: **CHECK** (1.6× width, `key.action`) + 7 letters + delete (1.6×) |

**Cell states** (one source of truth for the grid engine, CW-043):

| State | Fill | Border | Text |
| --- | --- | --- | --- |
| Empty / filled | `grid.cell` | `grid.cellBorder` | white |
| In active word | `grid.wordBg` | `grid.wordBorder` | white |
| Cursor | `grid.activeBg` | `grid.activeBorder` | `grid.activeText` |
| Checked correct | `grid.correctBg` | same | white |
| Checked wrong | `grid.wrongBg` | `grid.wrongBorder` | white |
| Revealed by hint | as current | as current | `grid.revealedText` |
| Block | `grid.block` | none | — |

**Interactions**

- Tap cell → cursor there; tap the same cell again → switch across/down (only if a word exists that way).
- Typing fills and moves to the next cell in the word; backspace clears, or moves back if empty.
- Prev/next and chips jump to the first empty cell of that word.
- **Check** colours filled cells right/wrong until the next edit of that cell; counts in `checksUsed`.
- Autosave: pause / leave / every 30 s if changed (CW-047). Never per key.
- Timer pauses when the app is backgrounded.

---

## 3. Hints (bottom sheet over Puzzle)

Scrim `bg.scrim`; sheet `bg.sheet`, top radius 24, drag handle 40 × 4.

| Block | Spec |
| --- | --- |
| Header | Overline "2 DOWN · 6 LETTERS" · "Need a hint?" `heading` · current clue muted · close (44) |
| Balance row | Bulb icon + "5 hints left" · "Get more" link (store) |
| Show a clue | **Free.** Expands inline to show `extraClue` in a quote box |
| Reveal a letter | "Fills the selected square · −5 XP" · cost chip "1 hint" |
| Reveal the word | "Fills all 6 letters of 2 Down · −15 XP" · cost chip "3 hints" |
| Rewarded ad | Outline button "Watch a short video for +1 hint" (existing `AdService`; hidden if ad-free / Pro) |
| Footnote | "Revealed words go to My mistakes so you can revise them later." |

Disabled option when balance is too low: cost chip turns to "Not enough hints", row is not tappable.

---

## 4. Results

| Block | Spec | Data (from `submitCrossword` response) |
| --- | --- | --- |
| Top bar | Close (→ Home) · Share (system share sheet, text summary) | — |
| Hero | 84 tile (`accent.primary`) with check · "Kerala History · Puzzle 12" caption · **"Puzzle solved"** `title` · score (30, `status.successText`) + "points" | `result.score` |
| Stats | 4 tiles: Time · Correct `5/7` · XP `+45` (`accent.hint`) · Day streak (`accent.streak`) | `timeSec`, `correctWords/totalWords`, `xpEarned`, streak |
| Level bar | "Level 7 · Fact Finder" · "1,285 / 1,500 XP" · 6 px bar in `accent.hint` | `xp` + Remote Config formula |
| Mistakes to revise | Card per wrong/revealed word: answer as green letter tiles (26 × 30) · tag ("You typed VAIKAM" in error colours, or "Revealed" in warn colours) · clue reference · fact | `wrongWordIds` + puzzle words |
| Actions | **Revise N mistakes** (filled, `accent.button`) · **Next puzzle** (outline) | — |

Perfect solve: mistakes section becomes "No mistakes — great work!" and the primary button is "Next puzzle".

---

## 5. Revise (My mistakes) — no prototype yet

List of `revisionItems` (`mastered == false`, newest first): answer tiles, clue, fact, subject chip, "Mark as learned" (sets `mastered`). Empty: "Nothing to revise. Mistakes from puzzles show up here."

---

## Copy

- Use plain, encouraging words; never blame ("Not quite" not "Wrong!").
- Facts are always full sentences with the key number/date.
- Malayalam strings come later (NEXT-002); keep every string in `LocalizedText` / l10n from day one.

## Analytics (CW-053)

`crossword_open` (Home) · `crossword_start` (puzzleId, source: daily|category) · `crossword_hint` (type) · `crossword_check` · `crossword_submit` (score, timeSec, hints) · `crossword_report` (reason).
