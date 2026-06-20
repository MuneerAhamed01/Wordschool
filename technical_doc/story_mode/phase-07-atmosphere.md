# Phase 7 — Atmosphere (Visual & Audio)

> **Status:** Not started  
> **Last updated:** —  
> **Owner:** —  
> **Depends on:** Phase 3 (screens exist)  
> **Blocks:** —  

## Goal

Deliver the noir detective feel: dark UI, typewriter story text, polished tile animations, and ambient audio.

## Scope

### In scope

- Noir theme tokens (colors, typography)
- Typewriter text effect for narrative blocks
- Enhanced Wordle tile animations
- Audio: rain ambient, keyboard clicks, win/fail SFX
- Text-first, minimal image design

### Out of scope (deferred)

- AI-generated artwork (future roadmap)
- Custom illustrations per case

## Steps checklist

- [ ] **Step 7.1** — Noir theme: dark palette + typewriter/serif font for story screens
- [ ] **Step 7.2** — `TypewriterText` widget — character-by-character reveal
- [ ] **Step 7.3** — Tile flip/animate enhancements (`flutter_animate` if needed)
- [ ] **Step 7.4** — `StoryAudioManager` — rain loop, key clicks, win/fail via `just_audio`
- [ ] **Step 7.5** — Apply story theme only to `/story/*` routes (don't affect daily game)

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Theme scope | Route-level `Theme` override | Isolate noir from main app | — |
| Audio assets | `assets/audio/` | Already used by app | — |
| Animation lib | `flutter_animate` | Listed in fulldoc.md | — |

## Visual reference (fulldoc.md)

- Noir-inspired UI
- Typewriter text effect
- Animated Wordle tiles
- Minimal image-free design

## Audio reference (fulldoc.md)

- Ambient rain
- Keyboard clicks
- Tile animations (sync with audio)
- Victory / failure effects

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `lib/features/story_mode/presentation/theme/story_theme.dart` | New |
| `lib/features/story_mode/presentation/widgets/typewriter_text.dart` | New |
| `lib/features/story_mode/presentation/utils/story_audio_manager.dart` | New |
| `assets/audio/` | New SFX files |
| `pubspec.yaml` | Add `flutter_animate` if not present |

## Acceptance criteria

- [ ] Story screens visually distinct from daily Wordle (noir feel)
- [ ] Intro and reactions use typewriter effect (skippable)
- [ ] Rain plays on story flow; stops on exit
- [ ] Win/fail sound on clue complete
- [ ] Daily game appearance unchanged

## Testing notes

- Test audio with silent mode / iOS audio session
- Performance: typewriter on long text blocks
- Accessibility: reduce motion option disables typewriter

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- User setting to mute story audio?
- Haptic feedback on tile flip?
