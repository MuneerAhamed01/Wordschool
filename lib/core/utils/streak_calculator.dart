import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';

class StreakUpdateResult {
  const StreakUpdateResult({
    required this.streak,
    required this.lastStreakDate,
    required this.longestStreak,
    required this.completedGames,
    required this.totalGames,
  });

  final int streak;
  final String lastStreakDate;
  final int longestStreak;
  final int completedGames;
  final int totalGames;
}

class StreakCalculator {
  StreakCalculator._();

  static StreakUpdateResult calculateAfterDailyCompletion({
    required UserGameStateEntity currentState,
    required String completedGameDateId,
    required bool isCorrect,
  }) {
    final todayDateId = DateHelper.todayDateId();

    if (completedGameDateId != todayDateId) {
      return StreakUpdateResult(
        streak: currentState.streak,
        lastStreakDate: currentState.lastStreakDate ?? '',
        longestStreak: currentState.longestStreak,
        completedGames: currentState.completedGames,
        totalGames: currentState.totalGames,
      );
    }

    if (currentState.lastStreakDate == todayDateId) {
      return StreakUpdateResult(
        streak: currentState.streak,
        lastStreakDate: todayDateId,
        longestStreak: currentState.longestStreak,
        completedGames: currentState.completedGames,
        totalGames: currentState.totalGames,
      );
    }

    final yesterdayDateId = DateHelper.previousDateId(todayDateId);
    final updatedStreak = currentState.lastStreakDate == yesterdayDateId
        ? currentState.streak + 1
        : 1;

    final updatedLongestStreak = updatedStreak > currentState.longestStreak
        ? updatedStreak
        : currentState.longestStreak;

    final updatedCompletedGames = isCorrect
        ? currentState.completedGames + 1
        : currentState.completedGames;

    return StreakUpdateResult(
      streak: updatedStreak,
      lastStreakDate: todayDateId,
      longestStreak: updatedLongestStreak,
      completedGames: updatedCompletedGames,
      totalGames: currentState.totalGames + 1,
    );
  }
}
