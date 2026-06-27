# Story Mode — Feature Completed (Phases 6–10)

> **Completed:** 2026-06-27  
> **Scope:** Leaderboards, atmosphere, sharing, monetization, analytics & polish

---

## Summary

Phases 6 through 10 of Story Mode are implemented. The app now tracks weekly detective leaderboard scores, applies a noir story theme with typewriter narrative and optional audio, supports native result sharing, includes ads/IAP infrastructure, and emits Firebase Analytics events with Remote Config rollout control.

---

## Phase 6 — Leaderboards & Progress

### Delivered

| Step | Description | Status |
| ---- | ----------- | ------ |
| 6.1 | Firestore model `detectiveLeaderboard/{yyyy-Www}/entries/{userId}` | Done |
| 6.2 | Cloud Function `updateDetectiveLeaderboard` on case completion | Done |
| 6.3 | Leaderboard UI with **Daily** (placeholder) + **Detective** tabs | Done |
| 6.4 | Story mode daily streak (already in Phase 5; integrated on dashboard) | Done |
| 6.5 | Dashboard detective stats panel (streak, weekly pts, total pts, rank) | Done |

### Key files

- `functions/src/updateDetectiveLeaderboard.ts` — server-side score aggregation
- `lib/core/utils/iso_week_id.dart` — ISO week ID (Mon–Sun UTC)
- `lib/features/leaderboard/` — data layer, bloc, UI
- `lib/shared/presentations/widgets/detective_stats_panel.dart`
- `firestore.rules` — read-only leaderboard access
- `firestore.indexes.json` — index on `entries.totalPoints`

### Schema

```
detectiveLeaderboard/{yyyy-Www}
  └── entries/{userId}
        ├── displayName: string
        ├── totalPoints: number
        ├── casesCompleted: number
        └── updatedAt: timestamp
```

---

## Phase 7 — Atmosphere (Visual & Audio)

### Delivered

| Step | Description | Status |
| ---- | ----------- | ------ |
| 7.1 | Noir theme tokens (`StoryTheme.dark()`) | Done |
| 7.2 | `TypewriterText` widget (skippable, respects reduced motion) | Done |
| 7.3 | Existing tile animations retained; `flutter_animate` added for future use | Done |
| 7.4 | `StoryAudioManager` (rain loop, key/win/fail SFX via `just_audio`) | Done |
| 7.5 | Route-level theme on `/story/*` via `StoryModeShell` | Done |

### Key files

- `lib/features/story_mode/presentation/theme/story_theme.dart`
- `lib/features/story_mode/presentation/widgets/typewriter_text.dart`
- `lib/features/story_mode/presentation/utils/story_audio_manager.dart`
- `lib/features/story_mode/presentation/widgets/story_mode_widgets.dart` — theme + typewriter on narrative scaffold

### Notes

- Audio assets are optional; the manager no-ops gracefully if files are missing under `assets/audio/`.
- Mute preference stored in SharedPreferences (`story_audio_muted`).

---

## Phase 8 — Sharing

### Delivered

| Step | Description | Status |
| ---- | ----------- | ------ |
| 8.1 | `share_plus` + `StoryShareFormatter` (outcome, score, emoji grids) | Done |
| 8.2 | Share button on case resolution screen | Done |

### Key files

- `lib/core/utils/wordle_guess_evaluator.dart` — shared emoji grid evaluation
- `lib/features/story_mode/presentation/utils/story_share_formatter.dart`
- `lib/features/story_mode/presentation/pages/case_resolution_page.dart`

### Share format

```
Detective Wordle — Case Closed 🕵️
Score: 240/300
Outcome: Case Closed

Clue 1 — Location
🟩⬛🟨🟩🟩
...
Play today's case in WordSchool
```

---

## Phase 9 — Monetization

### Delivered

| Step | Description | Status |
| ---- | ----------- | ------ |
| 9.1 | `google_mobile_ads` with AdMob test app IDs | Done |
| 9.2 | Banner (story home), interstitial (post-resolution), rewarded (hint API) | Done |
| 9.3 | `in_app_purchase` + product IDs + restore in Settings | Done |
| 9.4 | Hint consumption use case + entitlements on user state | Done |

### Key files

- `lib/core/monetization/ad_config.dart`, `ad_service.dart`, `iap_products.dart`, `iap_service.dart`, `story_entitlements.dart`
- `lib/features/story_mode/domain/usecases/consume_hint.dart`
- `lib/features/story_mode/presentation/widgets/story_banner_ad.dart`
- `lib/features/settings/presentation/pages/settings_page.dart` — Restore purchases
- `UserGameStateEntity` fields: `hintPackBalance`, `hasRemoveAds`, `isDetectivePro`

### IAP products (client IDs)

| Product ID | Benefit |
| ---------- | ------- |
| `wordschool_remove_ads` | No banner/interstitial |
| `wordschool_hint_pack_5` | +5 consumable hints |
| `wordschool_detective_pro_monthly` | Ad-free + unlimited hints |

---

## Phase 10 — Analytics & Polish

### Delivered

| Step | Description | Status |
| ---- | ----------- | ------ |
| 10.1 | Story analytics events wired | Done |
| 10.2 | Edge cases: no case message, offline defaults, completion lock | Done |
| 10.3 | QA checklist documented in `manual-testing-scenarios.md` | Done |
| 10.4 | Remote Config rollout: `story_mode_rollout_percent` | Done |

### Analytics events

| Event | Trigger |
| ----- | ------- |
| `story_case_started` | Continue on case intro |
| `story_clue_started` | Clue Wordle initialized |
| `story_clue_solved` | Clue completed (won) |
| `story_clue_failed` | Clue failed (6 guesses) |
| `story_case_completed` | Resolution screen shown |
| `story_share_tapped` | Share button pressed |
| `story_hint_used` | Hint consumed (API ready) |

### Key files

- `lib/features/story_mode/presentation/analytics/story_analytics.dart`
- `lib/core/analytics/analytics_service.dart` — extended facade
- `lib/core/remote_config/story_mode_config.dart` — `isEnabledForUser(userId)` with stable hash rollout

---

## Dependencies added (`pubspec.yaml`)

- `share_plus`
- `google_mobile_ads`
- `in_app_purchase`
- `flutter_animate`
- `just_audio`

---

## Deployment checklist

1. Deploy Cloud Function: `firebase deploy --only functions:updateDetectiveLeaderboard`
2. Deploy Firestore rules + indexes: `firebase deploy --only firestore`
3. Configure Remote Config keys (see `manual-configuration-setup.md`)
4. Add audio assets + production AdMob/IAP IDs (see `manual-configuration-setup.md`)
5. Create IAP products in App Store Connect / Play Console
6. Run manual QA from `manual-testing-scenarios.md`

---

## Known limitations (manual / external)

- **Audio files:** Add MP3s to `assets/audio/` for audible rain/SFX (code is wired).
- **Backend deploy:** Cloud Function + Firestore rules/indexes (see `manual-configuration-setup.md`).
- **Store products:** Create IAP products in App Store Connect / Play Console.
- **QA sign-off:** Run checklist in `manual-testing-scenarios.md`.
- **Production ad/IAP IDs:** Replace test AdMob IDs in `AdConfig`.
