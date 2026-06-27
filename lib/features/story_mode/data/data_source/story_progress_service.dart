import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';

abstract class StoryProgressDataSource {
  Future<DataState<StoryModeProgressModel>> ensureProgressDoc({
    required String userId,
    required String caseId,
  });

  Future<DataState<StoryModeProgressModel>> saveClueGuess({
    required String userId,
    required String caseId,
    required int clueIndex,
    required String guess,
  });

  Future<DataState<StoryModeProgressModel>> completeClue({
    required String userId,
    required String caseId,
    required int clueIndex,
    required bool solved,
  });

  Future<DataState<StoryModeProgressModel>> completeStoryCase({
    required String userId,
    required String caseId,
  });
}
