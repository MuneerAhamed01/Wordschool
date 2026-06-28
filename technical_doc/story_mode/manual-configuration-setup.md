# Story Mode — Manual Configuration Setup

Complete these steps before enabling Story Mode in production.

---

## 0. Monetization & ads (disabled until stable)

Copy `.env.example` to `.env` in the project root:

```bash
cp .env.example .env
```

| Key | Default | Description |
| --- | ------- | ----------- |
| `IS_MONIT_PURCH` | `false` | When `false`, ads and in-app purchases are **fully disabled**. Hints are free. |

**Current release:** keep `IS_MONIT_PURCH=false`. No real AdMob account or store products are required.

**Native AdMob test app IDs** stay in `AndroidManifest.xml` and `Info.plist` while `google_mobile_ads` is in `pubspec.yaml` — without them iOS crashes at launch (`GADInvalidInitializationException`). With `IS_MONIT_PURCH=false`, Dart never initializes `AdService` and no ads are shown.

**When ready to monetize:**

1. Set `IS_MONIT_PURCH=true` in `.env`
2. Replace test AdMob app IDs in `AndroidManifest.xml`, `Info.plist`, and `lib/core/monetization/ad_config.dart` with your production IDs
3. Follow sections 6–7 below (AdMob + IAP)
4. Rebuild the app

---

## 1. Firebase Remote Config

In Firebase Console → Remote Config, create or update:

| Key | Type | Default | Description |
| --- | ---- | ------- | ----------- |
| `story_mode_enabled` | Boolean | `false` | Master kill switch |
| `story_mode_rollout_percent` | Number | `0` | 0–100; stable per-user rollout via UID hash |

**Rollout example:** set `story_mode_enabled=true` and `story_mode_rollout_percent=25` for 25% of users.

---

## 2. Cloud Functions

Deploy the leaderboard aggregator:

```bash
cd functions
npm install
npm run build
firebase deploy --only functions:updateDetectiveLeaderboard
```

Ensure Firebase Auth is enabled so display names resolve for leaderboard entries.

---

## 3. Firestore

Deploy rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

**Collections used:**

- `detectiveLeaderboard/{yyyy-Www}/entries/{userId}` — server-written only
- `userGameStates/{uid}` — extended with `hintPackBalance`, `hasRemoveAds`, `isDetectivePro`

---

## 4. Daily case seeding

**Recommended (no Cursor API cost):** seed the 30-day local case catalog:

```bash
cd functions
npm run seed:planned -- --force
```

This writes `detectiveCases/{yyyy-MM-dd}` for **2026-06-28 through 2026-07-27** from `functions/src/data/planned-cases.json`.

Single date or example case:

```bash
npm run seed -- --date 2026-06-28
npm run seed:planned -- --date 2026-06-29 --force
```

**Scheduled generation:** `generateDailyCase` runs at **00:00 UTC** and publishes the planned case for that date when one exists in the catalog. Cursor API is only used as a fallback when no planned case exists and `CURSOR_API_KEY` is configured.

After updating cases or functions:

```bash
cd functions
npm run build
firebase deploy --only functions:generateDailyCase
```

---

## 5. Audio assets (Phase 7)

Add MP3 files under `assets/audio/` (already listed in `pubspec.yaml`):

| File | Purpose |
| ---- | ------- |
| `rain_loop.mp3` | Ambient loop on story routes |
| `key_click.mp3` | Keyboard tap (optional) |
| `win.mp3` | Clue solved |
| `fail.mp3` | Clue failed |

If files are missing, the app runs silently (no crash).

---

## 6. Google AdMob

> **Skip real AdMob setup until `IS_MONIT_PURCH=true`.** The repo ships Google **test** app IDs in native config so the linked SDK does not crash on launch. No ads load in Dart while monetization is off.

### Replace test IDs (production only)

Update `lib/core/monetization/ad_config.dart` with production IDs from AdMob console.

### Android

`android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXX~YYYYYYYY"/>
```

### iOS

`ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXX~YYYYYYYY</string>
```

### Test devices

Register test device IDs in AdMob for QA (Settings → Test devices).

---

## 7. In-App Purchases

> **Skip until `IS_MONIT_PURCH=true`.** Purchase UI is hidden when monetization is disabled.

### Product IDs (must match store consoles)

| Product ID | Type | Store setup |
| ---------- | ---- | ----------- |
| `wordschool_remove_ads` | Non-consumable | App Store Connect + Play Console |
| `wordschool_hint_pack_5` | Consumable | Same |
| `wordschool_detective_pro_monthly` | Auto-renewable subscription | Same |

### Sandbox testing

- **iOS:** Sandbox Apple ID in Settings → App Store
- **Android:** License testers in Play Console

### Restore purchases

Available in **Settings → Restore purchases**.

---

## 8. Firebase Analytics

Enable DebugView for QA:

- **iOS:** `-FIRAnalyticsDebugEnabled` launch argument
- **Android:** `adb shell setprop debug.firebase.analytics.app <package_name>`

Verify events: `story_case_started`, `story_clue_solved`, `story_case_completed`, etc.

---

## 9. App Store / Play listing (optional)

Update store copy to mention Detective Case / Story Mode if shipping publicly.

---

## 10. Environment checklist

| Item | Location |
| ---- | -------- |
| Remote Config keys | Firebase Console |
| Cloud Function | `updateDetectiveLeaderboard` |
| Firestore rules | `firestore.rules` |
| Firestore index | `firestore.indexes.json` |
| AdMob app ID | AndroidManifest + Info.plist |
| Ad unit IDs | `lib/core/monetization/ad_config.dart` |
| IAP product IDs | Store consoles + `lib/core/monetization/iap_products.dart` |
| Audio files | `assets/audio/` |
| Case seeds | `functions/src/data/planned-cases.json` + `npm run seed:planned` |
