import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_case_service.dart';
import 'package:wordshool/features/story_mode/data/models/detective_case.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/data/repositories/story_case_repository_impl.dart';
import 'package:wordshool/features/story_mode/domain/usecases/complete_story_case.dart';
import 'package:wordshool/features/story_mode/domain/usecases/complete_story_clue.dart';
import 'package:wordshool/features/story_mode/domain/usecases/save_clue_guess.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_clue_bloc/story_clue_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';

import '../../data/data_source/story_progress_service_test.dart';

class EmptyStoryCaseDataSource extends StoryCaseDataSource {
  @override
  Future<DataState<DetectiveCaseModel>> getCaseByDate(String dateId) {
    throw UnimplementedError();
  }

  @override
  Future<DataState<DetectiveCaseModel>> getTodayCase() {
    throw UnimplementedError();
  }

  @override
  Future<StoryModeProgressModel?> getTodayProgress(String userId) async {
    return null;
  }
}

StoryModeProgressModel _progressWithAttempts(int attempts) {
  return StoryModeProgressModel(
    userId: 'user-1',
    caseId: '2026-06-18',
    currentClueIndex: 0,
    clueAttempts: [attempts, 0, 0],
    clueGuesses: [
      List.filled(attempts, 'WRONG'),
      [],
      [],
    ],
    clueSolved: const [false, false, false],
    totalScore: 0,
  );
}

StoryClueBloc _createBloc(InMemoryStoryProgressDataSource dataSource) {
  final repository = StoryCaseRepositoryImpl(
    storyCaseDataSource: EmptyStoryCaseDataSource(),
    storyProgressDataSource: dataSource,
  );

  return StoryClueBloc(
    saveClueGuessUseCase: SaveClueGuessUseCase(storyCaseRepository: repository),
    completeStoryClueUseCase:
        CompleteStoryClueUseCase(storyCaseRepository: repository),
    completeStoryCaseUseCase:
        CompleteStoryCaseUseCase(storyCaseRepository: repository),
  );
}

Future<void> initializeClue(StoryClueBloc bloc, InitializeClue event) async {
  bloc.add(event);
  await bloc.stream.firstWhere((state) => state is StoryClueReady);
}

void main() {
  group('StoryClueBloc', () {
    test('initializes ready state from progress', () async {
      final bloc = _createBloc(InMemoryStoryProgressDataSource());

      await initializeClue(
        bloc,
        const InitializeClue(
          clueIndex: 0,
          caseId: '2026-06-18',
          answer: 'STUDY',
          userId: 'user-1',
        ),
      );

      expect(bloc.state, isA<StoryClueReady>());
      expect((bloc.state as StoryClueReady).answer, 'STUDY');
    });

    test('blocks submit after max attempts', () async {
      final dataSource = InMemoryStoryProgressDataSource();
      final bloc = _createBloc(dataSource);

      await initializeClue(
        bloc,
        InitializeClue(
          clueIndex: 0,
          caseId: '2026-06-18',
          answer: 'STUDY',
          userId: 'user-1',
          progress: _progressWithAttempts(5),
        ),
      );

      bloc.add(const SubmitGuess('WRONG'));
      await Future<void>.delayed(Duration.zero);

      expect((bloc.state as StoryClueReady).attemptCount, 5);
    });

    test('completeClue marks state finished', () async {
      final bloc = _createBloc(InMemoryStoryProgressDataSource());

      await initializeClue(
        bloc,
        const InitializeClue(
          clueIndex: 0,
          caseId: '2026-06-18',
          answer: 'STUDY',
          userId: 'user-1',
        ),
      );
      bloc.add(const CompleteClue(solved: true));
      await bloc.stream.firstWhere(
        (state) => state.maybeWhen(
          ready: (_, __, ___, ____, _____, isCompleted) => isCompleted,
          orElse: () => false,
        ),
      );

      expect((bloc.state as StoryClueReady).isClueFinished, isTrue);
    });
  });
}
