import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/settings/data/data_source/settings_data_source.dart';

class SettingsDataSourceImpl implements SettingsDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  SettingsDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  @override
  Future<DataState<bool>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return DataSuccess<bool>(data: true);
    } catch (e) {
      return DataError<bool>(error: AppError(error: e.toString(), code: '500'));
    }
  }
}
