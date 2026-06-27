# Phase 2 — App: Load Today's Case

> **Status:** Complete  
> **Last updated:** 2026-06-22  
> **Owner:** —  
> **Depends on:** Phase 0, Phase 1 (or dev seed)  
> **Blocks:** Phase 3, Phase 4  

## Goal

Wire the Flutter app to fetch today's detective case from Firestore, expose it through clean architecture layers, and add a dashboard entry point.

## Scope

### In scope

- Repository + data source for `detectiveCases`
- Use cases and BLoC for case loading
- Dashboard tile / navigation to story flow
- Error and empty states

### Out of scope (deferred)

- Story screens (Phase 3)
- Wordle gameplay (Phase 4)
- Progress persistence (Phase 4)

## Steps checklist

- [x] **Step 2.1** — `StoryCaseRepository` + Firestore data source (`getTodayCase`, optional stream)
- [x] **Step 2.2** — `LoadTodayDetectiveCaseUseCase`
- [x] **Step 2.3** — `StoryCaseBloc` — states: `loading`, `loaded`, `error`, `alreadyCompleted`
- [x] **Step 2.4** — Dashboard entry: "Detective Case" tile gated by Remote Config or dev flag

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Date key source | Shared `date_helper` / UTC | Consistent with daily game | 2026-06-18 |
| DI registration | `get_it` in `di.dart` | Matches existing app pattern | 2026-06-22 |
| Feature flag | Remote Config `story_mode_enabled` | Gradual rollout | 2026-06-22 |
| Remote Config init | Pulled forward from Phase 10 | Dashboard gating required for Phase 2 | 2026-06-22 |
| Progress read | Read-only in load use case | Enables `alreadyCompleted` without Phase 4 writes | 2026-06-22 |
| Data source layout | Abstract + `remote/` impl | Matches game feature pattern | 2026-06-22 |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/core/remote_config/story_mode_config.dart` | New — Remote Config wrapper |
| `lib/features/story_mode/data/data_source/story_case_service.dart` | New |
| `lib/features/story_mode/data/data_source/remote/story_case_service.dart` | New — Firestore impl |
| `lib/features/story_mode/data/repositories/story_case_repository_impl.dart` | New |
| `lib/features/story_mode/domain/repositories/story_case_repository.dart` | New |
| `lib/features/story_mode/domain/usecases/load_today_detective_case.dart` | New |
| `lib/features/story_mode/domain/usecases/today_detective_case_result.dart` | New |
| `lib/features/story_mode/presentation/bloc/story_case_bloc/` | New |
| `lib/features/story_mode/presentation/pages/story_home_page.dart` | Load/error/loaded states |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart` | Add story entry |
| `lib/core/routes/app_router.dart` | BlocProvider for story route |
| `lib/di.dart` | Register story + Remote Config dependencies |
| `pubspec.yaml` | Add `firebase_remote_config` |
| `test/features/story_mode/data/repositories/story_case_repository_impl_test.dart` | New |
| `test/features/dashboard/presentation/pages/dashboard_page_test.dart` | New |

## BLoC state sketch

```
StoryCaseState
├── initial
├── loading
├── loaded(DetectiveCase case, StoryModeProgress? progress)
├── alreadyCompleted(DetectiveCase case, StoryModeProgress progress)
└── error(String message)
```

## Acceptance criteria

- [x] App loads today's case when document exists in Firestore
- [x] Friendly error when no case exists for today
- [x] Dashboard shows story entry only when feature enabled
- [x] Loading state shown while fetching

## Testing notes

- Widget test: dashboard tile visible when flag on — **done**
- Repository test with mocked data source — **done**
- Manual test against seeded case from Phase 1 — **manual** (set RC `story_mode_enabled=true`, seed `detectiveCases/{todayUtcDateId}`)

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-22 | Steps 2.1–2.4 | Data layer, use case, BLoC, RC-gated dashboard tile, StoryHomePage load states, tests |

## Open questions / blockers

- Cache today's case locally for offline read?
- Show "case unlocks at midnight" when tomorrow's case not yet generated?
