import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/entities/case_outcome.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';
import 'package:wordshool/features/story_mode/domain/usecases/load_today_detective_case.dart';
import 'package:wordshool/features/story_mode/domain/usecases/today_detective_case_result.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_case_bloc/story_case_bloc.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';

DetectiveCaseEntity _sampleCase() {
  return DetectiveCaseEntity(
    id: '2026-06-18',
    title: 'Test Case',
    introduction: 'Intro',
    clues: const [],
    resolution: 'Done',
    createdAt: DateTime.utc(2026, 6, 18),
  );
}

StoryModeProgressModel _completedProgress() {
  return StoryModeProgressModel(
    userId: 'user-1',
    caseId: '2026-06-18',
    currentClueIndex: 3,
    clueAttempts: const [1, 1, 1],
    clueGuesses: const [[], [], []],
    clueSolved: const [true, true, true],
    totalScore: 300,
    outcome: CaseOutcome.caseClosed,
    completedAt: DateTime.utc(2026, 6, 27),
  );
}

class FakeLoadTodayDetectiveCaseUseCase extends LoadTodayDetectiveCaseUseCase {
  FakeLoadTodayDetectiveCaseUseCase(this._result)
      : super(
          storyCaseRepository: _UnusedStoryCaseRepository(),
          getCurrentUserUseCase: _UnusedGetCurrentUserUseCase(),
        );

  final DataState<TodayDetectiveCaseResult> _result;

  @override
  Future<DataState<TodayDetectiveCaseResult>> call({void param}) async {
    return _result;
  }
}

class _UnusedStoryCaseRepository implements StoryCaseRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedGetCurrentUserUseCase extends GetCurrentUserUseCase {
  _UnusedGetCurrentUserUseCase()
      : super(sessionRepository: _UnusedSessionRepository());
}

class _UnusedSessionRepository implements SessionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('StoryCaseBloc progress updates', () {
    test('emits alreadyCompleted when progress has completedAt', () async {
      final bloc = StoryCaseBloc(
        loadTodayDetectiveCaseUseCase: FakeLoadTodayDetectiveCaseUseCase(
          DataSuccess(
            data: TodayDetectiveCaseResult(detectiveCase: _sampleCase()),
          ),
        ),
      );

      await bloc.stream.firstWhere(
        (state) => state.maybeWhen(
          loaded: (_, __) => true,
          orElse: () => false,
        ),
      );

      bloc.add(StoryCaseEvent.progressUpdated(_completedProgress()));

      final finalState = await bloc.stream.firstWhere(
        (state) => state.maybeWhen(
          alreadyCompleted: (_, __) => true,
          orElse: () => false,
        ),
      );

      expect(
        finalState,
        StoryCaseState.alreadyCompleted(
          detectiveCase: _sampleCase(),
          progress: _completedProgress(),
        ),
      );

      await bloc.close();
    });
  });
}
