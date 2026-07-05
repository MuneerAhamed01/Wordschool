import 'package:wordshool/core/config/app_config.dart';

/// Google OAuth client IDs for Firebase project `wordschool-dev`.
///
/// [webClientId] is the Web application client (client_type 3 in
/// `google-services.json`). Android requires it as `serverClientId` to obtain
/// an ID token for Firebase Auth.
///
/// Values are selected per [AppConfig] because prod and dev register separate
/// mobile apps in the same Firebase project.
class GoogleAuthConfig {
  const GoogleAuthConfig._();

  /// Shared web client for both prod and dev app registrations.
  static String webClientId(AppConfig config) =>
      '87702505475-0jobqk13evdmu8qiinmdsgfrq33cscfj.apps.googleusercontent.com';

  static String iosClientId(AppConfig config) {
    return config.isProd
        ? '87702505475-id78b5gh16rqa8eirni1jveo6orrkd81.apps.googleusercontent.com'
        : '87702505475-7mjteelebbalmv9r989ol3j6lbnvpagu.apps.googleusercontent.com';
  }
}
