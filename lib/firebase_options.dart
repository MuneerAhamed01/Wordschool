import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import 'firebase_options_prod.dart';

export 'firebase_options_dev.dart' show DevFirebaseOptions;
export 'firebase_options_prod.dart' show ProdFirebaseOptions;

/// @deprecated Use [ProdFirebaseOptions] via [FirebaseBootstrap].
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform =>
      ProdFirebaseOptions.currentPlatform;
}
