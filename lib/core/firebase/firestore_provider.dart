import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wordshool/core/config/app_config.dart';

/// Provides the environment-scoped [FirebaseFirestore] instance.
///
/// Registered once in DI; data sources receive it via constructor injection
/// (clean architecture — no static `FirebaseFirestore.instance` in features).
class FirestoreProvider {
  const FirestoreProvider._();

  static const String devDatabaseId = 'development';

  static FirebaseFirestore instanceFor(AppConfig config) {
    if (config.isProd) {
      return FirebaseFirestore.instance;
    }

    return FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: config.firestoreDatabaseId,
    );
  }
}
