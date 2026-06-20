# Phase 5 — Scoring & Outcomes

> **Status:** Not started  
> **Last updated:** —  
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

- [ ] **Step 5.1** — `DetectiveScoreCalculator` — map attempts → points
- [ ] **Step 5.2** — `CaseOutcomeResolver` — 3/2/1/0 clues → outcome
- [ ] **Step 5.3** — Resolution screen: per-clue breakdown + total score
- [ ] **Step 5.4** — Extend user game state with `detectivePoints`, `storyModeStreak`
- [ ] **Step 5.5** — Prevent replay of today's case after completion

## Scoring table (from fulldoc.md)

| Attempts | Points |
| -------- | ------ |
| 1 | 100 |
| 2 | 80 |
| 3 | 60 |
| 4 | 40 |
| 5 | 20 |
| 6 | 10 |
| Failed (7+) | 0 |

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
| Score timing | Compute on clue complete + finalize on case end | Incremental + final validation | — |
| Stats storage | Extend `UserGameStateEntity` or separate doc | TBD — see Phase 0 open question | — |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/features/story_mode/domain/utils/detective_score_calculator.dart` | New |
| `lib/features/story_mode/domain/utils/case_outcome_resolver.dart` | New |
| `lib/features/story_mode/presentation/pages/case_resolution_page.dart` | Score UI |
| `lib/shared/domains/entities/user_game_state/` | Add detective fields |
| `lib/features/story_mode/domain/usecases/complete_story_case.dart` | New |

## Acceptance criteria

- [ ] 1-attempt solve on all clues = 300 total
- [ ] Failed clue contributes 0 to total
- [ ] Correct outcome badge for each solve combination
- [ ] Re-opening app after completion shows `alreadyCompleted`, not replay

## Testing notes

- Unit tests for all attempt → point mappings
- Unit tests for all 4 outcomes (0–3 clues solved)
- Edge: user fails clue 1, solves 2 and 3 → Cold Case, score = sum of 2+3 only

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- Partial credit if user abandons mid-case — score only completed clues?
- Show outcome on dashboard before opening resolution screen?
