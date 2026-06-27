# Phase 7 — Atmosphere (Visual & Audio)

> **Status:** Complete  
> **Last updated:** 2026-06-27  
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

- [x] **Step 7.1** — Noir theme: dark palette + typewriter/serif font for story screens
- [x] **Step 7.2** — `TypewriterText` widget — character-by-character reveal
- [x] **Step 7.3** — Tile flip/animate enhancements (`flutter_animate` added; existing tile animations retained)
- [x] **Step 7.4** — `StoryAudioManager` — rain loop, key clicks, win/fail via `just_audio`
- [x] **Step 7.5** — Apply story theme only to `/story/*` routes (don't affect daily game)

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Theme scope | Route-level `Theme` override | Isolate noir from main app | 2026-06-27 |
| Audio assets | `assets/audio/` | Optional MP3 files; manager no-ops if missing | 2026-06-27 |
| Animation lib | `flutter_animate` in pubspec | Available for future tile polish; daily tiles unchanged | 2026-06-27 |
| Mute preference | SharedPreferences `story_audio_muted` | Simple client-side toggle hook | 2026-06-27 |

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
| `lib/features/story_mode/presentation/theme/story_theme.dart` | New — `StoryTheme.dark()` |
| `lib/features/story_mode/presentation/widgets/typewriter_text.dart` | New — skippable, reduced-motion aware |
| `lib/features/story_mode/presentation/utils/story_audio_manager.dart` | New — rain, key, win/fail |
| `lib/features/story_mode/presentation/widgets/story_mode_widgets.dart` | Theme wrapper + typewriter on narrative scaffold |
| `lib/features/story_mode/presentation/pages/story_home_page.dart` | Typewriter on intro text |
| `assets/audio/` | Placeholder dir (`.gitkeep`); MP3s added manually |
| `pubspec.yaml` | Added `flutter_animate`, `just_audio` |

## Acceptance criteria

- [x] Story screens visually distinct from daily Wordle (noir feel)
- [x] Intro and reactions use typewriter effect (skippable)
- [x] Rain plays on story flow; stops on exit (when `assets/audio/rain_loop.mp3` present)
- [x] Win/fail sound on clue complete (wired in `StoryClueBloc`; assets optional)
- [x] Keyboard click on story Wordle keys
- [x] Story board fade-in via `flutter_animate`
- [x] Daily game appearance unchanged

## Testing notes

- Test audio with silent mode / iOS audio session
- Performance: typewriter on long text blocks
- Accessibility: reduce motion option disables typewriter

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-27 | 7.1–7.5 | Noir theme, typewriter, audio manager, route-level theme via `StoryModeShell` |

## Open questions / blockers

- User setting to mute story audio? → **Done:** Settings → Story audio toggle (`StoryAudioSettingTile`)
- Haptic feedback on tile flip? → **Deferred**
