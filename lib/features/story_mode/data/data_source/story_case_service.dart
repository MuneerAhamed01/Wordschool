import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/models/detective_case.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';

abstract class StoryCaseDataSource {
  Future<DataState<DetectiveCaseModel>> getTodayCase();

  Future<DataState<DetectiveCaseModel>> getCaseByDate(String dateId);

  Future<StoryModeProgressModel?> getTodayProgress(String userId);
}
