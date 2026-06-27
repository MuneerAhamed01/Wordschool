# Phase 5 — Scoring & Outcomes

> **Status:** Complete  
> **Last updated:** 2026-06-27  
> **Owner:** —  
> **Depends on:** Phase 4  
> **Blocks:** Phase 6, Phase 8  

## Goal

Calculate detective points per clue, determine case outcome, display results on resolution screen, and lock today's case after completion.

## Scope

### In scope

- Points mapping by attempts (100 → 10, fail = 0)
- Outcome enum resolution from solved clue count
- Total score (max 300/day)
- Extend user stats with detective points
- One case per day completion lock

### Out of scope (deferred)

- Weekly leaderboard aggregation (Phase 6)
- Share text with score (Phase 8)

## Steps checklist

- [x] **Step 5.1** — `DetectiveScoreCalculator` — map attempts → points
- [x] **Step 5.2** — `CaseOutcomeResolver` — 3/2/1/0 clues → outcome
- [x] **Step 5.3** — Resolution screen: per-clue breakdown + total score
- [x] **Step 5.4** — Extend user game state with `detectivePoints`, `storyModeStreak`
- [x] **Step 5.5** — Prevent replay of today's case after completion

## Scoring table (5-guess limit — Phase 4 alignment)

| Attempts | Points |
| -------- | ------ |
| 1 | 100 |
| 2 | 80 |
| 3 | 60 |
| 4 | 40 |
| 5 | 20 |
| Failed | 0 |

**Maximum:** 300 points per day (3 clues × 100)

## Outcome table

| Outcome | Clues solved |
| ------- | ------------ |
| Case Closed | 3 |
| Cold Case | 2 |
| Unsolved | 1 |
| Dismissed | 0 |

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Score timing | Compute on clue complete + finalize on case end | Incremental + final validation | 2026-06-27 |
| Stats storage | Extend `UserGameStateEntity` | Reuse existing user doc; Phase 6 adds weekly leaderboard | 2026-06-27 |
| Attempt table | 5 guesses (Phase 4) | Matches daily Wordle cap; drops fulldoc 6th-attempt row | 2026-06-27 |
| Post-completion UX | Read-only review | Show score/outcome; narrative replay allowed, no re-scoring | 2026-06-27 |
| Completion lock | `completedAt` on progress doc | `StoryCaseBloc` → `alreadyCompleted`; Firestore rule blocks updates | 2026-06-27 |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/features/story_mode/domain/utils/detective_score_calculator.dart` | New |
| `lib/features/story_mode/domain/utils/case_outcome_resolver.dart` | New |
| `lib/features/story_mode/domain/usecases/complete_story_case.dart` | New |
| `lib/features/story_mode/presentation/pages/case_resolution_page.dart` | Score UI |
| `lib/features/story_mode/presentation/widgets/case_score_breakdown.dart` | New |
| `lib/features/story_mode/presentation/utils/case_outcome_labels.dart` | New |
| `lib/shared/domains/entities/user_game_state/` | Add detective fields |
| `lib/core/utils/story_mode_streak_calculator.dart` | New |
| `lib/features/story_mode/data/data_source/remote/story_progress_service.dart` | Scoring + finalize |
| `firestore.rules` | Story progress lock + user stats fields |

## Acceptance criteria

- [x] 1-attempt solve on all clues = 300 total
- [x] Failed clue contributes 0 to total
- [x] Correct outcome badge for each solve combination
- [x] Re-opening app after completion shows `alreadyCompleted`, not replay

## Testing notes

- Unit tests for all attempt → point mappings
- Unit tests for all 4 outcomes (0–3 clues solved)
- Edge: user fails clue 1, solves 2 and 3 → Cold Case, score = sum of 2+3 only
- `StoryCaseBloc` transitions to `alreadyCompleted` when `completedAt` is set mid-session

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-27 | 5.1–5.5 | Scoring utils, incremental + finalize writes, resolution UI, user stats, completion lock |

## Open questions / blockers

- ~~Partial credit if user abandons mid-case — score only completed clues?~~ → Yes; case finalizes only after clue 3 completes
- ~~Show outcome on dashboard before opening resolution screen?~~ → Home shows outcome + score on `alreadyCompleted`
