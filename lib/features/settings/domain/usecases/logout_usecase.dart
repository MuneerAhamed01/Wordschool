import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/settings/domain/repositories/settings_repository.dart';

class LogoutUseCase {
  final SettingsRepository _repository;

  LogoutUseCase({required SettingsRepository repository})
      : _repository = repository;

  Future<DataState<bool>> call() {
    return _repository.logout();
  }
}


