// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/auth/domain/repositories/auth_repository.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';

class SignInWithGoogleUseCase
    extends UseCase<DataState<WordSchoolUserEntity?>, void> {
  final AuthRepository _authRepository;

  SignInWithGoogleUseCase({required AuthRepository authRepo})
      : _authRepository = authRepo;

  @override
  Future<DataState<WordSchoolUserEntity?>> call({void param}) {
    return _authRepository.signInWithGoogle();
  }
}
