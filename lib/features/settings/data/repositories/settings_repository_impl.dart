import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/notifications/notification_service.dart';
import 'package:wordshool/features/settings/data/data_source/settings_data_source.dart';
import 'package:wordshool/features/settings/domain/repositories/settings_repository.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_mode_session_controller.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _dataSource;
  final SessionRepository _sessionRepository;
  final StoryModeSessionController _storyModeSessionController;

  SettingsRepositoryImpl({
    required SettingsDataSource dataSource,
    required SessionRepository sessionRepository,
    required StoryModeSessionController storyModeSessionController,
  })  : _dataSource = dataSource,
        _sessionRepository = sessionRepository,
        _storyModeSessionController = storyModeSessionController;

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

    await _storyModeSessionController.resetOnLogout();

    if (getIt.isRegistered<NotificationService>()) {
      await getIt<NotificationService>().clearOnLogout();
    }

    return DataSuccess<bool>(data: true);
  }
}


