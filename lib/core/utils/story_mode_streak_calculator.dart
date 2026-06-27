import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';

class StoryModeStreakUpdateResult {
  const StoryModeStreakUpdateResult({
    required this.detectivePoints,
    required this.storyModeStreak,
    required this.lastStoryModeStreakDate,
    required this.storyModeLongestStreak,
  });

  final int detectivePoints;
  final int storyModeStreak;
  final String lastStoryModeStreakDate;
  final int storyModeLongestStreak;
}

class StoryModeStreakCalculator {
  StoryModeStreakCalculator._();

  static StoryModeStreakUpdateResult calculateAfterCaseCompletion({
    required UserGameStateEntity currentState,
    required String completedCaseDateId,
    required int score,
  }) {
    final todayDateId = DateHelper.todayDateId();
    final updatedDetectivePoints = currentState.detectivePoints + score;

    if (completedCaseDateId != todayDateId) {
      return StoryModeStreakUpdateResult(
        detectivePoints: updatedDetectivePoints,
        storyModeStreak: currentState.storyModeStreak,
        lastStoryModeStreakDate: currentState.lastStoryModeStreakDate ?? '',
        storyModeLongestStreak: currentState.storyModeLongestStreak,
      );
    }

    if (currentState.lastStoryModeStreakDate == todayDateId) {
      return StoryModeStreakUpdateResult(
        detectivePoints: updatedDetectivePoints,
        storyModeStreak: currentState.storyModeStreak,
        lastStoryModeStreakDate: todayDateId,
        storyModeLongestStreak: currentState.storyModeLongestStreak,
      );
    }

    final yesterdayDateId = DateHelper.previousDateId(todayDateId);
    final updatedStreak = currentState.lastStoryModeStreakDate == yesterdayDateId
        ? currentState.storyModeStreak + 1
        : 1;

    final updatedLongestStreak = updatedStreak > currentState.storyModeLongestStreak
        ? updatedStreak
        : currentState.storyModeLongestStreak;

    return StoryModeStreakUpdateResult(
      detectivePoints: updatedDetectivePoints,
      storyModeStreak: updatedStreak,
      lastStoryModeStreakDate: todayDateId,
      storyModeLongestStreak: updatedLongestStreak,
    );
  }
}
