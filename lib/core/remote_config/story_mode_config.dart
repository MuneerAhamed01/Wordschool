import 'package:firebase_remote_config/firebase_remote_config.dart';

abstract class StoryModeConfig {
  bool get isEnabled;

  Future<void> initialize();
}

class FirebaseStoryModeConfig implements StoryModeConfig {
  FirebaseStoryModeConfig({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const storyModeEnabledKey = 'story_mode_enabled';

  final FirebaseRemoteConfig _remoteConfig;

  @override
  bool get isEnabled => _remoteConfig.getBool(storyModeEnabledKey);

  @override
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults(const {
      storyModeEnabledKey: false,
    });

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Keep defaults when fetch fails (offline, throttled, etc.).
    }
  }
}
