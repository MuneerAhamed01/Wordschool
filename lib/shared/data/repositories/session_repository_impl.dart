import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';
import 'package:wordshool/shared/data/models/user.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionHandler _handler;

  SessionRepositoryImpl(this._handler);

  @override
  Future<DataState<bool>> saveUser(WordSchoolUserEntity user) {
    final model = WordSchoolUserModel(
        id: user.id, email: user.email, isAnonymous: user.isAnonymous);
    return _handler.saveUser(model);
  }

  @override
  WordSchoolUserEntity? getCurrentUser() {
    return _handler.currentUser;
  }

  @override
  void loadUser() {
    return _handler.loadUser();
  }

  @override
  Future<DataState<bool>> clearUser() {
    return _handler.clear();
  }
}
