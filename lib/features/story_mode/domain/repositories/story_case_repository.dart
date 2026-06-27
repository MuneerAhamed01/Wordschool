import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';

abstract class StoryCaseRepository {
  Future<DataState<DetectiveCaseEntity>> getTodayCase();

  Future<DataState<DetectiveCaseEntity>> getCaseByDate(String dateId);

  Future<StoryModeProgressEntity?> getTodayProgress(String userId);
}
