# Phase 8 — Sharing

> **Status:** Complete  
> **Last updated:** 2026-06-27  
> **Owner:** —  
> **Depends on:** Phase 5 (score + outcome available)  
> **Blocks:** —  

## Goal

Let players share case results via native share sheet (including WhatsApp where supported), with score, outcome, and Wordle-style guess grids.

## Scope

### In scope

- Add `share_plus` dependency
- Build share payload: outcome, total score, per-clue emoji grids
- Share button on case resolution screen

### Out of scope (deferred)

- Deep links back into app
- Share mid-case (in progress)

## Steps checklist

- [x] **Step 8.1** — Add `share_plus`; build `StoryShareFormatter` (outcome + score + grids)
- [x] **Step 8.2** — Share button on resolution screen → native share sheet

## Share payload format (sketch)

```
Detective Wordle — Case Closed 🕵️
Score: 240/300
Outcome: Case Closed

Clue 1 — Location
🟩⬛🟨🟩🟩

Clue 2 — Weapon
🟩🟩🟩🟩🟩

Clue 3 — Suspect
🟩🟨⬛🟩🟩

Play today's case in WordSchool
```

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Share lib | `share_plus` | Per fulldoc.md, cross-platform | 2026-06-27 |
| Grid encoding | Same emoji scheme as Wordle | Shared `WordleGuessEvaluator` | 2026-06-27 |
| Spoiler policy | Only share after case complete | Share button on resolution only | 2026-06-27 |
| Branding | "Detective Wordle" in share header | Matches fulldoc sketch | 2026-06-27 |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `pubspec.yaml` | Added `share_plus` |
| `lib/core/utils/wordle_guess_evaluator.dart` | New — shared emoji grid evaluation |
| `lib/features/story_mode/presentation/utils/story_share_formatter.dart` | New |
| `lib/features/story_mode/presentation/pages/case_resolution_page.dart` | Share button + `Share.share()` |

## Acceptance criteria

- [x] Share sheet opens on iOS and Android
- [x] Text includes outcome, score, and 3 clue grids
- [x] No answer words in plain text (grids only)
- [x] WhatsApp receives formatted text via system share intent

## Testing notes

- Manual share to Notes / WhatsApp / Messages
- Empty/failed clues render correct grid rows

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-27 | 8.1–8.2 | Formatter + resolution share button; analytics `story_share_tapped` wired |

## Open questions / blockers

- Include app store link in share text? → **Deferred** (tagline only: "Play today's case in WordSchool")
- Branding: "Detective Wordle" vs "WordSchool Story Mode"? → **Resolved:** "Detective Wordle" header, WordSchool tagline
