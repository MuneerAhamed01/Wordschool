import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_case_service.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';

class StoryCaseRepositoryImpl implements StoryCaseRepository {
  StoryCaseRepositoryImpl({required StoryCaseDataSource storyCaseDataSource})
      : _storyCaseDataSource = storyCaseDataSource;

  final StoryCaseDataSource _storyCaseDataSource;

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
}
