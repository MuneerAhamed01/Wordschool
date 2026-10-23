import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// XP deducted when a player reveals a letter or a whole word.
class HintPenalties extends Equatable {
  final int letter;
  final int word;

  const HintPenalties({required this.letter, required this.word});

  static const fallback = HintPenalties(letter: 5, word: 15);

  /// Parses `{"letter":5,"word":15}`; returns [fallback] for bad input.
  static HintPenalties parse(String? raw) {
    final json = _decodeObject(raw);
    final letter = json?['letter'];
    final word = json?['word'];
    if (letter is! int || word is! int || letter < 0 || word < 0) {
      return fallback;
    }
    return HintPenalties(letter: letter, word: word);
  }

  @override
  List<Object?> get props => [letter, word];
}

/// XP needed for level n is `base * growth^(n-1)`.
class XpLevelFormula extends Equatable {
  final int base;
  final double growth;

  const XpLevelFormula({required this.base, required this.growth});

  static const fallback = XpLevelFormula(base: 100, growth: 1.25);

  /// Parses `{"base":100,"growth":1.25}`; returns [fallback] for bad input.
  static XpLevelFormula parse(String? raw) {
    final json = _decodeObject(raw);
    final base = json?['base'];
    final growth = json?['growth'];
    if (base is! int || growth is! num || base <= 0 || growth < 1) {
      return fallback;
    }
    return XpLevelFormula(base: base, growth: growth.toDouble());
  }

  @override
  List<Object?> get props => [base, growth];
}

Map<String, dynamic>? _decodeObject(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

/// Typed access to Remote Config tunables. Values are always available:
/// in-app defaults until a fetch has been activated.
abstract class AppRemoteConfig {
  HintPenalties get crosswordHintPenalties;

  int get crosswordRevealsPerPuzzle;

  XpLevelFormula get xpLevelFormula;

  Duration get crosswordAutosaveInterval;

  int get minSupportedBuild;

  Future<void> initialize();
}

class FirebaseAppRemoteConfig implements AppRemoteConfig {
  FirebaseAppRemoteConfig({required FirebaseRemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;

  static const hintPenaltiesKey = 'crossword_hint_penalties';
  static const revealsPerPuzzleKey = 'crossword_reveals_per_puzzle';
  static const xpLevelFormulaKey = 'xp_level_formula';
  static const autosaveSecondsKey = 'crossword_autosave_seconds';
  static const minSupportedBuildKey = 'min_supported_build';

  static const defaults = <String, dynamic>{
    hintPenaltiesKey: '{"letter":5,"word":15}',
    revealsPerPuzzleKey: 3,
    xpLevelFormulaKey: '{"base":100,"growth":1.25}',
    autosaveSecondsKey: 30,
    minSupportedBuildKey: 0,
  };

  final FirebaseRemoteConfig _remoteConfig;

  @override
  HintPenalties get crosswordHintPenalties =>
      HintPenalties.parse(_remoteConfig.getString(hintPenaltiesKey));

  @override
  int get crosswordRevealsPerPuzzle => _nonNegativeInt(revealsPerPuzzleKey);

  @override
  XpLevelFormula get xpLevelFormula =>
      XpLevelFormula.parse(_remoteConfig.getString(xpLevelFormulaKey));

  @override
  Duration get crosswordAutosaveInterval {
    final seconds = _remoteConfig.getInt(autosaveSecondsKey);
    return Duration(
      seconds: seconds > 0 ? seconds : defaults[autosaveSecondsKey] as int,
    );
  }

  @override
  int get minSupportedBuild => _nonNegativeInt(minSupportedBuildKey);

  int _nonNegativeInt(String key) {
    final value = _remoteConfig.getInt(key);
    return value >= 0 ? value : defaults[key] as int;
  }

  /// Applies defaults and the last fetched values, then fetches in the
  /// background so startup never waits on the network. Newly fetched values
  /// take effect on the next launch.
  @override
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.setDefaults(defaults);
      await _remoteConfig.activate();
    } catch (error, stackTrace) {
      log(
        'Remote Config setup failed; using in-app defaults',
        name: 'REMOTE_CONFIG',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    unawaited(
      _remoteConfig.fetch().catchError((Object error, StackTrace stackTrace) {
        log(
          'Remote Config fetch failed; keeping cached values',
          name: 'REMOTE_CONFIG',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }
}
