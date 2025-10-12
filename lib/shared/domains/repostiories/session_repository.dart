import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';

abstract class SessionRepository {
  Future<DataState<bool>> saveUser(WordSchoolUserEntity user);
  WordSchoolUserEntity? getCurrentUser();
  void loadUser();
  Future<DataState<bool>> clearUser();
}
