import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/shared/domain/utils/sign_in_errors.dart';

enum AdminAuthStatus { unknown, signedOut, notAdmin, admin }

/// Email + password sign-in for the admin panel. Accounts are made by
/// `functions/scripts/set_admin_claim.py --password` (there is no sign-up). Only accounts with the `admin` custom
/// claim (set by `functions/scripts/set_admin_claim.py`) get past the login page.
///
/// Notifies listeners whenever [status] changes, so the router can redirect.
class AdminAuthService extends ChangeNotifier {
  AdminAuthService(this._auth) {
    _subscription = _auth.authStateChanges().listen(_onUser);
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _subscription;
  final Completer<void> _firstStatus = Completer<void>();

  AdminAuthStatus _status = AdminAuthStatus.unknown;
  AdminAuthStatus get status => _status;
  bool get isAdmin => _status == AdminAuthStatus.admin;

  User? get currentUser => _auth.currentUser;

  /// Completes once the persisted session has been checked.
  Future<void> get ready => _firstStatus.future;

  Future<void> _onUser(User? user) async {
    if (user == null) {
      _setStatus(AdminAuthStatus.signedOut);
      return;
    }
    try {
      final token = await user.getIdTokenResult(true);
      _setStatus(token.claims?['admin'] == true
          ? AdminAuthStatus.admin
          : AdminAuthStatus.notAdmin);
    } catch (_) {
      _setStatus(AdminAuthStatus.signedOut);
    }
  }

  void _setStatus(AdminAuthStatus status) {
    _status = status;
    if (!_firstStatus.isCompleted) _firstStatus.complete();
    notifyListeners();
  }

  /// Signs in with email and password. A non-admin account is signed out
  /// again and gets a `not-admin` error.
  Future<DataState<void>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final token = await credential.user?.getIdTokenResult(true);
      if (token?.claims?['admin'] != true) {
        final address = credential.user?.email ?? 'This account';
        await _auth.signOut();
        return DataError(
          error: AppError(
            error: 'not-admin',
            code: 'not-admin',
            message: '$address is not an admin. Ask the project owner to give '
                'this account admin access, then try again.',
          ),
        );
      }
      return DataSuccess(data: null);
    } on FirebaseAuthException catch (e) {
      return _authError(e);
    } catch (e) {
      return DataError(
        error: AppError(error: e, code: 'sign-in-failed', message: '$e'),
      );
    }
  }

  /// Emails a password-reset link. Firebase answers the same whether or not
  /// the address has an account.
  Future<DataState<void>> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return DataSuccess(data: null);
    } on FirebaseAuthException catch (e) {
      return _authError(e);
    } catch (e) {
      return DataError(
        error: AppError(error: e, code: 'reset-failed', message: '$e'),
      );
    }
  }

  DataError<void> _authError(FirebaseAuthException e) => DataError(
        error: AppError(
          error: e,
          code: e.code,
          message: signInErrorMessage(e.code),
        ),
      );

  Future<void> signOut() => _auth.signOut();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
