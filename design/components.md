# Component inventory — PSC Crossword

Build these once (Flutter widgets in `lib/features/crossword/presentation/widgets/` or `lib/shared/presentations/widgets/` if reused) and mirror them as Figma components with the same names. Tokens use the `crossword.` prefix.

| Component | Variants / states | Key tokens | Used on |
| --- | --- | --- | --- |
| `StreakChip` | default · zero | `accent.streak`, `accent.streakBg`, radius `chip` | Home, Results |
| `LanguageToggle` | EN active · ML active · ML disabled (phase 1) | `bg.surface`, `border.default` | Home |
| `DailyPuzzleCard` | new · in progress · solved · unavailable · loading | `bg.surface`, `accent.glow`, `accent.button` | Home |
| `CategoryTile` | default · new · loading | `bg.surface`, `border.subtle`, category colour | Home |
| `ProgressBar` | thin (4) · level (6) | category colour / `accent.hint` | Home, Results |
| `CrosswordCell` | empty · filled · word · cursor · correct · wrong · revealed · block; with/without number | `grid.*`, `cellLetter`, `cellNumber`, radius `cell` | Puzzle, Hints |
| `CrosswordGrid` | rows × cols up to 15; read-only (preview) | `size.gridGap` | Puzzle, admin preview |
| `ClueBar` | default · first/last (chevron disabled) | `clueBar.*` | Puzzle |
| `ClueChip` | default · filled · active | `status.success*`, `accent.hint` | Puzzle |
| `KeyboardKey` | letter · action (CHECK) · delete · pressed · disabled | `key.*`, `size.key` | Puzzle |
| `TimerChip` | running · paused | `bg.surface`, `border.default` | Puzzle |
| `HintButton` | with badge · zero balance | `accent.hint`, `accent.hintStrong` | Puzzle |
| `BottomSheet` | handle, header, close | `bg.sheet`, `bg.scrim`, radius `sheet` | Hints |
| `HintOption` | free · paid · insufficient · expanded (clue shown) | `clueBar.*`, `status.success*` | Hints |
| `StatTile` | neutral · XP · streak | `bg.surface`, `accent.hint`, `accent.streak` | Results |
| `MistakeCard` | typed-wrong · revealed | `status.error*`, `status.warn*`, `accent.primary` tiles | Results, Revise |
| `PrimaryButton` / `SecondaryButton` | default · pressed · disabled · loading | `accent.button`, `border.default`, radius `button`, height 48–50 | everywhere |

Rules: min touch 44 × 44; icon-only buttons need a semantics label; no colour-only meaning (correct/wrong cells also differ in lightness, and wrong letters are announced by screen readers).
