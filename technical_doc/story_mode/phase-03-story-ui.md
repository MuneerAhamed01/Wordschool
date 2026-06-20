# Phase 3 — Story Flow UI

> **Status:** Not started  
> **Last updated:** —  
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

- [ ] **Step 3.1** — Define screen map and GoRouter routes under `/story/...`
- [ ] **Step 3.2** — Case Introduction screen (title + intro narrative)
- [ ] **Step 3.3** — Story Hint screen (clue-specific hint)
- [ ] **Step 3.4** — Investigate Prompt screen (CTA → Wordle)
- [ ] **Step 3.5** — Story Reaction screen (post-puzzle narrative)
- [ ] **Step 3.6** — Case Resolution screen (final story + outcome placeholder)
- [ ] **Step 3.7** — Sequential gating: block advance until current clue criteria met

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
| Router | `go_router` nested routes | Consistent with `app_router.dart` | — |
| State holder | `StoryFlowBloc` or extend `StoryCaseBloc` | TBD when implementing | — |
| Text presentation | Plain text v1; typewriter in Phase 7 | Ship flow first | — |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/core/routes/app_router.dart` | Story routes |
| `lib/features/story_mode/presentation/pages/case_intro_page.dart` | New |
| `lib/features/story_mode/presentation/pages/story_hint_page.dart` | New |
| `lib/features/story_mode/presentation/pages/investigate_prompt_page.dart` | New |
| `lib/features/story_mode/presentation/pages/story_reaction_page.dart` | New |
| `lib/features/story_mode/presentation/pages/case_resolution_page.dart` | New |
| `lib/features/story_mode/presentation/bloc/story_flow_bloc.dart` | New |

## Acceptance criteria

- [ ] User can navigate full flow with seeded case (Wordle can be stubbed)
- [ ] Cannot skip to clue 2 before clue 1 completes
- [ ] Back navigation does not corrupt clue index
- [ ] Resolution screen reachable after clue 3 reaction

## Testing notes

- Navigation integration test through full flow with mock bloc
- Manual walkthrough with 3-clue seed data

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- Allow re-read of intro/hints after completion, or lock as read-only?
- Single `StoryFlowBloc` vs separate blocs per screen?
