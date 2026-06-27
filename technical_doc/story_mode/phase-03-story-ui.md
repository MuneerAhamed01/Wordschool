# Phase 3 — Story Flow UI

> **Status:** Complete  
> **Last updated:** 2026-06-22  
> **Owner:** —  
> **Depends on:** Phase 2  
> **Blocks:** Phase 4, Phase 5  

## Goal

Build the narrative screen flow that guides players from case intro through each clue's hint, investigation, and reaction, ending at case resolution.

## Scope

### In scope

- Route map for full story flow
- Five screen types: intro, hint, investigate, reaction, resolution
- Sequential clue gating (clue N+1 locked until clue N resolved)
- Navigation wired to `StoryCaseBloc` / future progress BLoC

### Out of scope (deferred)

- Wordle grid implementation details (Phase 4)
- Scoring display (Phase 5)
- Noir theme polish (Phase 7)

## Steps checklist

- [x] **Step 3.1** — Define screen map and GoRouter routes under `/story/...`
- [x] **Step 3.2** — Case Introduction screen (title + intro narrative)
- [x] **Step 3.3** — Story Hint screen (clue-specific hint)
- [x] **Step 3.4** — Investigate Prompt screen (CTA → Wordle)
- [x] **Step 3.5** — Story Reaction screen (post-puzzle narrative)
- [x] **Step 3.6** — Case Resolution screen (final story + outcome placeholder)
- [x] **Step 3.7** — Sequential gating: block advance until current clue criteria met

## Screen flow

```
/story/intro
    ↓
/story/clue/:index/hint
    ↓
/story/clue/:index/investigate
    ↓
/story/clue/:index/wordle      (Phase 4)
    ↓
/story/clue/:index/reaction
    ↓
(repeat for clues 0, 1, 2)
    ↓
/story/resolution
```

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Router | `go_router` nested routes | Consistent with `app_router.dart` | 2026-06-22 |
| State holder | Separate `StoryFlowBloc` + `StoryCaseBloc` | Keeps load vs flow progress separate for Phase 4 writes | 2026-06-22 |
| Text presentation | Plain text v1; typewriter in Phase 7 | Ship flow first | 2026-06-22 |
| Completed case UX | Read-only narrative replay; Wordle route redirects to reaction | Per product choice | 2026-06-22 |
| Entry | Keep `/story` preview; Begin pushes into flow | Per product choice | 2026-06-22 |
| BLoC codegen | Sealed classes for `StoryFlowBloc` | Avoids extra build_runner surface for flow-only state | 2026-06-22 |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/core/routes/app_router.dart` | Story ShellRoute + nested routes |
| `lib/features/story_mode/presentation/pages/case_intro_page.dart` | New |
| `lib/features/story_mode/presentation/pages/story_hint_page.dart` | New |
| `lib/features/story_mode/presentation/pages/investigate_prompt_page.dart` | New |
| `lib/features/story_mode/presentation/pages/story_reaction_page.dart` | New |
| `lib/features/story_mode/presentation/pages/case_resolution_page.dart` | New |
| `lib/features/story_mode/presentation/pages/story_wordle_stub_page.dart` | New — Phase 3 stub |
| `lib/features/story_mode/presentation/pages/story_home_page.dart` | Begin / Continue / Replay CTA |
| `lib/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart` | New |
| `lib/features/story_mode/presentation/routing/story_flow_gating.dart` | New |
| `lib/features/story_mode/presentation/routing/story_flow_redirect.dart` | New |
| `lib/features/story_mode/presentation/widgets/story_mode_widgets.dart` | New — shell + shared scaffold |
| `lib/features/story_mode/presentation/utils/clue_type_labels.dart` | New |
| `test/features/story_mode/presentation/bloc/story_flow_bloc_test.dart` | New |
| `test/features/story_mode/presentation/routing/story_flow_gating_test.dart` | New |
| `test/features/story_mode/presentation/routing/story_flow_navigation_test.dart` | New |

## Acceptance criteria

- [x] User can navigate full flow with seeded case (Wordle can be stubbed)
- [x] Cannot skip to clue 2 before clue 1 completes
- [x] Back navigation does not corrupt clue index
- [x] Resolution screen reachable after clue 3 reaction

## Testing notes

- Navigation integration test through full flow with mock bloc — **done**
- Unit tests for `StoryFlowBloc` and gating helpers — **done**
- Manual walkthrough with 3-clue seed data — **manual**

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-22 | Steps 3.1–3.7 | ShellRoute, five narrative screens, Wordle stub, StoryFlowBloc gating, tests |

## Open questions / blockers

- ~~Allow re-read of intro/hints after completion, or lock as read-only?~~ → Read-only replay allowed; Wordle skipped
- ~~Single `StoryFlowBloc` vs separate blocs per screen?~~ → Single `StoryFlowBloc` alongside `StoryCaseBloc`
