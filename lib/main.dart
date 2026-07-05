import 'package:wordshool/main_dev.dart' as entry;

/// Default entry point — delegates to [main_dev] so a plain `flutter run`
/// never targets production Firestore.
///
/// Prefer explicit targets:
/// - `lib/main_dev.dart` with `--flavor dev`
/// - `lib/main_prod.dart` with `--flavor prod`
void main() => entry.main();
