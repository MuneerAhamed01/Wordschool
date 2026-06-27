import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wordshool/config/google_auth_config.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/auth/data/data_source/auth_service.dart';
import 'package:wordshool/shared/data/models/user.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  static Future<void> initializeGoogleSignIn() async {
    await GoogleSignIn.instance.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? GoogleAuthConfig.iosClientId
          : null,
      serverClientId: GoogleAuthConfig.webClientId,
    );
  }

  @override
  Future<DataState<WordSchoolUserModel?>> signInAnonymously() async {
    try {
      final response = await _firebaseAuth.signInAnonymously();

      if (response.user != null) {
        return DataSuccess<WordSchoolUserModel?>(
            data: WordSchoolUserModel.fromFirebase(user: response.user!));
      }

      return DataError<WordSchoolUserModel?>(
        error: AppError.notFound(
          message: 'User not found',
          error: 'User not found',
        ),
      );
    } catch (error, stackTrace) {
      return DataError<WordSchoolUserModel?>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'AuthDataSource.signInAnonymously',
      );
    }
  }

  @override
  Future<DataState<WordSchoolUserModel?>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      return _completeGoogleSignIn(googleUser);
    } on GoogleSignInException catch (e, stackTrace) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return DataError<WordSchoolUserModel?>(
          error: AppError.cancelled(
            message: 'Google sign-in was cancelled',
            error: e,
          ),
        );
      }

      return DataError<WordSchoolUserModel?>(
        error: AppError.fromException(e),
        stackTrace: stackTrace,
        context: 'AuthDataSource.signInWithGoogle',
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      return DataError<WordSchoolUserModel?>(
        error: AppError.fromException(
          e,
          message: e.message ?? e.code,
          code: e.code,
        ),
        stackTrace: stackTrace,
        context: 'AuthDataSource.signInWithGoogle',
      );
    } catch (e, stackTrace) {
      return DataError<WordSchoolUserModel?>(
        error: AppError.fromException(e),
        stackTrace: stackTrace,
        context: 'AuthDataSource.signInWithGoogle',
      );
    }
  }

  Future<DataState<WordSchoolUserModel?>> _completeGoogleSignIn(
    GoogleSignInAccount googleUser,
  ) async {
    final idToken = googleUser.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      return DataError<WordSchoolUserModel?>(
        error: AppError(
          error: 'Failed to retrieve Google ID token. '
              'Ensure the Firebase Web client ID is configured.',
          code: '401',
        ),
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final currentUser = _firebaseAuth.currentUser;

    try {
      final UserCredential response;
      if (currentUser != null && currentUser.isAnonymous) {
        response = await currentUser.linkWithCredential(credential);
      } else {
        response = await _firebaseAuth.signInWithCredential(credential);
      }

      if (response.user == null) {
        return DataError<WordSchoolUserModel?>(
          error: AppError.notFound(
            message: 'Authentication failed',
            error: 'Authentication failed',
          ),
        );
      }

      return DataSuccess<WordSchoolUserModel?>(
        data: WordSchoolUserModel.fromFirebase(user: response.user!),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'credential-already-in-use') {
        rethrow;
      }

      await _firebaseAuth.signOut();
      final response = await _firebaseAuth.signInWithCredential(credential);

      if (response.user == null) {
        return DataError<WordSchoolUserModel?>(
          error: AppError.notFound(
            message: 'Authentication failed',
            error: 'Authentication failed',
          ),
        );
      }

      return DataSuccess<WordSchoolUserModel?>(
        data: WordSchoolUserModel.fromFirebase(user: response.user!),
      );
    }
  }
}
