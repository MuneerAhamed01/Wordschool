import 'package:equatable/equatable.dart';

class DetectiveLeaderboardEntry extends Equatable {
  const DetectiveLeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.totalPoints,
    required this.casesCompleted,
  });

  final String userId;
  final String displayName;
  final int totalPoints;
  final int casesCompleted;

  @override
  List<Object?> get props =>
      [userId, displayName, totalPoints, casesCompleted];
}

class DetectiveLeaderboardSnapshot extends Equatable {
  const DetectiveLeaderboardSnapshot({
    required this.weekId,
    required this.topEntries,
    this.currentUserEntry,
    this.currentUserRank,
  });

  final String weekId;
  final List<DetectiveLeaderboardEntry> topEntries;
  final DetectiveLeaderboardEntry? currentUserEntry;
  final int? currentUserRank;

  @override
  List<Object?> get props =>
      [weekId, topEntries, currentUserEntry, currentUserRank];
}
