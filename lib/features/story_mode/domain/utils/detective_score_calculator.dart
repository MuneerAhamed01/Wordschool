class DetectiveScoreCalculator {
  DetectiveScoreCalculator._();

  static const int maxPointsPerClue = 100;
  static const int maxPointsPerDay = 300;
  static const int maxAttempts = 5;

  static const Map<int, int> _pointsByAttempt = {
    1: 100,
    2: 80,
    3: 60,
    4: 40,
    5: 20,
  };

  static int pointsForClue({
    required bool solved,
    required int attempts,
  }) {
    if (!solved) {
      return 0;
    }

    return _pointsByAttempt[attempts] ?? 0;
  }

  static int totalScore({
    required List<bool> clueSolved,
    required List<int> clueAttempts,
    required int currentClueIndex,
  }) {
    var sum = 0;

    for (var index = 0; index < clueSolved.length; index++) {
      if (!_isClueFinished(index: index, currentClueIndex: currentClueIndex)) {
        continue;
      }

      sum += pointsForClue(
        solved: clueSolved[index],
        attempts: clueAttempts[index],
      );
    }

    return sum;
  }

  static bool _isClueFinished({
    required int index,
    required int currentClueIndex,
  }) {
    return index < currentClueIndex;
  }
}
