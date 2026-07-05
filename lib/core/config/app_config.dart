import 'package:wordshool/core/config/app_environment.dart';

/// Application-wide environment configuration.
///
/// Lives in `core/config` (not feature code) so every layer can depend on a
/// single source of truth without importing Firebase or platform plugins.
///
/// See [technical_doc/environments/flutter-flavors.md] for setup and run commands.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.firestoreDatabaseId,
    required this.displayName,
    required this.envFileName,
    required this.bundleId,
  });

  /// Legacy compile-time key. Prefer separate entry points (`main_dev.dart` /
  /// `main_prod.dart`) instead of `--dart-define=APP_ENV`.
  static const String dartDefineKey = 'APP_ENV';

  final AppEnvironment environment;

  /// Firestore database id. Production uses the implicit `(default)` database.
  final String firestoreDatabaseId;

  /// Human-readable app name (home screen / MaterialApp title).
  final String displayName;

  /// Dotenv file loaded at startup (e.g. `.env.dev`).
  final String envFileName;

  /// Expected iOS bundle id / Android application id for this environment.
  final String bundleId;

  bool get isProd => environment == AppEnvironment.prod;

  bool get isDev => environment == AppEnvironment.dev;

  /// Legacy resolver for `--dart-define=APP_ENV`. Prefer [AppConfig.forEnvironment]
  /// via `main_dev.dart` / `main_prod.dart`.
  factory AppConfig.fromDartDefine() {
    const raw = String.fromEnvironment(dartDefineKey, defaultValue: 'dev');
    final env = raw == 'prod' ? AppEnvironment.prod : AppEnvironment.dev;
    return AppConfig.forEnvironment(env);
  }

  factory AppConfig.forEnvironment(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.prod:
        return const AppConfig(
          environment: AppEnvironment.prod,
          firestoreDatabaseId: '(default)',
          displayName: 'WordSchool',
          envFileName: '.env.prod',
          bundleId: 'com.wordschool.mat',
        );
      case AppEnvironment.dev:
        return const AppConfig(
          environment: AppEnvironment.dev,
          firestoreDatabaseId: 'development',
          displayName: 'WordSchool Dev',
          envFileName: '.env.dev',
          bundleId: 'com.wordschool.mat.dev',
        );
    }
  }
}
