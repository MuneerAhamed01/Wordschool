import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';

abstract class AuthRepository {
  Future<DataState<WordSchoolUserEntity?>> signInWithGoogle();

  Future<DataState<WordSchoolUserEntity?>> signInAnonymously();
}
