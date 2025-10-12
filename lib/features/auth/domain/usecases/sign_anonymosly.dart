// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/auth/domain/repositories/auth_repository.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';

class SignInAnonymouslyUseCase
    extends UseCase<DataState<WordSchoolUserEntity?>, void> {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  SignInAnonymouslyUseCase(
      {required AuthRepository authRepository,
      required SessionRepository sessionRepository})
      : _authRepository = authRepository,
        _sessionRepository = sessionRepository;

  @override
  Future<DataState<WordSchoolUserEntity?>> call({void param}) async {
    final data = await _authRepository.signInAnonymously();

    if (data is DataSuccess) {
      await _sessionRepository.saveUser(data.data!);
    }

    return data;
  }
}
