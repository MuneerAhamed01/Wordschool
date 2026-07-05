import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/settings/domain/repositories/settings_repository.dart';

class DeleteAccountUseCase {
  final SettingsRepository _repository;

  DeleteAccountUseCase({required SettingsRepository repository})
      : _repository = repository;

  Future<DataState<bool>> call({required String firestoreDatabaseId}) {
    return _repository.deleteAccount(firestoreDatabaseId: firestoreDatabaseId);
  }
}
