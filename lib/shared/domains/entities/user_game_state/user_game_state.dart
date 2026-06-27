import 'package:equatable/equatable.dart';

class UserGameStateEntity extends Equatable {
  final String id;
  final int streak;
  final int longestStreak;
  final String? lastStreakDate;
  final int completedGames;
  final int totalGames;
  final int detectivePoints;
  final int storyModeStreak;
  final int storyModeLongestStreak;
  final String? lastStoryModeStreakDate;
  final int hintPackBalance;
  final bool hasRemoveAds;
  final bool isDetectivePro;
  final DateTime createdDate;
  final DateTime updatedDate;

  const UserGameStateEntity({
    required this.id,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastStreakDate,
    this.completedGames = 0,
    this.totalGames = 0,
    this.detectivePoints = 0,
    this.storyModeStreak = 0,
    this.storyModeLongestStreak = 0,
    this.lastStoryModeStreakDate,
    this.hintPackBalance = 0,
    this.hasRemoveAds = false,
    this.isDetectivePro = false,
    required this.createdDate,
    required this.updatedDate,
  });

  @override
  List<Object?> get props => [
        id,
        streak,
        longestStreak,
        lastStreakDate,
        completedGames,
        totalGames,
        detectivePoints,
        storyModeStreak,
        storyModeLongestStreak,
        lastStoryModeStreakDate,
        hintPackBalance,
        hasRemoveAds,
        isDetectivePro,
        createdDate,
        updatedDate,
      ];
}
