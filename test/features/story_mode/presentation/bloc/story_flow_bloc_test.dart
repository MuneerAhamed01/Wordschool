import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/story_mode/data/models/detective_case.dart';
import 'package:wordshool/features/story_mode/data/models/detective_clue.dart';
import 'package:wordshool/features/story_mode/domain/entities/clue_type.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';

DetectiveCaseModel sampleDetectiveCase() {
  return DetectiveCaseModel(
    id: '2026-06-18',
    title: 'The Midnight Ledger',
    introduction: 'Rain hammers the precinct windows.',
    clues: const [
      DetectiveClueModel(
        index: 0,
        type: ClueType.location,
        hint: 'Hint 0',
        answer: 'STUDY',
        reaction: 'Reaction 0',
        investigatePrompt: 'Investigate 0',
      ),
      DetectiveClueModel(
        index: 1,
        type: ClueType.weapon,
        hint: 'Hint 1',
        answer: 'KNIFE',
        reaction: 'Reaction 1',
        investigatePrompt: 'Investigate 1',
      ),
      DetectiveClueModel(
        index: 2,
        type: ClueType.suspect,
        hint: 'Hint 2',
        answer: 'HEIRS',
        reaction: 'Reaction 2',
        investigatePrompt: 'Investigate 2',
      ),
    ],
    resolution: 'Case closed.',
    createdAt: DateTime.utc(2026, 6, 18),
  );
}

Future<void> initializeFlow(StoryFlowBloc bloc, Initialize event) async {
  bloc.add(event);
  await bloc.stream.firstWhere((state) => state is StoryFlowReady);
}

void main() {
  group('StoryFlowBloc', () {
    test('initializes with all clues incomplete when no progress', () async {
      final bloc = StoryFlowBloc();
      final detectiveCase = sampleDetectiveCase();

      await initializeFlow(
        bloc,
        Initialize(
          detectiveCase: detectiveCase,
          isReadOnly: false,
        ),
      );

      expect(
        bloc.state,
        isA<StoryFlowReady>().having(
          (state) => state.completedClues,
          'completedClues',
          [false, false, false],
        ),
      );
      expect((bloc.state as StoryFlowReady).resumeClueIndex, 0);
    });

    test('seeds completed clues from currentClueIndex', () async {
      final bloc = StoryFlowBloc();
      final detectiveCase = sampleDetectiveCase();

      await initializeFlow(
        bloc,
        Initialize(
          detectiveCase: detectiveCase,
          progress: StoryModeProgressEntity(
            userId: 'user-1',
            caseId: '2026-06-18',
            currentClueIndex: 1,
            clueAttempts: [2, 0, 0],
            clueGuesses: [[], [], []],
            clueSolved: [true, false, false],
            totalScore: 80,
          ),
          isReadOnly: false,
        ),
      );

      expect((bloc.state as StoryFlowReady).completedClues, [true, false, false]);
      expect((bloc.state as StoryFlowReady).resumeClueIndex, 1);
    });

    test('marks failed clue complete when currentClueIndex advances', () async {
      final bloc = StoryFlowBloc();
      final detectiveCase = sampleDetectiveCase();

      await initializeFlow(
        bloc,
        Initialize(
          detectiveCase: detectiveCase,
          progress: StoryModeProgressEntity(
            userId: 'user-1',
            caseId: '2026-06-18',
            currentClueIndex: 1,
            clueAttempts: [5, 0, 0],
            clueGuesses: [
              ['WRONG', 'WRONG', 'WRONG', 'WRONG', 'WRONG'],
              [],
              [],
            ],
            clueSolved: [false, false, false],
            totalScore: 0,
          ),
          isReadOnly: false,
        ),
      );

      expect((bloc.state as StoryFlowReady).completedClues, [true, false, false]);
      expect(StoryFlowGating.canAccessReaction(bloc.state, 0), isTrue);
    });

    test('marks clue resolved in active mode', () async {
      final bloc = StoryFlowBloc();
      final detectiveCase = sampleDetectiveCase();

      await initializeFlow(
        bloc,
        Initialize(
          detectiveCase: detectiveCase,
          isReadOnly: false,
        ),
      );
      bloc.add(const MarkClueResolved(0));
      await bloc.stream.first;

      expect((bloc.state as StoryFlowReady).completedClues, [true, false, false]);
      expect((bloc.state as StoryFlowReady).resumeClueIndex, 1);
    });

    test('does not mark clue resolved in read-only mode', () async {
      final bloc = StoryFlowBloc();
      final detectiveCase = sampleDetectiveCase();

      await initializeFlow(
        bloc,
        Initialize(
          detectiveCase: detectiveCase,
          isReadOnly: true,
        ),
      );
      bloc.add(const MarkClueResolved(0));
      await Future<void>.delayed(Duration.zero);

      expect((bloc.state as StoryFlowReady).completedClues, [true, true, true]);
    });

    test('resetForLogout clears ready state', () async {
      final bloc = StoryFlowBloc();
      final detectiveCase = sampleDetectiveCase();

      await initializeFlow(
        bloc,
        Initialize(
          detectiveCase: detectiveCase,
          isReadOnly: false,
        ),
      );

      bloc.resetForLogout();
      await bloc.stream.firstWhere((state) => state is StoryFlowUninitialized);

      expect(bloc.state, isA<StoryFlowUninitialized>());
    });
  });
}
