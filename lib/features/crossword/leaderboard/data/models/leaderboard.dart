import 'package:wordshool/core/firebase/dt_converter.dart';
import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';

class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.uid,
    required super.displayName,
    super.photoUrl,
    required super.points,
    required super.puzzlesSolved,
  });

  /// A `top50` item (has `uid`) or an `entries/{uid}` doc ([documentId]).
  factory LeaderboardEntryModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    return LeaderboardEntryModel(
      uid: documentId ?? asString(json['uid']),
      displayName: asString(json['displayName'], 'Player'),
      photoUrl: json['photoUrl'] as String?,
      points: asInt(json['points']),
      puzzlesSolved: asInt(json['puzzlesSolved']),
    );
  }
}

class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    required super.boardId,
    super.top,
    super.me,
    super.myRank,
    super.updatedAt,
  });

  /// The board doc (`top50`, `updatedAt`); [me]/[myRank] come from other reads.
  factory LeaderboardModel.fromJson(
    Map<String, dynamic> json, {
    required String documentId,
    LeaderboardEntryEntity? me,
    int? myRank,
  }) {
    final top = json['top50'] is List ? json['top50'] as List : const [];
    return LeaderboardModel(
      boardId: documentId,
      top: [
        for (final e in top.whereType<Map>())
          LeaderboardEntryModel.fromJson(Map<String, dynamic>.from(e)),
      ],
      me: me,
      myRank: myRank,
      updatedAt: FirebaseDTConverter.tryParse(json['updatedAt']),
    );
  }
}
