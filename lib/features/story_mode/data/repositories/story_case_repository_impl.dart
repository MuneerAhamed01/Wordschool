import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_case_service.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_progress_service.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';

class StoryCaseRepositoryImpl implements StoryCaseRepository {
  StoryCaseRepositoryImpl({
    required StoryCaseDataSource storyCaseDataSource,
    required StoryProgressDataSource storyProgressDataSource,
  })  : _storyCaseDataSource = storyCaseDataSource,
        _storyProgressDataSource = storyProgressDataSource;

  final StoryCaseDataSource _storyCaseDataSource;
  final StoryProgressDataSource _storyProgressDataSource;

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
}
