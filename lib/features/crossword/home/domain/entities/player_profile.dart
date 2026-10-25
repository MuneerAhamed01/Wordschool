import 'package:equatable/equatable.dart';

/// `users/{uid}.crossword` — written only by `submitCrossword`.
class CrosswordStatsEntity extends Equatable {
  const CrosswordStatsEntity({
    this.played = 0,
    this.solved = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSolvedDate,
    this.bestTimeSec,
  });

  static const empty = CrosswordStatsEntity();

  final int played;
  final int solved;
  final int currentStreak;
  final int longestStreak;

  /// IST `YYYY-MM-DD` of the last completed puzzle.
  final String? lastSolvedDate;
  final int? bestTimeSec;

  @override
  List<Object?> get props => [
        played,
        solved,
        currentStreak,
        longestStreak,
        lastSolvedDate,
        bestTimeSec
      ];
}

/// The player root doc (`users/{uid}`, DEC-006) as the app reads it.
class PlayerProfileEntity extends Equatable {
  const PlayerProfileEntity({
    required this.uid,
    this.displayName = '',
    this.photoUrl,
    this.xp = 0,
    this.crossword = CrosswordStatsEntity.empty,
  });

  final String uid;
  final String displayName;
  final String? photoUrl;
  final int xp;
  final CrosswordStatsEntity crossword;

  @override
  List<Object?> get props => [uid, displayName, photoUrl, xp, crossword];
}
