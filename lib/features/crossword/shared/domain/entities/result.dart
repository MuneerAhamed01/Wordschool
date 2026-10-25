import 'package:equatable/equatable.dart';

/// Server score of one puzzle (`crosswordProgress.result`, DEC-011).
class CrosswordResultEntity extends Equatable {
  const CrosswordResultEntity({
    required this.score,
    required this.correctWords,
    required this.totalWords,
    required this.xpEarned,
    required this.timeSec,
    this.wrongWordIds = const [],
    this.revealedWordIds = const [],
  });

  /// % of words correct.
  final int score;
  final int correctWords;
  final int totalWords;
  final int xpEarned;
  final int timeSec;

  /// Includes revealed words.
  final List<String> wrongWordIds;
  final List<String> revealedWordIds;

  bool get isPerfect => wrongWordIds.isEmpty;

  @override
  List<Object?> get props => [
        score,
        correctWords,
        totalWords,
        xpEarned,
        timeSec,
        wrongWordIds,
        revealedWordIds,
      ];
}

/// What `submitCrossword` returns: the result plus the player's new totals.
class CrosswordSubmitOutcome extends Equatable {
  const CrosswordSubmitOutcome({
    required this.result,
    required this.xp,
    required this.currentStreak,
    this.alreadySubmitted = false,
  });

  final CrosswordResultEntity result;

  /// Total XP after this puzzle.
  final int xp;
  final int currentStreak;
  final bool alreadySubmitted;

  @override
  List<Object?> get props => [result, xp, currentStreak, alreadySubmitted];
}
