# Phase 4 — Wordle Per Clue

> **Status:** Not started  
> **Last updated:** —  
> **Owner:** —  
> **Depends on:** Phase 3  
> **Blocks:** Phase 5  

## Goal

Reuse the existing Wordle engine for each detective clue: 5 letters, max 6 guesses, persist progress, and resume mid-case.

## Scope

### In scope

- Story Wordle wrapper using `WordCubit`, tiles, keyboard
- Per-clue answer from `DetectiveClue.answer`
- 6-attempt limit and fail handling
- Persist guesses and attempts to Firestore
- Restore state on app reopen

### Out of scope (deferred)

- Scoring calculation (Phase 5)
- Share grid formatting (Phase 8)
- Enhanced tile animations (Phase 7)

## Steps checklist

- [ ] **Step 4.1** — `StoryWordlePage` wrapping existing Wordle widgets with clue answer
- [ ] **Step 4.2** — Enforce 6-guess limit; on fail mark clue failed (0 pts) and allow reaction
- [ ] **Step 4.3** — Persist guesses per clue to `userStoryProgress`
- [ ] **Step 4.4** — Restore guesses + active row on app reopen (`WordCubit.restoreGuesses`)
- [ ] **Step 4.5** — Win/fail events → navigate to Story Reaction screen

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Wordle state | Reuse `WordCubit` | Already handles evaluation + restore | — |
| Valid words | Existing `ValidWords` / dictionary | Same rules as daily game | — |
| Fail behavior | Advance to reaction with failed clue | Per fulldoc scoring (0 pts) | — |

## Reuse map

| Existing | Story Mode usage |
| -------- | ---------------- |
| `WordCubit` | One instance per clue session |
| `shared/.../wordle_tile/tile.dart` | Grid display |
| `keyboard/keyboard.dart` | Input |
| `WordCubit.restoreGuesses` | Resume mid-clue |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/features/story_mode/presentation/pages/story_wordle_page.dart` | New |
| `lib/features/story_mode/presentation/bloc/story_clue_bloc.dart` | New — clue-level game state |
| `lib/features/story_mode/data/data_source/story_progress_service.dart` | New |
| `lib/features/story_mode/domain/usecases/save_clue_guess.dart` | New |
| `lib/features/story_mode/domain/usecases/load_story_progress.dart` | New |

## Acceptance criteria

- [ ] Solving clue in ≤6 guesses navigates to reaction
- [ ] Failing after 6 guesses still navigates to reaction
- [ ] Closing app mid-clue restores guesses on return
- [ ] Each clue uses its own answer, not daily `todayWord`

## Testing notes

- Unit test: attempt cap at 6
- Integration: save → kill app → restore → continue
- Reuse patterns from `game_page_helper.dart` where applicable

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- New BLoC per clue vs shared `StoryClueBloc` with clue index param?
- Shake animation / invalid word snackbar — copy from `GamePage`?
