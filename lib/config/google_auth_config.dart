/// Google OAuth client IDs from the Firebase project `wordschool-dev`.
///
/// [webClientId] is the Web application client (client_type 3 in
/// `google-services.json`). Android requires it as `serverClientId` to obtain
/// an ID token for Firebase Auth.
class GoogleAuthConfig {
  static const String webClientId =
      '87702505475-0jobqk13evdmu8qiinmdsgfrq33cscfj.apps.googleusercontent.com';

  static const String iosClientId =
      '87702505475-id78b5gh16rqa8eirni1jveo6orrkd81.apps.googleusercontent.com';
}
