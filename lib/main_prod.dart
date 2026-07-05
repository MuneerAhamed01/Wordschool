import 'package:wordshool/app/bootstrap.dart';
import 'package:wordshool/core/config/app_config.dart';
import 'package:wordshool/core/config/app_environment.dart';
import 'package:wordshool/features/notifications/firebase_messaging_background.dart';

/// Production entry point — Firestore `(default)` database, `com.wordschool.mat`.
///
/// Run: `flutter run -t lib/main_prod.dart --flavor prod`
Future<void> main() async {
  await bootstrapWordSchool(
    appConfig: AppConfig.forEnvironment(AppEnvironment.prod),
    backgroundMessageHandler: firebaseMessagingBackgroundHandlerProd,
  );
}
