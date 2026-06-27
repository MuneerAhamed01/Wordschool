import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/story_mode/domain/utils/detective_score_calculator.dart';

void main() {
  group('DetectiveScoreCalculator.pointsForClue', () {
    test('maps solved attempts 1-5 to correct points', () {
      expect(
        DetectiveScoreCalculator.pointsForClue(solved: true, attempts: 1),
        100,
      );
      expect(
        DetectiveScoreCalculator.pointsForClue(solved: true, attempts: 2),
        80,
      );
      expect(
        DetectiveScoreCalculator.pointsForClue(solved: true, attempts: 3),
        60,
      );
      expect(
        DetectiveScoreCalculator.pointsForClue(solved: true, attempts: 4),
        40,
      );
      expect(
        DetectiveScoreCalculator.pointsForClue(solved: true, attempts: 5),
        20,
      );
    });

    test('returns 0 when clue failed', () {
      expect(
        DetectiveScoreCalculator.pointsForClue(solved: false, attempts: 5),
        0,
      );
    });

    test('returns 0 for invalid attempt counts', () {
      expect(
        DetectiveScoreCalculator.pointsForClue(solved: true, attempts: 0),
        0,
      );
      expect(
        DetectiveScoreCalculator.pointsForClue(solved: true, attempts: 6),
        0,
      );
    });
  });

  group('DetectiveScoreCalculator.totalScore', () {
    test('perfect run scores 300', () {
      expect(
        DetectiveScoreCalculator.totalScore(
          clueSolved: const [true, true, true],
          clueAttempts: const [1, 1, 1],
          currentClueIndex: 3,
        ),
        300,
      );
    });

    test('fail clue 1, solve 2 and 3 on first attempt', () {
      expect(
        DetectiveScoreCalculator.totalScore(
          clueSolved: const [false, true, true],
          clueAttempts: const [5, 1, 1],
          currentClueIndex: 3,
        ),
        200,
      );
    });

    test('ignores unfinished clues', () {
      expect(
        DetectiveScoreCalculator.totalScore(
          clueSolved: const [true, false, false],
          clueAttempts: const [1, 0, 0],
          currentClueIndex: 1,
        ),
        100,
      );
    });
  });
}
