# Phase 8 — Sharing

> **Status:** Not started  
> **Last updated:** —  
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

- [ ] **Step 8.1** — Add `share_plus`; build `StoryShareFormatter` (outcome + score + grids)
- [ ] **Step 8.2** — Share button on resolution screen → native share sheet

## Share payload format (sketch)

```
Detective Wordle — Case Closed 🕵️
Score: 240/300

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
| Share lib | `share_plus` | Per fulldoc.md, cross-platform | — |
| Grid encoding | Same emoji scheme as Wordle | Familiar to players | — |
| Spoiler policy | Only share after case complete | Avoid leaking answers | — |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `pubspec.yaml` | Add `share_plus` |
| `lib/features/story_mode/presentation/utils/story_share_formatter.dart` | New |
| `lib/features/story_mode/presentation/pages/case_resolution_page.dart` | Share button |

## Acceptance criteria

- [ ] Share sheet opens on iOS and Android
- [ ] Text includes outcome, score, and 3 clue grids
- [ ] No answer words in plain text (grids only)
- [ ] WhatsApp receives formatted text via system share intent

## Testing notes

- Manual share to Notes / WhatsApp / Messages
- Empty/failed clues render correct grid rows

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- Include app store link in share text?
- Branding: "Detective Wordle" vs "WordSchool Story Mode"?
