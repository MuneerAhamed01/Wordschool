import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/settings/data/data_source/settings_data_source.dart';
import 'package:wordshool/features/settings/domain/repositories/settings_repository.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _dataSource;
  final SessionRepository _sessionRepository;

  SettingsRepositoryImpl({
    required SettingsDataSource dataSource,
    required SessionRepository sessionRepository,
  })  : _dataSource = dataSource,
        _sessionRepository = sessionRepository;

  @override
  Future<DataState<bool>> logout() async {
    final signOutResult = await _dataSource.signOut();
    if (signOutResult is DataError) {
      return signOutResult;
    }

    final clearResult = await _sessionRepository.clearUser();
    if (clearResult is DataError) {
      return clearResult;
    }

    return DataSuccess<bool>(data: true);
  }
}


