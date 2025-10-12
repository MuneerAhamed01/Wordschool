// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase extends UseCase<DataState<bool>, void> {
  final AuthRepository _authRepository;

  SignOutUseCase({required AuthRepository authRepo})
      : _authRepository = authRepo;

  @override
  Future<DataState<bool>> call({void param}) {
    return _authRepository.signOut();
  }
}
