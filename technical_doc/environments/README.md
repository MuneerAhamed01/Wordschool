# Environments

Documentation for WordSchool **dev** vs **production** client and backend configuration.

| Phase | Document | Description |
|-------|----------|-------------|
| **2** | [flutter-flavors.md](./flutter-flavors.md) | Dart `AppConfig`, DI, Firestore `dev` database, run commands |
| **3** | [native-flavor-setup.md](./native-flavor-setup.md) | Android/iOS flavors, Firebase plists, entitlements, **manual steps** |

## Quick reference

```bash
# Daily development (Firestore `dev` database)
flutter run -t lib/main_dev.dart --flavor dev

# Production smoke test (Firestore `(default)` — real data)
flutter run -t lib/main_prod.dart --flavor prod
```

Firebase project for both: **`wordschool-dev`**.

## Manual setup checklist

- [ ] **iOS:** Register `com.wordschool.mat.dev` in Apple Developer (Push + Sign in with Apple)
- [ ] **Android:** Add debug SHA-1 to Firebase app `com.wordschool.mat.dev` for Google Sign-In
- [ ] **iOS:** Run `cd ios && pod install` after pulling native changes
- [ ] **Prod release:** Archive with `--flavor prod` and `aps-environment: production`

Details: [native-flavor-setup.md](./native-flavor-setup.md)
