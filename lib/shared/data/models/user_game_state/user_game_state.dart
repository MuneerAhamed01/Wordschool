import 'package:wordshool/core/firebase/dt_converter.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';

class UserGameStateModel extends UserGameStateEntity {
  const UserGameStateModel({
    required super.id,
    super.streak = 0,
    super.longestStreak = 0,
    super.lastStreakDate,
    super.completedGames = 0,
    super.totalGames = 0,
    required super.createdDate,
    required super.updatedDate,
  });

  UserGameStateModel copyWith({
    String? id,
    int? streak,
    int? longestStreak,
    String? lastStreakDate,
    int? completedGames,
    int? totalGames,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return UserGameStateModel(
      id: id ?? this.id,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      completedGames: completedGames ?? this.completedGames,
      totalGames: totalGames ?? this.totalGames,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  factory UserGameStateModel.fromJson(Map<String, dynamic> json) {
    return UserGameStateModel(
      id: json['id'] as String,
      streak: (json['streak'] as int?) ?? 0,
      longestStreak: (json['longestStreak'] as int?) ?? 0,
      lastStreakDate: json['lastStreakDate'] as String?,
      completedGames: (json['completedGames'] as int?) ?? 0,
      totalGames: (json['totalGames'] as int?) ?? 0,
      createdDate: FirebaseDTConverter.fromTimestamp(json['createdDate']),
      updatedDate: FirebaseDTConverter.fromTimestamp(json['updatedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streak': streak,
      'longestStreak': longestStreak,
      if (lastStreakDate != null) 'lastStreakDate': lastStreakDate,
      'completedGames': completedGames,
      'totalGames': totalGames,
      'createdDate': FirebaseDTConverter.toTimestamp(createdDate),
      'updatedDate': FirebaseDTConverter.toTimestamp(updatedDate),
    };
  }
}
