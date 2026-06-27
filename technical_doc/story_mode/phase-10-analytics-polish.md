# Phase 10 — Analytics & Polish

> **Status:** Complete  
> **Last updated:** 2026-06-27  
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

- [x] **Step 10.1** — Analytics events (see list below)
- [x] **Step 10.2** — Edge cases: no case today, offline defaults, resume mid-case, date rollover
- [x] **Step 10.3** — QA checklist documented in `manual-testing-scenarios.md`
- [x] **Step 10.4** — Remote Config rollout: `story_mode_enabled` + `story_mode_rollout_percent`

## Analytics events

| Event | When | Wired |
| ----- | ---- | ----- |
| `story_case_started` | User continues from case intro | `CaseIntroPage` |
| `story_clue_started` | User begins a clue Wordle | `StoryClueBloc` |
| `story_clue_solved` | Clue solved (param: attempts) | `StoryClueBloc` |
| `story_clue_failed` | All guesses exhausted | `StoryClueBloc` |
| `story_case_completed` | Resolution reached (param: outcome, score) | `CaseResolutionPage` |
| `story_share_tapped` | Share button pressed | `CaseResolutionPage` |
| `story_hint_used` | Hint letter reveal (param: source) | `StoryHintPage` |

## QA checklist

Documented in [`manual-testing-scenarios.md`](./manual-testing-scenarios.md). Execute manually before production sign-off:

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
| Analytics | `firebase_analytics` via `AnalyticsService` + `StoryAnalytics` | Facade pattern | 2026-06-27 |
| Rollout | Remote Config `story_mode_rollout_percent` + UID hash | Safe gradual release | 2026-06-27 |
| Case rollover TZ | UTC date IDs (Phase 0) | Single source of truth | 2026-06-27 |
| No-case UX | Friendly message from data source | "Today's detective case isn't ready yet" | 2026-06-27 |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/core/analytics/analytics_service.dart` | Story event methods |
| `lib/core/analytics/analytics_events.dart` | Story event names + params |
| `lib/features/story_mode/presentation/analytics/story_analytics.dart` | New — thin helpers |
| `lib/core/remote_config/story_mode_config.dart` | `isEnabledForUser()`, rollout percent |
| `lib/features/story_mode/presentation/routing/story_mode_feature_gate.dart` | RC gate on `/story/*` |
| `lib/features/settings/presentation/widgets/story_settings_tiles.dart` | Audio mute + IAP purchase tiles |
| `technical_doc/story_mode/manual-testing-scenarios.md` | QA test cases |
| `technical_doc/story_mode/manual-configuration-setup.md` | Deploy + RC setup |
| `technical_doc/story_mode/feature-completed.md` | Full phase 6–10 summary |

## Launch criteria

- [ ] MVP or full 3-clue loop passes QA checklist (manual sign-off pending)
- [ ] At least 7 days of seeded/generated cases in staging
- [ ] Analytics events verified in DebugView
- [ ] Crash-free sessions target met in internal testing
- [ ] App Store / Play listing copy updated (if shipping publicly)

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-27 | 10.1–10.4 | Analytics wired, rollout RC, QA docs created |

## Open questions / blockers

- Crashlytics custom keys for story flow step? → **Deferred**
- Beta cohort before 100% rollout? → **Use** `story_mode_rollout_percent` in Remote Config
