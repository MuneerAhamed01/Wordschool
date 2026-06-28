import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages ambient and SFX audio for story mode. Gracefully no-ops when assets
/// are missing or audio is muted.
class StoryAudioManager {
  StoryAudioManager({SharedPreferences? preferences})
      : _preferences = preferences;

  static const _muteKey = 'story_audio_muted';

  final SharedPreferences? _preferences;
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _keyClickPlayer = AudioPlayer();

  bool _initialized = false;
  bool _muted = false;
  bool _keyClickLoaded = false;
  bool _ambientPlaying = false;

  bool get isMuted => _muted;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _muted = _preferences?.getBool(_muteKey) ?? false;
    await _preloadKeyClick();
  }

  Future<void> _preloadKeyClick() async {
    if (_keyClickLoaded) return;
    try {
      await _keyClickPlayer.setAsset('assets/audio/key_click.mp3');
      await _keyClickPlayer.setVolume(0.5);
      _keyClickLoaded = true;
    } catch (error) {
      debugPrint('StoryAudioManager: key_click asset unavailable ($error)');
    }
  }

  Future<void> startStoryAmbience() async {
    if (_muted || _ambientPlaying) return;
    try {
      await _ambientPlayer.stop();
      await _ambientPlayer.setAsset('assets/audio/rain_loop.mp3');
      await _ambientPlayer.setLoopMode(LoopMode.one);
      await _ambientPlayer.setVolume(0.35);
      await _ambientPlayer.play();
      _ambientPlaying = true;
    } catch (error) {
      debugPrint('StoryAudioManager: rain asset unavailable ($error)');
      _ambientPlaying = false;
    }
  }

  Future<void> stopAll() async {
    _ambientPlaying = false;
    await Future.wait([
      _ambientPlayer.stop(),
      _sfxPlayer.stop(),
      _keyClickPlayer.stop(),
    ]);
  }

  Future<void> playKeyClick() async {
    if (_muted) return;
    try {
      if (!_keyClickLoaded) {
        await _preloadKeyClick();
      }
      if (!_keyClickLoaded) return;
      await _keyClickPlayer.seek(Duration.zero);
      await _keyClickPlayer.play();
    } catch (_) {
      // Optional asset.
    }
  }

  Future<void> playWin() async {
    await _playSfx('assets/audio/win.mp3');
  }

  Future<void> playFail() async {
    await _playSfx('assets/audio/fail.mp3');
  }

  Future<void> _playSfx(String assetPath) async {
    if (_muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.setVolume(0.7);
      await _sfxPlayer.play();
    } catch (_) {
      // Optional asset.
    }
  }

  Future<void> setMuted(bool muted) async {
    _muted = muted;
    await _preferences?.setBool(_muteKey, muted);
    if (muted) {
      await stopAll();
    }
  }

  Future<void> dispose() async {
    await stopAll();
    await Future.wait([
      _ambientPlayer.dispose(),
      _sfxPlayer.dispose(),
      _keyClickPlayer.dispose(),
    ]);
  }
}
