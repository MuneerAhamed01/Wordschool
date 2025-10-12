// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/auth/domain/repositories/auth_repository.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';

class SignInAnonymouslyUseCase
    extends UseCase<DataState<WordSchoolUserEntity?>, void> {
  final AuthRepository _authRepository;

  SignInAnonymouslyUseCase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<DataState<WordSchoolUserEntity?>> call({void param}) async {
    return await _authRepository.signInAnonymously();
  }
}
