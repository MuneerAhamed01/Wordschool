# Detective Wordle (Story Mode) — Implementation Tracker

Living documentation for building Story Mode. Product requirements live in [fulldoc.md](./fulldoc.md). Each phase has its own doc with checklists, decisions, and a completion log — **update the relevant phase doc and this README after every completed step**.

---

## Status dashboard

| Phase | Doc | Status | Progress | Last updated |
| ----- | --- | ------ | -------- | ------------ |
| 0 — Foundation | [phase-00-foundation.md](./phase-00-foundation.md) | Complete | 4/4 steps | 2026-06-18 |
| 1 — Backend | [phase-01-backend.md](./phase-01-backend.md) | Complete | 6/6 steps | 2026-06-21 |
| 2 — Load case | [phase-02-load-case.md](./phase-02-load-case.md) | Complete | 4/4 steps | 2026-06-22 |
| 3 — Story UI | [phase-03-story-ui.md](./phase-03-story-ui.md) | Complete | 7/7 steps | 2026-06-22 |
| 4 — Wordle clues | [phase-04-wordle-clues.md](./phase-04-wordle-clues.md) | Complete | 5/5 steps | 2026-06-25 |
| 5 — Scoring & outcomes | [phase-05-scoring-outcomes.md](./phase-05-scoring-outcomes.md) | Not started | 0/5 steps | — |
| 6 — Leaderboards | [phase-06-leaderboards.md](./phase-06-leaderboards.md) | Not started | 0/5 steps | — |
| 7 — Atmosphere | [phase-07-atmosphere.md](./phase-07-atmosphere.md) | Not started | 0/5 steps | — |
| 8 — Sharing | [phase-08-sharing.md](./phase-08-sharing.md) | Not started | 0/2 steps | — |
| 9 — Monetization | [phase-09-monetization.md](./phase-09-monetization.md) | Not started | 0/4 steps | — |
| 10 — Analytics & polish | [phase-10-analytics-polish.md](./phase-10-analytics-polish.md) | Not started | 0/4 steps | — |

**Overall:** 26 / 51 steps complete

---

## MVP slice (ship first)

Smallest playable loop before full feature:

1. Hardcoded case in Firestore (skip Claude + scheduler)
2. Story intro → 1 Wordle clue → reaction → resolution
3. Basic scoring for that clue
4. Save progress to Firestore
5. Dashboard entry point

Full 3-clue loop, AI generation, leaderboard, audio, share, and ads follow in later phases.

---

## Phase dependencies

```
Phase 0 (Foundation)
    ↓
Phase 1 (Backend) ──→ Phase 2 (Load case)
                            ↓
              Phase 3 (Story UI) + Phase 4 (Wordle clues)
                            ↓
                    Phase 5 (Scoring)
                            ↓
              Phase 6 (Leaderboards) + Phase 8 (Sharing)
                            ↓
         Phase 7 (Atmosphere) + Phase 9 (Monetization)
                            ↓
                  Phase 10 (Analytics & polish)
```

---

## How to update docs after completing work

1. Open the phase doc (e.g. `phase-02-load-case.md`).
2. Check off the completed step(s) in **Steps checklist**.
3. Add a row to **Completion log** with date, step name, and brief notes.
4. Set **Status** and **Last updated** at the top of that phase doc.
5. Update the **Status dashboard** table above (progress count, status, date).
6. Add a line to **Changelog** below.
7. Record non-obvious choices in **Technical decisions** on the phase doc.

---

## Changelog

| Date | Change |
| ---- | ------ |
| 2026-06-25 | Phase 4 complete — real Wordle per clue, Firestore progress writes, restore, win/fail navigation |
| 2026-06-22 | Phase 3 complete — story flow routes, five narrative screens, Wordle stub, StoryFlowBloc gating, tests |
| 2026-06-22 | Phase 2 complete — Firestore case load, StoryCaseBloc, Remote Config gating, dashboard tile |
| 2026-06-21 | Phase 1 complete — Cloud Functions, Cursor API generation, validation, scheduled job, seed tools |
| 2026-06-18 | Phase 0 complete — entities, Firestore schema/rules, `/story` route, unit tests |
| 2026-06-18 | Initial phase documentation scaffold created (README + phases 0–10). |

---

## Existing codebase (reuse)

| Area | Path / notes |
| ---- | ------------ |
| Wordle engine | `lib/features/game/presentation/bloc/word_cubit/` |
| Game BLoC & page | `lib/features/game/presentation/` |
| Firebase collections | `lib/core/firebase/collections.dart` |
| User game state | `lib/shared/domains/entities/user_game_state/` |
| Leaderboard | `lib/features/leaderboard/` |
| Dashboard entry | `lib/features/dashboard/` |
| Audio (partial) | `just_audio` in `pubspec.yaml` |
| Story mode foundation | `lib/features/story_mode/` — entities, models, data layer, BLoC, story flow UI (Phase 0–3) |
| Story mode backend | `functions/` — `generateDailyCase`, `seedDetectiveCase`, validation, seed script |
| Remote Config | `lib/core/remote_config/story_mode_config.dart` — `story_mode_enabled` flag |

**Not yet in app:** ads/IAP, `share_plus`, scoring/outcomes UI (Phase 5).
