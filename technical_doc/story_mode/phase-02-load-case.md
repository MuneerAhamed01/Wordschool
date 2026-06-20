# Phase 2 — App: Load Today's Case

> **Status:** Not started  
> **Last updated:** —  
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

- [ ] **Step 2.1** — `StoryCaseRepository` + Firestore data source (`getTodayCase`, optional stream)
- [ ] **Step 2.2** — `LoadTodayDetectiveCaseUseCase`
- [ ] **Step 2.3** — `StoryCaseBloc` — states: `loading`, `loaded`, `error`, `alreadyCompleted`
- [ ] **Step 2.4** — Dashboard entry: "Detective Case" tile gated by Remote Config or dev flag

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Date key source | Shared `date_helper` / UTC | Consistent with daily game | — |
| DI registration | `get_it` in `di.dart` | Matches existing app pattern | — |
| Feature flag | Remote Config `story_mode_enabled` | Gradual rollout | — |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/features/story_mode/data/data_source/story_case_service.dart` | New |
| `lib/features/story_mode/data/repositories/story_case_repository_impl.dart` | New |
| `lib/features/story_mode/domain/repositories/story_case_repository.dart` | New |
| `lib/features/story_mode/domain/usecases/load_today_detective_case.dart` | New |
| `lib/features/story_mode/presentation/bloc/story_case_bloc.dart` | New |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart` | Add story entry |
| `lib/di.dart` | Register story dependencies |

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

- [ ] App loads today's case when document exists in Firestore
- [ ] Friendly error when no case exists for today
- [ ] Dashboard shows story entry only when feature enabled
- [ ] Loading state shown while fetching

## Testing notes

- Widget test: dashboard tile visible when flag on
- Repository test with mocked Firestore
- Manual test against seeded case from Phase 1

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- Cache today's case locally for offline read?
- Show "case unlocks at midnight" when tomorrow's case not yet generated?
