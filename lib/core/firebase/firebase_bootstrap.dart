import 'package:firebase_core/firebase_core.dart';
import 'package:wordshool/core/config/app_config.dart';
import 'package:wordshool/firebase_options_dev.dart' as dev_options;
import 'package:wordshool/firebase_options_prod.dart' as prod_options;

/// Initializes Firebase for the active [AppConfig] environment.
///
/// Keeps Firebase SDK details out of [main] and feature modules.
class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<void> initialize(AppConfig config) async {
    await Firebase.initializeApp(
      options: optionsFor(config),
    );
  }

  static FirebaseOptions optionsFor(AppConfig config) {
    return config.isProd
        ? prod_options.ProdFirebaseOptions.currentPlatform
        : dev_options.DevFirebaseOptions.currentPlatform;
  }
}
