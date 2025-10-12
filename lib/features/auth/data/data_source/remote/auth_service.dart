import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  @override
  Future<DataState<WordSchoolUserModel?>> signInAnonymously() async {
    try {
      final response = await _firebaseAuth.signInAnonymously();

      if (response.user != null) {
        return DataSuccess<WordSchoolUserModel?>(
            data: WordSchoolUserModel.fromFirebase(user: response.user!));
      }

      return DataError<WordSchoolUserModel?>(
        error: AppError(error: 'User not found', code: '404'),
      );
    } catch (e) {
      return DataError<WordSchoolUserModel?>(
        error: AppError(error: e.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<WordSchoolUserModel?>> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();

      const scopes = [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'openid',
      ];

      final googleUser = await _googleSignIn.authenticate(scopeHint: scopes);

      final googleAuthentication = googleUser.authentication;
      final googleAuthorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes);

      if (googleAuthorization == null) {
        return DataError<WordSchoolUserModel?>(
          error: AppError(
              error: 'Failed to retrieve Google ID Token', code: '401'),
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuthorization.accessToken,
        idToken: googleAuthentication.idToken,
      );

      final response = await _firebaseAuth.signInWithCredential(credential);

      if (response.user == null) {
        return DataError<WordSchoolUserModel?>(
          error: AppError(error: 'Authentication failed', code: '404'),
        );
      }

      return DataSuccess<WordSchoolUserModel?>(
        data: WordSchoolUserModel.fromFirebase(user: response.user!),
      );
    } catch (e) {
      return DataError<WordSchoolUserModel?>(
        error: AppError(error: e.toString(), code: '500'),
      );
    }
  }
}
