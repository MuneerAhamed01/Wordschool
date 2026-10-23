# Kerala map geometry (Phase 2)

| File | What |
| --- | --- |
| `kerala-map-paths.json` | Simplified SVG paths: `state` outline, `coast`, eastern `border`, terrain bands (`mid`, `high`, `peak`), `contours`, `vembanad`, and 14 `districts` with label points and bounds |
| `landmarks.json` | Approximate projected points: Periyar route, peaks, passes, dams, towns |
| `build_map_paths.py` | Script that produced the paths (needs `pip install shapely`) |

**Coordinates.** Equirectangular projection: `x = (lon − 74.80) × 100 × 0.983`, `y = (12.85 − lat) × 100`. `kerala-map-paths.json` is scaled **×2** (Kerala ≈ 512 × 912 units); `landmarks.json` is **×1** — multiply by 2 to overlay. Paths use relative integer commands (`M x y l dx dy … z`) and drop straight into SVG `d` or Flutter's `path_drawing` `parseSvgPathData`.

**Accuracy.** District and state shapes are real boundaries, simplified. **Terrain bands are stylised** (distance from the eastern border, Palakkad Gap cut by hand), not elevation data. **Landmark points and the Periyar route are approximate** — replace with surveyed data (e.g. a river dataset and verified peak coordinates) before shipping MAP-003/004.

**Source and licence.** Boundaries from [geohacker/kerala](https://github.com/geohacker/kerala), based on DataMeet maps. Confirm the licence terms and add attribution in the app's About screen before release.

Rebuild:

```bash
git clone --depth 1 https://github.com/geohacker/kerala.git /tmp/kerala
pip install shapely
python3 build_map_paths.py /tmp/kerala/geojsons kerala-map-paths.json
```
