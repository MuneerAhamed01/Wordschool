import 'package:equatable/equatable.dart';

/// One row of a weekly board (`leaderboards/{boardId}` `top50[]` or `entries/{uid}`).
class LeaderboardEntryEntity extends Equatable {
  const LeaderboardEntryEntity({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.points,
    required this.puzzlesSolved,
  });

  final String uid;
  final String displayName;
  final String? photoUrl;
  final int points;
  final int puzzlesSolved;

  @override
  List<Object?> get props =>
      [uid, displayName, photoUrl, points, puzzlesSolved];
}

/// This week's crossword board, plus the player's own row and rank.
class LeaderboardEntity extends Equatable {
  const LeaderboardEntity({
    required this.boardId,
    this.top = const [],
    this.me,
    this.myRank,
    this.updatedAt,
  });

  /// `crossword-2026-W43`.
  final String boardId;

  /// Sorted by points, best first (refreshed every 15 min).
  final List<LeaderboardEntryEntity> top;

  /// Null until the player completes a puzzle this week.
  final LeaderboardEntryEntity? me;
  final int? myRank;
  final DateTime? updatedAt;

  /// Whether the player's row is already in [top] (no pinned row needed).
  bool get meInTop => me != null && top.any((e) => e.uid == me!.uid);

  @override
  List<Object?> get props => [boardId, top, me, myRank, updatedAt];
}
