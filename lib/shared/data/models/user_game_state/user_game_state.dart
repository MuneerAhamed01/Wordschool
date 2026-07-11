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
    super.detectivePoints = 0,
    super.storyModeStreak = 0,
    super.storyModeLongestStreak = 0,
    super.lastStoryModeStreakDate,
    super.hintPackBalance = 0,
    super.hasRemoveAds = false,
    super.isDetectivePro = false,
    super.deletedAt,
    super.blockedAt,
    super.blockedReason,
    super.blockedBy,
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
    int? detectivePoints,
    int? storyModeStreak,
    int? storyModeLongestStreak,
    String? lastStoryModeStreakDate,
    int? hintPackBalance,
    bool? hasRemoveAds,
    bool? isDetectivePro,
    DateTime? deletedAt,
    DateTime? blockedAt,
    String? blockedReason,
    String? blockedBy,
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
      detectivePoints: detectivePoints ?? this.detectivePoints,
      storyModeStreak: storyModeStreak ?? this.storyModeStreak,
      storyModeLongestStreak:
          storyModeLongestStreak ?? this.storyModeLongestStreak,
      lastStoryModeStreakDate:
          lastStoryModeStreakDate ?? this.lastStoryModeStreakDate,
      hintPackBalance: hintPackBalance ?? this.hintPackBalance,
      hasRemoveAds: hasRemoveAds ?? this.hasRemoveAds,
      isDetectivePro: isDetectivePro ?? this.isDetectivePro,
      deletedAt: deletedAt ?? this.deletedAt,
      blockedAt: blockedAt ?? this.blockedAt,
      blockedReason: blockedReason ?? this.blockedReason,
      blockedBy: blockedBy ?? this.blockedBy,
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
      detectivePoints: (json['detectivePoints'] as int?) ?? 0,
      storyModeStreak: (json['storyModeStreak'] as int?) ?? 0,
      storyModeLongestStreak: (json['storyModeLongestStreak'] as int?) ?? 0,
      lastStoryModeStreakDate: json['lastStoryModeStreakDate'] as String?,
      hintPackBalance: (json['hintPackBalance'] as int?) ?? 0,
      hasRemoveAds: (json['hasRemoveAds'] as bool?) ?? false,
      isDetectivePro: (json['isDetectivePro'] as bool?) ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : FirebaseDTConverter.fromTimestamp(json['deletedAt']),
      blockedAt: json['blockedAt'] == null
          ? null
          : FirebaseDTConverter.fromTimestamp(json['blockedAt']),
      blockedReason: json['blockedReason'] as String?,
      blockedBy: json['blockedBy'] as String?,
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
      'detectivePoints': detectivePoints,
      'storyModeStreak': storyModeStreak,
      'storyModeLongestStreak': storyModeLongestStreak,
      if (lastStoryModeStreakDate != null)
        'lastStoryModeStreakDate': lastStoryModeStreakDate,
      'hintPackBalance': hintPackBalance,
      'hasRemoveAds': hasRemoveAds,
      'isDetectivePro': isDetectivePro,
      if (deletedAt != null)
        'deletedAt': FirebaseDTConverter.toTimestamp(deletedAt!),
      if (blockedAt != null)
        'blockedAt': FirebaseDTConverter.toTimestamp(blockedAt!),
      if (blockedReason != null) 'blockedReason': blockedReason,
      if (blockedBy != null) 'blockedBy': blockedBy,
      'createdDate': FirebaseDTConverter.toTimestamp(createdDate),
      'updatedDate': FirebaseDTConverter.toTimestamp(updatedDate),
    };
  }
}
