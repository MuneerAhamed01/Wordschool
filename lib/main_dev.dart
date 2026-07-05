import 'package:wordshool/app/bootstrap.dart';
import 'package:wordshool/core/config/app_config.dart';
import 'package:wordshool/core/config/app_environment.dart';
import 'package:wordshool/features/notifications/firebase_messaging_background.dart';

/// Development entry point — Firestore `dev` database, `com.wordschool.mat.dev`.
///
/// Run: `flutter run -t lib/main_dev.dart --flavor dev`
Future<void> main() async {
  await bootstrapWordSchool(
    appConfig: AppConfig.forEnvironment(AppEnvironment.dev),
    backgroundMessageHandler: firebaseMessagingBackgroundHandlerDev,
  );
}
