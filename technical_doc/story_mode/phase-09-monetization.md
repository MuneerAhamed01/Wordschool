# Phase 9 — Monetization

> **Status:** Complete  
> **Last updated:** 2026-06-27  
> **Owner:** —  
> **Depends on:** Phase 5 (core loop complete)  
> **Blocks:** —  

## Goal

Add ads and in-app purchases for Story Mode: banners, interstitials, rewarded hints, remove-ads, hint packs, and Detective Pro subscription.

## Scope

### In scope

- Google Mobile Ads integration
- Banner, interstitial, rewarded ad placements
- IAP products: Remove Ads, Hint Packs, Detective Pro
- Hint pack consumption logic
- Pro subscription entitlements

### Out of scope (deferred)

- Web monetization
- Regional pricing experiments

## Steps checklist

- [x] **Step 9.1** — `google_mobile_ads` setup (AdMob app IDs, test units)
- [x] **Step 9.2** — Placements: banner (story home), interstitial (post-resolution), rewarded (hint API)
- [x] **Step 9.3** — IAP products + client purchase flow + restore in Settings
- [x] **Step 9.4** — Hint pack + Pro logic + ad-free gate on `UserGameStateEntity`

## Ad placements (from fulldoc.md)

| Type | Implemented placement |
| ---- | ------------------- |
| Banner | Story home + dashboard (`StoryBannerAd`) |
| Interstitial | After case resolution (`CaseResolutionPage`) |
| Rewarded | Hint page letter reveal (`StoryHintPage`) |

## IAP products (from fulldoc.md)

| Product ID | Benefit |
| ---------- | ------- |
| `wordschool_remove_ads` | No banner/interstitial |
| `wordschool_hint_pack_5` | +5 consumable hints |
| `wordschool_detective_pro_monthly` | Ad-free + unlimited hints |

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Ads SDK | `google_mobile_ads` | Per fulldoc.md | 2026-06-27 |
| IAP package | `in_app_purchase` | Cross-platform store API | 2026-06-27 |
| Entitlements storage | Firestore `userGameStates` fields | Reuse existing user doc | 2026-06-27 |
| Ad IDs | Google test units in `AdConfig` | Safe debug; replace for release | 2026-06-27 |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `pubspec.yaml` | Added `google_mobile_ads`, `in_app_purchase` |
| `lib/core/monetization/ad_config.dart` | Test AdMob IDs |
| `lib/core/monetization/ad_service.dart` | Banner, interstitial, rewarded |
| `lib/core/monetization/iap_products.dart` | Product ID constants |
| `lib/core/monetization/iap_service.dart` | Purchase stream + restore |
| `lib/core/monetization/story_entitlements.dart` | Ad-free / hint checks |
| `lib/features/story_mode/presentation/widgets/story_banner_ad.dart` | New |
| `lib/features/story_mode/domain/usecases/consume_hint.dart` | New |
| `lib/shared/domains/entities/user_game_state/user_game_state.dart` | `hintPackBalance`, `hasRemoveAds`, `isDetectivePro` |
| `lib/features/settings/presentation/pages/settings_page.dart` | Restore purchases |
| `android/app/src/main/AndroidManifest.xml` | AdMob APPLICATION_ID |
| `ios/Runner/Info.plist` | GADApplicationIdentifier |

## Acceptance criteria

- [x] Test ads show in debug; production units configured for release (test IDs in code; manual swap documented)
- [x] Interstitial respects "Remove Ads" purchase (`StoryEntitlements.shouldHideAds`)
- [x] Rewarded ad grants one hint via API; hint consumed via `ConsumeHintUseCase`
- [x] Pro subscribers see no ads and get hint allowance

## Testing notes

- Use AdMob test device IDs
- Sandbox IAP on iOS/Android
- Verify purchase restore after reinstall

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-27 | 9.1–9.4 | Ads, IAP, entitlements, consume hint, restore purchases |

## Open questions / blockers

- Hint mechanics: reveal one letter vs show stronger narrative hint? → **Done:** letter reveal on hint page (`StoryHintReveal`)
- Pro subscription price points and trial period? → **Manual:** configure in App Store Connect / Play Console
