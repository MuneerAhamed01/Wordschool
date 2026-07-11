import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  AdminAuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final isAdmin = await _hasAdminClaim(credential.user);
    if (!isAdmin) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'This account does not have admin access.',
      );
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    return _hasAdminClaim(user);
  }

  Future<bool> _hasAdminClaim(User? user) async {
    if (user == null) return false;
    final token = await user.getIdTokenResult(true);
    return token.claims?['admin'] == true;
  }
}
