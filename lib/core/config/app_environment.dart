/// Runtime environment for the WordSchool client.
///
/// Selected by the app entry point (`main_dev.dart` or `main_prod.dart`) and
/// aligned with native product flavors (`prod` / `dev`).
enum AppEnvironment {
  /// Store builds — Firestore database `(default)`.
  prod,

  /// Engineering / QA builds — Firestore database `dev`.
  dev,
}
