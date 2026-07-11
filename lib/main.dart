import 'package:flutter/foundation.dart';
import 'package:wordshool/app/bootstrap_admin.dart';
import 'package:wordshool/main_dev.dart' as entry;

/// Default entry point.
///
/// Web browsers load the admin panel; native mobile loads the game app.
/// Prefer explicit mobile targets:
/// - `lib/main_dev.dart` with `--flavor dev`
/// - `lib/main_prod.dart` with `--flavor prod`
void main() {
  if (kIsWeb) {
    bootstrapAdmin();
    return;
  }
  entry.main();
}
