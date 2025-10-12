import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/data/models/user.dart';

abstract class AuthDataSource {
  Future<DataState<WordSchoolUserModel?>> signInWithGoogle();
  Future<DataState<WordSchoolUserModel?>> signInAnonymously();
}
