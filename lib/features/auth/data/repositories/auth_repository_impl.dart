import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/auth/data/data_source/auth_service.dart';
import 'package:wordshool/features/auth/domain/repositories/auth_repository.dart';
import 'package:wordshool/shared/data/models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepositoryImpl({required AuthDataSource authDataSource})
      : _authDataSource = authDataSource;

  @override
  Future<DataState<WordSchoolUserModel?>> signInAnonymously() {
    return _authDataSource.signInAnonymously();
  }

  @override
  Future<DataState<WordSchoolUserModel?>> signInWithGoogle() {
    return _authDataSource.signInWithGoogle();
  }

  @override
  Future<DataState<bool>> signOut() {
    return _authDataSource.signOut();
  }
}
