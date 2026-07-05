import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/settings/data/data_source/settings_data_source.dart';

class SettingsDataSourceImpl implements SettingsDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFunctions _functions;

  SettingsDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFunctions functions,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _functions = functions;

  @override
  Future<DataState<bool>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return DataSuccess<bool>(data: true);
    } catch (error, stackTrace) {
      return DataError<bool>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'SettingsDataSource.signOut',
      );
    }
  }

  @override
  Future<DataState<bool>> softDeleteAccount({
    required String firestoreDatabaseId,
  }) async {
    try {
      final callable = _functions.httpsCallable('softDeleteUserAccount');
      await callable.call<Map<String, dynamic>>({
        'firestoreDatabaseId': firestoreDatabaseId,
      });
      return DataSuccess<bool>(data: true);
    } catch (error, stackTrace) {
      return DataError<bool>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'SettingsDataSource.softDeleteAccount',
      );
    }
  }
}
