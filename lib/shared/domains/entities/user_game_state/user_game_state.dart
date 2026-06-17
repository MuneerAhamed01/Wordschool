import 'package:equatable/equatable.dart';

class UserGameStateEntity extends Equatable {
  final String id;
  final int streak;
  final int longestStreak;
  final String? lastStreakDate;
  final int completedGames;
  final int totalGames;
  final DateTime createdDate;
  final DateTime updatedDate;

  const UserGameStateEntity({
    required this.id,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastStreakDate,
    this.completedGames = 0,
    this.totalGames = 0,
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
        createdDate,
        updatedDate,
      ];
}
