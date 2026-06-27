import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:wordshool/core/logging/logging.dart';

abstract class StoryModeConfig {
  bool get isEnabled;

  int get rolloutPercent;

  bool isEnabledForUser(String? userId);

  Future<void> initialize();
}

class FirebaseStoryModeConfig implements StoryModeConfig {
  FirebaseStoryModeConfig({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const storyModeEnabledKey = 'story_mode_enabled';
  static const storyModeRolloutKey = 'story_mode_rollout_percent';

  final FirebaseRemoteConfig _remoteConfig;

  @override
  bool get isEnabled => isEnabledForUser(null);

  @override
  int get rolloutPercent => _remoteConfig.getInt(storyModeRolloutKey);

  @override
  bool isEnabledForUser(String? userId) {
    if (!_remoteConfig.getBool(storyModeEnabledKey)) {
      return false;
    }

    final rollout = rolloutPercent.clamp(0, 100);
    if (rollout >= 100) {
      return true;
    }
    if (rollout <= 0) {
      return false;
    }
    if (userId == null || userId.isEmpty) {
      return true;
    }

    return _stableBucket(userId) < rollout;
  }

  int _stableBucket(String userId) {
    var hash = 0;
    for (final unit in userId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash % 100;
  }

  @override
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults(const {
      storyModeEnabledKey: true,
      storyModeRolloutKey: 100,
    });

    var fetchActivated = false;
    try {
      fetchActivated = await _remoteConfig.fetchAndActivate();
    } catch (error, stackTrace) {
      AppLogger.instance.warning(
        'Remote Config fetch failed; using defaults or cached values',
        tag: 'REMOTE_CONFIG',
        error: error,
        stackTrace: stackTrace,
      );
    }

    _logRemoteConfig(fetchActivated: fetchActivated);
  }

  void _logRemoteConfig({required bool fetchActivated}) {
    final enabled = _remoteConfig.getBool(storyModeEnabledKey);
    final rollout = _remoteConfig.getInt(storyModeRolloutKey);
    final lastFetchStatus = _remoteConfig.lastFetchStatus;
    final lastFetchTime = _remoteConfig.lastFetchTime;

    AppLogger.instance.info(
      'Story mode Remote Config\n'
      '  $storyModeEnabledKey: $enabled\n'
      '  $storyModeRolloutKey: $rollout\n'
      '  fetchAndActivate: ${fetchActivated ? 'activated new values' : 'using cached/defaults'}\n'
      '  lastFetchStatus: $lastFetchStatus\n'
      '  lastFetchTime: $lastFetchTime',
      tag: 'REMOTE_CONFIG',
    );
  }
}
