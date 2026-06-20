# Phase 9 — Monetization

> **Status:** Not started  
> **Last updated:** —  
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

- [ ] **Step 9.1** — `google_mobile_ads` setup (AdMob app IDs, test units)
- [ ] **Step 9.2** — Placements: banner (dashboard/story), interstitial (post-resolution), rewarded (extra hint)
- [ ] **Step 9.3** — IAP products in App Store Connect / Play Console + client purchase flow
- [ ] **Step 9.4** — Hint pack + Pro logic (reveal letter / stronger hint, ad-free gate)

## Ad placements (from fulldoc.md)

| Type | Suggested placement |
| ---- | ------------------- |
| Banner | Dashboard, story intro |
| Interstitial | After case resolution |
| Rewarded | Optional hint before Wordle |

## IAP products (from fulldoc.md)

| Product | Benefit |
| ------- | ------- |
| Remove Ads | No banner/interstitial |
| Hint Packs | Consumable extra hints |
| Detective Pro | Subscription: ad-free + unlimited hints (define tiers) |

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| Ads SDK | `google_mobile_ads` | Per fulldoc.md | — |
| IAP package | TBD (`in_app_purchase`?) | Align with store requirements | — |
| Entitlements storage | Firestore user doc or RevenueCat | TBD | — |

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `pubspec.yaml` | Add `google_mobile_ads`, IAP package |
| `lib/features/story_mode/presentation/widgets/story_banner_ad.dart` | New |
| `lib/features/story_mode/domain/usecases/consume_hint.dart` | New |
| `lib/features/settings/` | Restore purchases |

## Acceptance criteria

- [ ] Test ads show in debug; production units configured for release
- [ ] Interstitial respects "Remove Ads" purchase
- [ ] Rewarded ad grants one hint; hint consumed on use
- [ ] Pro subscribers see no ads and get hint allowance

## Testing notes

- Use AdMob test device IDs
- Sandbox IAP on iOS/Android
- Verify purchase restore after reinstall

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- Hint mechanics: reveal one letter vs show stronger narrative hint?
- Pro subscription price points and trial period?
