# Design

Everything the app's look is built from. Screens are specified in Markdown so they live next to the code and can be reviewed in PRs; the live prototypes are the visual reference.

```
design/
  README.md                         ← this file
  components.md                     ← component inventory (names match Figma + Flutter)
  tokens/
    psc-crossword.tokens.json       ← dark theme (Phase 1)
    kerala-map-challenge.tokens.json← light Material theme (Phase 2)
  screens/
    psc-crossword.md                ← Home, Puzzle, Hints, Results, Revise
    kerala-map-challenge.md         ← parked until Phase 2
  prototypes/
    psc-crossword/*.dc.html         ← source of the live canvas (see links below)
    kerala-map-challenge/*.dc.html
  assets/kerala-map/                ← real Kerala map geometry for Phase 2
```

## Live prototypes

| Prototype | Link | Notes |
| --- | --- | --- |
| PSC Crossword (4 screens) | https://claude.ai/artifact/StzcyAzABQDwkWv9oPxG5H | Puzzle screen is playable |
| Kerala Map Challenge (5 screens) | https://claude.ai/artifact/Nuv4ytQmPFN1GsBBmDqX2E | River, Ghats and Build are playable |

The `.dc.html` files are the canvas source (they need the canvas runtime, so open the links rather than the files). Keep them for history and for regenerating screens.

**Where specs and prototype differ, the spec wins.** Known differences: filled buttons use `accent.button` `#467A41` (white text 5.1:1) instead of the tile green `#538D4E` (3.97:1 — fails AA for button-size text).

## Tokens → Flutter

| Token | Flutter |
| --- | --- |
| `crossword.color.bg.canvas` | `MyColors.gameBackground` |
| `crossword.color.bg.surface` | `MyColors.gameSurface` |
| `crossword.color.bg.surfaceRaised` | `MyColors.gameSurfaceElevated` |
| `crossword.color.border.default` | `MyColors.gameBorder` |
| `crossword.color.accent.primary` | `MyColors.tileCorrect` |
| `crossword.color.accent.hintStrong` | `MyColors.tilePresent` |
| `crossword.color.accent.glow` | `MyColors.accentGlow` |
| `crossword.color.accent.streak` | `MyColors.streakAccent` |
| everything else in `grid.*`, `clueBar.*`, `key.*`, `status.*` | add to `MyColors` with the token name (e.g. `crosswordWordBg`) in CW-046 |

## Using this with Figma

1. **Import tokens:** Figma → Tokens Studio plugin → *Load from file* → pick a `*.tokens.json` (W3C design-token format) → *Create variables*. Colours, radii, sizes and text styles become Figma variables/styles.
2. **Pages:** one page per screen file (`PSC Crossword`, `Kerala Map Challenge`), one frame per screen at the frame size in the spec, plus a `Components` page from `components.md`.
3. **Keep names identical** to `components.md` so devs can find the matching widget.
4. The Figma connector is available in Claude — ask Claude to "build the PSC Crossword screens in Figma from design/" to generate the file from these specs and tokens.

## Map data (Phase 2)

See `assets/kerala-map/README.md`.
