import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_case_service.dart';
import 'package:wordshool/features/story_mode/data/models/detective_case.dart';
import 'package:wordshool/features/story_mode/data/models/detective_clue.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/data/repositories/story_case_repository_impl.dart';
import 'package:wordshool/features/story_mode/domain/entities/clue_type.dart';

import '../data_source/story_progress_service_test.dart';

class FakeStoryCaseDataSource extends StoryCaseDataSource {
  FakeStoryCaseDataSource({
    this.caseResult,
    this.progress,
  });

  DataState<DetectiveCaseModel>? caseResult;
  StoryModeProgressModel? progress;

  @override
  Future<DataState<DetectiveCaseModel>> getCaseByDate(String dateId) async {
    return caseResult ?? DataError(error: AppError(error: 'unset', code: '500'));
  }

  @override
  Future<DataState<DetectiveCaseModel>> getTodayCase() {
    return getCaseByDate('2026-06-18');
  }

  @override
  Future<StoryModeProgressModel?> getTodayProgress(String userId) async {
    return progress;
  }
}

DetectiveCaseModel _sampleCase() {
  return DetectiveCaseModel(
    id: '2026-06-18',
    title: 'The Midnight Ledger',
    introduction: 'A financier is found dead.',
    clues: const [
      DetectiveClueModel(
        index: 0,
        type: ClueType.location,
        hint: 'Where the crime happened.',
        answer: 'STUDY',
        reaction: 'The study was locked.',
        investigatePrompt: 'Find the location.',
      ),
      DetectiveClueModel(
        index: 1,
        type: ClueType.weapon,
        hint: 'What caused the wound.',
        answer: 'KNIFE',
        reaction: 'A knife is missing.',
        investigatePrompt: 'Find the weapon.',
      ),
      DetectiveClueModel(
        index: 2,
        type: ClueType.suspect,
        hint: 'Who benefits most.',
        answer: 'HEIRS',
        reaction: 'The heir had motive.',
        investigatePrompt: 'Name the suspect.',
      ),
    ],
    resolution: 'The case is closed.',
    createdAt: DateTime.utc(2026, 6, 18),
  );
}

void main() {
  group('StoryCaseRepositoryImpl', () {
    test('returns today case from data source', () async {
      final dataSource = FakeStoryCaseDataSource(
        caseResult: DataSuccess(data: _sampleCase()),
      );
      final repository = StoryCaseRepositoryImpl(
        storyCaseDataSource: dataSource,
        storyProgressDataSource: InMemoryStoryProgressDataSource(),
      );

      final result = await repository.getTodayCase();

      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data!.title, 'The Midnight Ledger');
    });

    test('propagates data source errors', () async {
      final dataSource = FakeStoryCaseDataSource(
        caseResult: DataError(
          error: AppError(
            error: 'Case not found',
            message: "Today's detective case isn't ready yet. Check back soon.",
            code: '404',
          ),
        ),
      );
      final repository = StoryCaseRepositoryImpl(
        storyCaseDataSource: dataSource,
        storyProgressDataSource: InMemoryStoryProgressDataSource(),
      );

      final result = await repository.getTodayCase();

      expect(result, isA<DataError>());
      expect(
        (result as DataError).error?.message,
        "Today's detective case isn't ready yet. Check back soon.",
      );
    });

    test('returns progress from data source', () async {
      final progress = StoryModeProgressModel.empty(
        userId: 'user-1',
        caseId: '2026-06-18',
      );
      final dataSource = FakeStoryCaseDataSource(progress: progress);
      final repository = StoryCaseRepositoryImpl(
        storyCaseDataSource: dataSource,
        storyProgressDataSource: InMemoryStoryProgressDataSource(),
      );

      final result = await repository.getTodayProgress('user-1');

      expect(result, progress);
    });
  });
}
