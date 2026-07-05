# Phase 3 — Native flavor setup

This document covers **Android and iOS** configuration for `prod` and `dev` flavors. It complements [flutter-flavors.md](./flutter-flavors.md) (Dart layer / Phase 2).

---

## Overview

| | **prod** | **dev** |
|---|----------|---------|
| Flutter `--flavor` | `prod` | `dev` |
| Dart entry | `lib/main_dev.dart` | `lib/main_prod.dart` |
| Flutter `-t` | `-t lib/main_dev.dart` | `-t lib/main_prod.dart` |
| Native `--flavor` | `dev` | `prod` |
| Android `applicationId` | `com.wordschool.mat` | `com.wordschool.mat.dev` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.wordschool.mat` | `com.wordschool.mat.dev` |
| Home screen name | WordSchool | WordSchool Dev |
| Firebase Android config | `android/app/src/prod/google-services.json` | `android/app/src/dev/google-services.json` |
| Firebase iOS config | `ios/flavors/prod/GoogleService-Info.plist` | `ios/flavors/dev/GoogleService-Info.plist` |
| APNs entitlements (release) | `production` | `development` (debug builds) |

Both flavors use Firebase project **`wordschool-dev`**.

---

## Android

### Files (automated in repo)

| File | Purpose |
|------|---------|
| `android/app/build.gradle.kts` | `productFlavors { prod, dev }` |
| `android/app/src/prod/google-services.json` | Prod Firebase Android app |
| `android/app/src/dev/google-services.json` | Dev Firebase Android app |
| `android/app/src/main/AndroidManifest.xml` | `android:label="@string/app_name"` (from flavor `resValue`) |

The legacy root `android/app/google-services.json` was **removed** — only flavor-specific files are used.

### How Gradle resolves Firebase

The Google Services plugin picks the `client` entry whose `package_name` matches the flavor `applicationId`.

### Build commands

```bash
# Debug APK (dev)
flutter build apk -t lib/main_dev.dart --flavor dev --debug

# Release App Bundle (prod — Play Store)
flutter build appbundle -t lib/main_prod.dart --flavor prod --release
```

### Manual steps (Android)

1. **Register debug SHA-1 for dev Google Sign-In** (if Google login fails on dev builds):
   - Firebase Console → Project settings → Your apps → **Android `com.wordschool.mat.dev`**
   - Add SHA-1 from debug keystore:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   - Download updated `google-services.json` → replace `android/app/src/dev/google-services.json`

2. **Release signing** — unchanged; `android/key.properties` applies to both flavors for release builds.

3. **Play Console** — create a separate internal testing track for dev if you distribute `com.wordschool.mat.dev` (optional).

---

## iOS

### Files (automated in repo)

| File | Purpose |
|------|---------|
| `ios/Podfile` | Maps `Debug-prod`, `Release-dev`, etc. to CocoaPods build types |
| `ios/Flutter/Debug-prod.xcconfig` … `Profile-dev.xcconfig` | Per-flavor Pods + Generated includes |
| `ios/Runner.xcodeproj/project.pbxproj` | 6 build configurations + bundle IDs |
| `ios/Runner.xcodeproj/xcshareddata/xcschemes/prod.xcscheme` | Flutter `--flavor prod` |
| `ios/Runner.xcodeproj/xcshareddata/xcschemes/dev.xcscheme` | Flutter `--flavor dev` |
| `ios/Runner/select_firebase_plist.sh` | Copies correct `GoogleService-Info.plist` before Resources phase |
| `ios/flavors/prod/GoogleService-Info.plist` | Prod Firebase iOS app |
| `ios/flavors/dev/GoogleService-Info.plist` | Dev Firebase iOS app |
| `ios/Runner/Runner.entitlements` | `aps-environment: development` (debug / dev) |
| `ios/Runner/Runner-Release.entitlements` | `aps-environment: production` (prod release/profile) |
| `ios/Runner/Info.plist` | Both Google URL schemes; display name from build setting |

### Build configuration naming

Flutter expects Xcode configuration names **`{BuildType}-{flavor}`**:

| Flutter | Xcode configuration |
|---------|---------------------|
| `--flavor prod` debug | `Debug-prod` |
| `--flavor prod` release | `Release-prod` |
| `--flavor dev` debug | `Debug-dev` |
| `--flavor dev` release | `Release-dev` |

### After pulling iOS changes

```bash
cd ios && pod install && cd ..
```

CocoaPods generates `Pods-Runner.debug-prod.xcconfig`, `Pods-Runner.debug-dev.xcconfig`, etc.

### Build commands

```bash
# Dev on device / simulator
flutter run -t lib/main_dev.dart --flavor dev

# Prod release (TestFlight / App Store)
flutter build ipa -t lib/main_prod.dart --flavor prod --release
```

### Manual steps (iOS)

1. **Apple Developer — register dev App ID**
   - Identifier: `com.wordschool.mat.dev`
   - Capabilities: **Push Notifications**, **Sign In with Apple**
   - Create provisioning profile for dev (Xcode can manage automatically with Automatic signing)

2. **APNs key** — one key in Firebase Console works for both bundle IDs if both apps are registered in the same Firebase project (already done).

3. **Google Sign-In** — `Info.plist` includes URL schemes for **both** prod and dev reversed client IDs (no per-flavor plist needed).

4. **TestFlight / App Store** — always archive with **`prod`** scheme and `Runner-Release.entitlements` (`aps-environment: production`).

5. **Re-run `pod install`** whenever `Podfile` or Xcode configurations change.

---

## Push notifications (APNs)

| Build | Entitlements file | `aps-environment` |
|-------|-------------------|-------------------|
| Dev debug / profile | `Runner.entitlements` | `development` |
| Prod release / profile | `Runner-Release.entitlements` | `production` |
| Prod debug (local) | `Runner.entitlements` | `development` |

**Manual:** Before App Store submission, confirm Archive uses **Release-prod** → `Runner-Release.entitlements`.

---

## Firebase plist / JSON sync

| Platform | Update command |
|----------|----------------|
| Android prod | Re-download → `android/app/src/prod/google-services.json` |
| Android dev | Re-download → `android/app/src/dev/google-services.json` |
| iOS prod | Re-download → `ios/flavors/prod/GoogleService-Info.plist` |
| iOS dev | Re-download → `ios/flavors/dev/GoogleService-Info.plist` |

Or use FlutterFire (updates `firebase.json` outputs):

```bash
flutterfire configure --project=wordschool-dev \
  --out=lib/firebase_options_prod.dart \
  --ios-bundle-id=com.wordschool.mat \
  --android-package-name=com.wordschool.mat

flutterfire configure --project=wordschool-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.wordschool.mat.dev \
  --android-package-name=com.wordschool.mat.dev
```

Rename generated classes to `ProdFirebaseOptions` / `DevFirebaseOptions` if the CLI emits `DefaultFirebaseOptions`.

---

## Verification

### Android dev

```bash
flutter run -t lib/main_dev.dart --flavor dev
```

- [ ] Launcher shows **WordSchool Dev**
- [ ] `adb shell pm list packages | grep wordschool` shows `com.wordschool.mat.dev`
- [ ] Google Sign-In works (after SHA-1 registered for dev app)

### Android prod

```bash
flutter run -t lib/main_prod.dart --flavor prod
```

- [ ] Launcher shows **WordSchool**
- [ ] Package `com.wordschool.mat`

### iOS dev

```bash
flutter run -t lib/main_dev.dart --flavor dev
```

- [ ] Home screen **WordSchool Dev**
- [ ] Bundle ID `com.wordschool.mat.dev` (Xcode → Runner → Signing)

### iOS prod release

```bash
flutter build ipa -t lib/main_prod.dart --flavor prod --release
```

- [ ] Archive uses **Release-prod**
- [ ] Entitlements show `aps-environment: production`

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `Gradle flavor required` | Missing `--flavor` | Add `--flavor dev` or `prod` |
| iOS Pod errors after pull | Stale Pods | `cd ios && pod install` |
| Google Sign-In fails on **dev** Android | No SHA-1 for `.dev` package | Add debug SHA-1 in Firebase Console |
| Google Sign-In fails on **dev** iOS | Missing URL scheme | Confirm both schemes in `Info.plist` |
| FCM works in debug but not TestFlight | Wrong APNs environment | Prod release must use `Runner-Release.entitlements` |
| Wrong Firestore database | Wrong `-t` entry / flavor mismatch | Use `main_dev.dart` + `--flavor dev` or `main_prod.dart` + `--flavor prod` |

---

## Related

- [flutter-flavors.md](./flutter-flavors.md) — Dart `AppConfig`, DI, Firestore `dev` database
- [README.md](./README.md) — environments index
- [manual-configuration-setup.md](../story_mode/manual-configuration-setup.md) — AdMob, IAP, Apple Sign In
