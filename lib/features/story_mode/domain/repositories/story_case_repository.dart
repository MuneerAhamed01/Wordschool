import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';

abstract class StoryCaseRepository {
  Future<DataState<DetectiveCaseEntity>> getTodayCase();

  Future<DataState<DetectiveCaseEntity>> getCaseByDate(String dateId);

  Future<StoryModeProgressEntity?> getTodayProgress(String userId);

  Future<DataState<StoryModeProgressEntity>> ensureProgressDoc({
    required String userId,
    required String caseId,
  });

  Future<DataState<StoryModeProgressEntity>> saveClueGuess({
    required String userId,
    required String caseId,
    required int clueIndex,
    required String guess,
  });

  Future<DataState<StoryModeProgressEntity>> completeClue({
    required String userId,
    required String caseId,
    required int clueIndex,
    required bool solved,
  });

  Future<DataState<StoryModeProgressEntity>> completeStoryCase({
    required String userId,
    required String caseId,
  });
}
