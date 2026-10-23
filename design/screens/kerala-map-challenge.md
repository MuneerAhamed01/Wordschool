# Kerala Map Challenge — Screen Specs (Phase 2, after Crossword release)

> Frame **393 × 852** (iPhone 15). Light Material theme. Tokens: `design/tokens/kerala-map-challenge.tokens.json` (prefix `mapChallenge.`).
> Prototype (live — River, Ghats and Build are playable): https://claude.ai/artifact/Nuv4ytQmPFN1GsBBmDqX2E · Source: `design/prototypes/kerala-map-challenge/`
> Map data: `design/assets/kerala-map/` · Tasks: MAP-001 – MAP-006 (backlog)

**Status: parked.** Don't build until Phase 1 ships. This file records what the design decided.

Flow: **Game Home → Mode → Mission → Interact with map → Feedback → Results + PSC facts → Next challenge**

---

## 1. Game Home

- Header: "WordSchool PSC · Geography" overline, **Kerala Map Challenge** title, avatar (44).
- Progress card: level circle (48) + level name + XP bar · 4 badge slots (2 earned, 2 locked/dashed) · "Badges 2 / 12" · streak chip.
- Daily challenge card (`primary.container`): target icon, "DAILY CHALLENGE · ENDS IN 6H", task line, "+40 XP".
- Three large mode cards (104 thumbnails, real map art): **Draw the River** (Periyar on terrain, "4 / 12 rivers") · **Explore the Western Ghats** (ridges illustration, "1 / 5 found") · **Build Kerala** (outline + lifted Idukki piece, "Best 8 / 14"). Each card has a play button (40).
- Bottom nav (80, Material 3 style, pill on active): Maps · Revise · Badges · Ranks.

## 2. Draw the River

- Header: back · "Draw the River" · "River 5 of 12 · Central Kerala" · timer chip.
- Mission card: "Trace the Periyar to the Arabian Sea" + instruction.
- Map (361 × 441, radius 20): sea `water.sea`, neighbour states hatched `terrain.neighbourLand`, Kerala lowland → highland bands, Vembanad lake, labels (Arabian Sea, Western Ghats, Kochi), scale bar.
- Source pin (white ring, river blue) · numbered checkpoints (Mullaperiyar Dam → Idukki Dam → Bhoothathankettu → Aluva → river mouth); reached = green with ✓.
- Drawing: finger path; on-route segments solid river blue, off-route segments dashed `status.offRoute`. Tolerance ≈ 9 map units from the true route; a checkpoint counts when the line passes within ≈ 11 units, in order.
- Live feedback chip (top of map): "On route · 94% accurate" (success) / "Off route — head north-west toward Idukki Dam" (off-route colours) / "Start at the source pin" (warn).
- Checkpoint stepper under the map (5 steps).
- Buttons: Undo stroke · Restart · Show path (−5 XP).
- Completion sheet: accuracy · +XP · time · PSC fact (river length, Aluva split) · Play again / See results.

## 3. Explore the Western Ghats

- Header with "Challenge n of 5" and XP chip; 5-segment progress bar.
- Challenge card: "Locate Anamudi, the highest peak in South India".
- Terrain map zoomed Palakkad Gap → Idukki: relief bands, contour lines, small peak glyphs, legend (Highland / Midland / Lowland).
- Landmark buttons (44 targets, 28 visible): peaks (triangle) and passes/gaps (pass glyph). Unknown until tapped.
- Tap → info panel: verdict chip (Correct +20 XP / Not this one / Already found) · name · height or width · kind · PSC fact. Wrong taps still teach.
- V1 landmarks: Anamudi (2,695 m) · Meesapulimala (2,640 m) · Palakkad Gap (30–40 km) · Bodinayakkanur Pass · Nelliampathy Hills. **Verify all heights/positions against a source before shipping.**

## 4. Build Kerala

- Header + progress bar "8 / 14" + miss counter.
- Board: Kerala outline with 14 dashed district slots (real DataMeet shapes), neighbour state labels, north arrow.
- Tray: 3-column grid of district pieces (shape thumbnail + name); selected piece lifts with a shadow and amber border.
- Interaction: drag piece onto slot (device); tap piece → tap slot (fallback, accessibility). Correct → fills with district colour + label; wrong → slot flashes red, miss +1, location hint ("It sits at the Palakkad Gap, between Malappuram and Thrissur").
- Completion sheet: districts north → south, largest (Palakkad) / smallest (Alappuzha) by area, XP, Play again / See results.

## 5. Results

- Score hero with accuracy ring · Accuracy · XP · Time tiles · "Route completed" mini map with checkpoint list and badge progress · 3 PSC revision facts (saved to Revise) · Play again / Next challenge.

---

## Data notes for MAP-001

- Map geometry ships with the app (`kerala-map-paths.json`, ~20 KB). Firestore stores only challenge definitions (route points, checkpoints, landmark ids, facts) and progress.
- Scoring (accuracy %, checkpoint order) must be recomputed server-side in `submitMapChallenge` from the submitted path (downsampled to ≤ 200 points).
