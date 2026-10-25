import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/home/domain/entities/player_profile.dart';

class CrosswordStatsModel extends CrosswordStatsEntity {
  const CrosswordStatsModel({
    super.played,
    super.solved,
    super.currentStreak,
    super.longestStreak,
    super.lastSolvedDate,
    super.bestTimeSec,
  });

  factory CrosswordStatsModel.fromJson(Object? json) {
    final map = asMap(json);
    return CrosswordStatsModel(
      played: asInt(map['played']),
      solved: asInt(map['solved']),
      currentStreak: asInt(map['currentStreak']),
      longestStreak: asInt(map['longestStreak']),
      lastSolvedDate: map['lastSolvedDate'] as String?,
      bestTimeSec: asIntOrNull(map['bestTimeSec']),
    );
  }
}

class PlayerProfileModel extends PlayerProfileEntity {
  const PlayerProfileModel({
    required super.uid,
    super.displayName,
    super.photoUrl,
    super.xp,
    super.crossword,
  });

  /// [documentId] is the uid.
  factory PlayerProfileModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    return PlayerProfileModel(
      uid: documentId ?? asString(json['uid']),
      displayName: asString(json['displayName']),
      photoUrl: json['photoUrl'] as String?,
      xp: asInt(json['xp']),
      crossword: CrosswordStatsModel.fromJson(json['crossword']),
    );
  }
}
