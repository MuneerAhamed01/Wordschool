import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wordshool/core/config/app_config.dart';
import 'package:wordshool/core/config/app_environment.dart';
import 'package:wordshool/core/firebase/firebase_bootstrap.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandlerDev(RemoteMessage message) async {
  await FirebaseBootstrap.initialize(
    AppConfig.forEnvironment(AppEnvironment.dev),
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandlerProd(RemoteMessage message) async {
  await FirebaseBootstrap.initialize(
    AppConfig.forEnvironment(AppEnvironment.prod),
  );
}
