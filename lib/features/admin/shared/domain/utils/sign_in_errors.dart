/// Player-readable text for the admin email sign-in form.
library;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Problem with the typed email, or null when it looks like an address.
String? emailProblem(String? value) {
  final email = (value ?? '').trim();
  if (email.isEmpty) return 'Enter your email';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email';
  return null;
}

/// Problem with the typed password, or null when one was entered.
String? passwordProblem(String? value) =>
    (value ?? '').isEmpty ? 'Enter your password' : null;

/// Message for a `FirebaseAuthException.code` from email sign-in or a
/// password-reset request.
String signInErrorMessage(String code) {
  switch (code) {
    // With email enumeration protection, a wrong password and an unknown
    // email both come back as `invalid-credential`.
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
    case 'invalid-login-credentials':
      return 'Wrong email or password.';
    case 'invalid-email':
      return 'Enter a valid email.';
    case 'user-disabled':
      return 'This account is disabled. Ask the project owner.';
    case 'too-many-requests':
      return 'Too many attempts. Wait a few minutes, or reset your password.';
    case 'network-request-failed':
      return 'No connection. Check your network and try again.';
    case 'operation-not-allowed':
      return 'Email sign-in is turned off for this project. Enable '
          'Email/Password in Firebase Console → Authentication.';
    default:
      return 'Sign-in failed ($code).';
  }
}
