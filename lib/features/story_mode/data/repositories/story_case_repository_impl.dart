import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/story_mode_streak_calculator.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_case_service.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_progress_service.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';
import 'package:wordshool/shared/data/data_source/user_game_state_service.dart';
import 'package:wordshool/shared/data/models/user_game_state/user_game_state.dart';

class StoryCaseRepositoryImpl implements StoryCaseRepository {
  StoryCaseRepositoryImpl({
    required StoryCaseDataSource storyCaseDataSource,
    required StoryProgressDataSource storyProgressDataSource,
    UserGameStateDataSource? userGameStateDataSource,
  })  : _storyCaseDataSource = storyCaseDataSource,
        _storyProgressDataSource = storyProgressDataSource,
        _userGameStateDataSource = userGameStateDataSource;

  final StoryCaseDataSource _storyCaseDataSource;
  final StoryProgressDataSource _storyProgressDataSource;
  final UserGameStateDataSource? _userGameStateDataSource;

  @override
  Future<DataState<DetectiveCaseEntity>> getTodayCase() {
    return _storyCaseDataSource.getTodayCase();
  }

  @override
  Future<DataState<DetectiveCaseEntity>> getCaseByDate(String dateId) {
    return _storyCaseDataSource.getCaseByDate(dateId);
  }

  @override
  Future<StoryModeProgressEntity?> getTodayProgress(String userId) {
    return _storyCaseDataSource.getTodayProgress(userId);
  }

  @override
  Future<DataState<StoryModeProgressEntity>> ensureProgressDoc({
    required String userId,
    required String caseId,
  }) {
    return _storyProgressDataSource.ensureProgressDoc(
      userId: userId,
      caseId: caseId,
    );
  }

  @override
  Future<DataState<StoryModeProgressEntity>> saveClueGuess({
    required String userId,
    required String caseId,
    required int clueIndex,
    required String guess,
  }) {
    return _storyProgressDataSource.saveClueGuess(
      userId: userId,
      caseId: caseId,
      clueIndex: clueIndex,
      guess: guess,
    );
  }

  @override
  Future<DataState<StoryModeProgressEntity>> completeClue({
    required String userId,
    required String caseId,
    required int clueIndex,
    required bool solved,
  }) {
    return _storyProgressDataSource.completeClue(
      userId: userId,
      caseId: caseId,
      clueIndex: clueIndex,
      solved: solved,
    );
  }

  @override
  Future<DataState<StoryModeProgressEntity>> completeStoryCase({
    required String userId,
    required String caseId,
  }) async {
    final beforeResult = await _storyProgressDataSource.ensureProgressDoc(
      userId: userId,
      caseId: caseId,
    );
    if (beforeResult is! DataSuccess<StoryModeProgressEntity>) {
      return beforeResult;
    }

    if (beforeResult.data!.completedAt != null) {
      return beforeResult;
    }

    final progressResult = await _storyProgressDataSource.completeStoryCase(
      userId: userId,
      caseId: caseId,
    );

    if (progressResult is! DataSuccess<StoryModeProgressEntity>) {
      return progressResult;
    }

    final progress = progressResult.data!;
    final dataSource = _userGameStateDataSource;
    if (dataSource == null || progress.completedAt == null) {
      return progressResult;
    }

    final userStateResult = await dataSource.getUserGameState(userId);
    if (userStateResult is! DataSuccess<UserGameStateModel>) {
      return progressResult;
    }

    final streakUpdate = StoryModeStreakCalculator.calculateAfterCaseCompletion(
      currentState: userStateResult.data!,
      completedCaseDateId: caseId,
      score: progress.totalScore,
    );

    await dataSource.updateStoryModeStats(
      userId,
      detectivePoints: streakUpdate.detectivePoints,
      storyModeStreak: streakUpdate.storyModeStreak,
      lastStoryModeStreakDate: streakUpdate.lastStoryModeStreakDate,
      storyModeLongestStreak: streakUpdate.storyModeLongestStreak,
    );

    return progressResult;
  }
}
