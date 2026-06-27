import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/story_mode/domain/entities/case_outcome.dart';

/// Story mode analytics helpers (Phase 10).
class StoryAnalytics {
  StoryAnalytics._();

  static AnalyticsService? get _analytics =>
      getIt.isRegistered<AnalyticsService>()
          ? getIt<AnalyticsService>()
          : null;

  static Future<void> caseStarted() async =>
      await _analytics?.logStoryCaseStarted();

  static Future<void> clueStarted({required int clueIndex}) async =>
      await _analytics?.logStoryClueStarted(clueIndex: clueIndex);

  static Future<void> clueSolved({
    required int clueIndex,
    required int attempts,
  }) async =>
      await _analytics?.logStoryClueSolved(
        clueIndex: clueIndex,
        attempts: attempts,
      );

  static Future<void> clueFailed({required int clueIndex}) async =>
      await _analytics?.logStoryClueFailed(clueIndex: clueIndex);

  static Future<void> caseCompleted({
    required CaseOutcome outcome,
    required int score,
  }) async =>
      await _analytics?.logStoryCaseCompleted(
        outcome: outcome.name,
        score: score,
      );

  static Future<void> shareTapped() async =>
      await _analytics?.logStoryShareTapped();

  static Future<void> hintUsed({required String source}) async =>
      await _analytics?.logStoryHintUsed(source: source);
}
