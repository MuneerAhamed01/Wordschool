# Phase 4 — Wordle Per Clue

> **Status:** Complete  
> **Last updated:** 2026-06-27  
> **Owner:** —  
> **Depends on:** Phase 3  
> **Blocks:** Phase 5  

## Goal

Reuse the existing Wordle engine for each detective clue: 5 letters, max 5 guesses (aligned with daily game), persist progress, and resume mid-case.

## Scope

### In scope

- Story Wordle wrapper using `WordCubit`, tiles, keyboard
- Per-clue answer from `DetectiveClue.answer`
- 5-attempt limit and fail handling
- Persist guesses and attempts to Firestore
- Restore state on app reopen

### Out of scope (deferred)

- Scoring calculation (Phase 5)
- Share grid formatting (Phase 8)
- Enhanced tile animations (Phase 7)

## Steps checklist

- [x] **Step 4.1** — `StoryWordlePage` wrapping existing Wordle widgets with clue answer
- [x] **Step 4.2** — Enforce 5-guess limit; on fail mark clue failed (0 pts) and allow reaction
- [x] **Step 4.3** — Persist guesses per clue to `userStoryProgress`
- [x] **Step 4.4** — Restore guesses + active row on app reopen (`WordCubit.restoreGuesses`)
- [x] **Step 4.5** — Win/fail events → navigate to Story Reaction screen

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Wordle state | Reuse `WordCubit` | Already handles evaluation + restore | 2026-06-25 |
| Valid words | Existing `ValidWords` / dictionary | Same rules as daily game | 2026-06-25 |
| Fail behavior | Advance to reaction with failed clue | Per fulldoc scoring (0 pts) | 2026-06-25 |
| Attempt limit | 5 guesses (`GameConstants.maxWords`) | Match daily game; deviates from fulldoc 6 | 2026-06-25 |
| Clue BLoC | `StoryClueBloc` per route with `clueIndex` | Mirrors `GameBloc` + `WordCubit` pattern | 2026-06-25 |
| Invalid word UX | Copy shake + snackbar from `GamePageHelper` | Consistent daily game feel | 2026-06-25 |
| Flow completion | Derive from `currentClueIndex`, not only `clueSolved` | Failed clues still unlock reaction | 2026-06-25 |
| `clueGuesses` persistence | Map in Firestore (`"0"`, `"1"`, `"2"` → string[]) | Firestore rejects nested arrays; model converts in `toJson`/`fromJson` | 2026-06-27 |

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
| `lib/features/story_mode/presentation/pages/story_wordle_page.dart` | New — real Wordle UI |
| `lib/features/story_mode/presentation/pages/story_wordle_page_helper.dart` | New — submit/win/fail logic |
| `lib/features/story_mode/presentation/bloc/story_clue_bloc/story_clue_bloc.dart` | New — clue-level game state |
| `lib/features/story_mode/data/data_source/story_progress_service.dart` | New — write interface |
| `lib/features/story_mode/data/data_source/remote/story_progress_service.dart` | New — Firestore writes |
| `lib/features/story_mode/domain/usecases/save_clue_guess.dart` | New |
| `lib/features/story_mode/domain/usecases/complete_story_clue.dart` | New |
| `lib/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart` | Progress sync + completion derivation |
| `lib/features/story_mode/presentation/routing/story_flow_gating.dart` | Mid-clue resume to wordle |
| `lib/core/routes/app_router.dart` | Wire `StoryWordlePage` + providers |

## Acceptance criteria

- [x] Solving clue in ≤5 guesses navigates to reaction
- [x] Failing after 5 guesses still navigates to reaction
- [x] Closing app mid-clue restores guesses on return
- [x] Each clue uses its own answer, not daily `todayWord`

## Testing notes

- Unit test: attempt cap at 5 (`story_clue_bloc_test.dart`)
- Progress save/complete round-trip (`story_progress_service_test.dart`)
- Failed clue unlocks reaction via `currentClueIndex` (`story_flow_bloc_test.dart`)
- Mid-clue resume path (`story_flow_gating_test.dart`)

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-25 | 4.1–4.5 | Real Wordle page, progress writes, restore, win/fail → reaction |
| 2026-06-27 | Hotfix | `clueGuesses` Firestore map serialization — fixes iOS crash on first guess write |

## Open questions / blockers

- ~~New BLoC per clue vs shared `StoryClueBloc` with clue index param?~~ → Per-route `StoryClueBloc` with index
- ~~Shake animation / invalid word snackbar — copy from `GamePage`?~~ → Yes, via `StoryWordlePageHelper`
