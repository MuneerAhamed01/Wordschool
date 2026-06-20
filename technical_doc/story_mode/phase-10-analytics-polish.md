# Phase 10 — Analytics & Polish

> **Status:** Not started  
> **Last updated:** —  
> **Owner:** —  
> **Depends on:** Phases 0–9 (incremental — start after Phase 5 MVP)  
> **Blocks:** Production launch  

## Goal

Instrument Story Mode with analytics, harden edge cases, complete QA, and enable gradual rollout via Remote Config.

## Scope

### In scope

- Firebase Analytics custom events
- Error handling: no case, offline, timezone boundaries
- QA checklist and launch criteria
- Remote Config rollout flag
- Performance and crash monitoring review

### Out of scope (deferred)

- Push notifications (future roadmap)
- A/B test framework

## Steps checklist

- [ ] **Step 10.1** — Analytics events (see list below)
- [ ] **Step 10.2** — Edge cases: no case today, offline cache, resume mid-case, date rollover
- [ ] **Step 10.3** — QA checklist execution and sign-off
- [ ] **Step 10.4** — Remote Config rollout: `story_mode_enabled`, staged % rollout

## Analytics events

| Event | When |
| ----- | ---- |
| `story_case_started` | User opens intro for today's case |
| `story_clue_started` | User begins a clue Wordle |
| `story_clue_solved` | Clue solved (param: attempts) |
| `story_clue_failed` | 6 guesses exhausted |
| `story_case_completed` | Resolution reached (param: outcome, score) |
| `story_share_tapped` | Share button pressed |
| `story_hint_used` | Hint consumed (param: source: iap/rewarded) |

## QA checklist

- [ ] New user: full case flow 0 → resolution
- [ ] Resume mid-clue after app kill
- [ ] Resume mid-case between clues
- [ ] All 4 outcomes display correctly
- [ ] Max score 300 achievable
- [ ] Completed case cannot replay same day
- [ ] Midnight UTC/local rollover behavior documented and tested
- [ ] Feature flag off hides all story entry points
- [ ] No regression on daily Wordle or archive modes
- [ ] Firestore rules block cheating (writing case answers)

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Analytics | `firebase_analytics` | Per fulldoc.md | — |
| Rollout | Remote Config percentage | Safe gradual release | — |
| Case rollover TZ | Document in Phase 0 decision | Single source of truth | — |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `pubspec.yaml` | Add `firebase_analytics`, `firebase_remote_config` |
| `lib/features/story_mode/presentation/analytics/story_analytics.dart` | New |
| `lib/main.dart` | Remote Config init |
| `technical_doc/story_mode/README.md` | Mark phases complete at launch |

## Launch criteria

- [ ] MVP or full 3-clue loop passes QA checklist
- [ ] At least 7 days of seeded/generated cases in staging
- [ ] Analytics events verified in DebugView
- [ ] Crash-free sessions target met in internal testing
- [ ] App Store / Play listing copy updated (if shipping publicly)

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- Crashlytics custom keys for story flow step?
- Beta cohort before 100% rollout?
