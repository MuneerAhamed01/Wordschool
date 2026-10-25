import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/auth/data/data_source/auth_service.dart';
import 'package:wordshool/features/auth/domain/utils/player_name.dart';
import 'package:wordshool/features/auth/utils/auth_type.dart';
import 'package:wordshool/shared/data/models/user.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  @override
  Future<DataState<void>> savePlayerProfile() {
    return guardData('Auth.savePlayerProfile', () async {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const NotSignedInException();
      final ref =
          _firestore.collection(FirebaseCollections.users).doc(user.uid);
      // Only the keys the rules allow; xp/crossword stay server-only.
      final profile = <String, dynamic>{
        'displayName': playerDisplayName(uid: user.uid, name: user.displayName),
        'photoUrl': user.photoURL,
        'isAnonymous': user.isAnonymous,
        'lastSeenAt': FieldValue.serverTimestamp(),
      };
      // submitCrossword may create the doc (server fields only) at any
      // time, so decide create vs update inside a transaction: if the doc
      // appears between the read and the write, the transaction retries
      // as an update instead of a create the rules reject.
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (snap.exists) {
          tx.update(ref, profile);
        } else {
          tx.set(ref, {...profile, 'createdAt': FieldValue.serverTimestamp()});
        }
      });
    });
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
      final googleUser = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      // Firebase only needs the ID token; no separate authorization step
      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        return DataError<WordSchoolUserModel?>(
          error: AppError(
              error: 'Failed to retrieve Google ID Token', code: '401'),
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      final response = await _firebaseAuth.signInWithCredential(credential);

      if (response.user == null) {
        return DataError<WordSchoolUserModel?>(
          error: AppError(error: 'Authentication failed', code: '404'),
        );
      }

      return DataSuccess<WordSchoolUserModel?>(
        data: WordSchoolUserModel.fromFirebase(user: response.user!),
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return DataError<WordSchoolUserModel?>(
          error: AppError(error: 'Sign-in cancelled', code: authCancelledCode),
        );
      }

      return DataError<WordSchoolUserModel?>(
        error: AppError(error: e.description ?? e.toString(), code: '500'),
      );
    } catch (e) {
      return DataError<WordSchoolUserModel?>(
        error: AppError(error: e.toString(), code: '500'),
      );
    }
  }
}
