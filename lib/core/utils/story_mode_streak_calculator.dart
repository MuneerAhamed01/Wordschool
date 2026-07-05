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
    // Story case IDs use UTC date keys (see StoryCaseDataSource.getTodayCase).
    final todayCaseDateId = DateHelper.todayUtcDateId();
    final updatedDetectivePoints = currentState.detectivePoints + score;

    if (completedCaseDateId != todayCaseDateId) {
      return StoryModeStreakUpdateResult(
        detectivePoints: updatedDetectivePoints,
        storyModeStreak: currentState.storyModeStreak,
        lastStoryModeStreakDate: currentState.lastStoryModeStreakDate ?? '',
        storyModeLongestStreak: currentState.storyModeLongestStreak,
      );
    }

    if (currentState.lastStoryModeStreakDate == todayCaseDateId) {
      return StoryModeStreakUpdateResult(
        detectivePoints: updatedDetectivePoints,
        storyModeStreak: currentState.storyModeStreak,
        lastStoryModeStreakDate: todayCaseDateId,
        storyModeLongestStreak: currentState.storyModeLongestStreak,
      );
    }

    final yesterdayDateId = DateHelper.previousDateId(todayCaseDateId);
    final updatedStreak = currentState.lastStoryModeStreakDate == yesterdayDateId
        ? currentState.storyModeStreak + 1
        : 1;

    final updatedLongestStreak = updatedStreak > currentState.storyModeLongestStreak
        ? updatedStreak
        : currentState.storyModeLongestStreak;

    return StoryModeStreakUpdateResult(
      detectivePoints: updatedDetectivePoints,
      storyModeStreak: updatedStreak,
      lastStoryModeStreakDate: todayCaseDateId,
      storyModeLongestStreak: updatedLongestStreak,
    );
  }
}
