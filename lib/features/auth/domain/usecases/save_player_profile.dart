import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/auth/domain/repositories/auth_repository.dart';

/// Creates or refreshes `users/{uid}` (displayName, photoUrl, isAnonymous,
/// lastSeenAt) for the signed-in player — after sign-in and on app start.
class SavePlayerProfileUseCase extends UseCase<DataState<void>, void> {
  final AuthRepository _authRepository;

  SavePlayerProfileUseCase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<DataState<void>> call({void param}) {
    return _authRepository.savePlayerProfile();
  }
}
