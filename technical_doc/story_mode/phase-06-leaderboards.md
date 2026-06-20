# Phase 6 — Leaderboards & Progress

> **Status:** Not started  
> **Last updated:** —  
> **Owner:** —  
> **Depends on:** Phase 5  
> **Blocks:** —  

## Goal

Track weekly detective points, show player rank on leaderboards, and surface story-mode streaks and totals on the dashboard.

## Scope

### In scope

- Weekly leaderboard data model
- Score aggregation on case completion
- Detective tab/filter on existing leaderboard
- Story mode streak tracking
- Dashboard stats for rank and points

### Out of scope (deferred)

- Friend challenges (future roadmap)
- Historical case replay leaderboard

## Steps checklist

- [ ] **Step 6.1** — Weekly leaderboard Firestore model (`detectiveLeaderboard/{weekId}/entries/{userId}`)
- [ ] **Step 6.2** — Aggregation on case complete (Cloud Function or client write with rules)
- [ ] **Step 6.3** — Leaderboard UI: "Detective" tab on `leaderboard_page.dart`
- [ ] **Step 6.4** — Story mode daily streak (reuse `streak_calculator` patterns)
- [ ] **Step 6.5** — Dashboard: detective rank, weekly points, story streak

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Week boundary | ISO week (Mon–Sun) UTC | Consistent global leaderboard | — |
| Aggregation | Cloud Function on progress complete | Prevents client tampering | — |
| Leaderboard scope | Top N + current user rank | Match existing leaderboard UX | — |

## Firestore schema sketch

```
detectiveLeaderboard/{yyyy-Www}          # e.g. 2026-W25
  └── entries/{userId}
        ├── displayName: string
        ├── totalPoints: number
        ├── casesCompleted: number
        └── updatedAt: timestamp
```

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `functions/src/updateDetectiveLeaderboard.ts` | New (if server-side) |
| `lib/features/leaderboard/presentation/pages/leaderboard_page.dart` | Detective tab |
| `lib/features/leaderboard/data/` | Detective leaderboard source |
| `lib/core/utils/streak_calculator.dart` | Story streak variant |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart` | Detective stats |

## Acceptance criteria

- [ ] Completing a case adds points to current week's entry
- [ ] Leaderboard shows top players and requesting user's rank
- [ ] Streak increments on consecutive daily story completions
- [ ] Dashboard reflects updated stats after case complete

## Testing notes

- Test week rollover: case completed Sunday vs Monday
- Emulator: two users, verify ordering by points
- Streak break: miss a day → streak resets

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- Separate story streak from daily Wordle streak?
- Minimum cases to appear on public leaderboard?
