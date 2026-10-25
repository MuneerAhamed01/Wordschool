import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/result/domain/utils/xp_level.dart';

void main() {
  group('levelFor (base 100, growth 1.25)', () {
    LevelProgress level(int xp) => levelFor(xp, base: 100, growth: 1.25);

    test('starts at level 1', () {
      expect(level(0),
          const LevelProgress(level: 1, xpIntoLevel: 0, xpForLevel: 100));
      expect(level(-5).level, 1);
      expect(level(99).xpIntoLevel, 99);
    });

    test('each level needs base × growth^(n−1)', () {
      expect(level(100),
          const LevelProgress(level: 2, xpIntoLevel: 0, xpForLevel: 125));
      expect(level(225),
          const LevelProgress(level: 3, xpIntoLevel: 0, xpForLevel: 156));
      expect(level(300).fraction, closeTo(75 / 156, 1e-9));
    });

    test('growth 1 is a flat curve', () {
      expect(levelFor(1000, base: 100, growth: 1).level, 11);
    });
  });
}
