import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/remote_config/app_remote_config.dart';

void main() {
  group('HintPenalties.parse', () {
    test('reads the default value', () {
      final raw = FirebaseAppRemoteConfig
          .defaults[FirebaseAppRemoteConfig.hintPenaltiesKey] as String;

      expect(HintPenalties.parse(raw), HintPenalties.fallback);
    });

    test('reads custom values', () {
      expect(
        HintPenalties.parse('{"letter":2,"word":10}'),
        const HintPenalties(letter: 2, word: 10),
      );
    });

    test('falls back on empty, malformed or invalid input', () {
      for (final raw in [
        null,
        '',
        'not json',
        '[1,2]',
        '{"letter":5}',
        '{"letter":"5","word":15}',
        '{"letter":-1,"word":15}',
      ]) {
        expect(HintPenalties.parse(raw), HintPenalties.fallback, reason: raw);
      }
    });
  });

  group('XpLevelFormula.parse', () {
    test('reads the default value', () {
      final raw = FirebaseAppRemoteConfig
          .defaults[FirebaseAppRemoteConfig.xpLevelFormulaKey] as String;

      expect(XpLevelFormula.parse(raw), XpLevelFormula.fallback);
    });

    test('accepts an integer growth', () {
      expect(
        XpLevelFormula.parse('{"base":50,"growth":2}'),
        const XpLevelFormula(base: 50, growth: 2.0),
      );
    });

    test('falls back on empty, malformed or invalid input', () {
      for (final raw in [
        null,
        '',
        '{',
        '{"base":0,"growth":1.25}',
        '{"base":100,"growth":0.5}',
        '{"base":100.5,"growth":1.25}',
      ]) {
        expect(XpLevelFormula.parse(raw), XpLevelFormula.fallback, reason: raw);
      }
    });
  });

  test('defaults cover every key from the CW-005 card', () {
    expect(FirebaseAppRemoteConfig.defaults, {
      'crossword_hint_penalties': '{"letter":5,"word":15}',
      'crossword_reveals_per_puzzle': 3,
      'xp_level_formula': '{"base":100,"growth":1.25}',
      'crossword_autosave_seconds': 30,
      'min_supported_build': 0,
    });
  });
}
