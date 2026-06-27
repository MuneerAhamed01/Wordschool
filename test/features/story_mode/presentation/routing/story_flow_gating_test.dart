import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/story_mode/data/models/detective_case.dart';
import 'package:wordshool/features/story_mode/data/models/detective_clue.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/entities/clue_type.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';

StoryFlowReady readyState({
  List<bool> completedClues = const [false, false, false],
  bool isReadOnly = false,
  StoryModeProgressModel? progress,
}) {
  final resumeIndex = completedClues.indexWhere((resolved) => !resolved);
  return StoryFlowReady(
    detectiveCase: DetectiveCaseModel(
      id: '2026-06-18',
      title: 'The Midnight Ledger',
      introduction: 'Intro',
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
      resolution: 'Resolution',
      createdAt: DateTime.utc(2026, 6, 18),
    ),
    completedClues: completedClues,
    isReadOnly: isReadOnly,
    resumeClueIndex: resumeIndex == -1 ? completedClues.length : resumeIndex,
    progress: progress,
  );
}

void main() {
  group('StoryFlowGating', () {
    test('blocks clue 2 before clue 0 is resolved', () {
      final state = readyState();

      expect(StoryFlowGating.canAccessClue(state, 0), isTrue);
      expect(StoryFlowGating.canAccessClue(state, 1), isFalse);
      expect(StoryFlowGating.canAccessClue(state, 2), isFalse);
    });

    test('allows next clue after previous clue resolves', () {
      final state = readyState(completedClues: [true, false, false]);

      expect(StoryFlowGating.canAccessClue(state, 1), isTrue);
      expect(StoryFlowGating.canAccessClue(state, 2), isFalse);
    });

    test('redirects blocked clue routes to resume hint', () {
      final state = readyState();

      expect(
        StoryFlowGating.redirectForClueRoute(state, 2),
        StoryFlowGating.clueHintPath(0),
      );
    });

    test('blocks reaction until clue is resolved', () {
      final state = readyState();

      expect(StoryFlowGating.canAccessReaction(state, 0), isFalse);
      expect(
        StoryFlowGating.redirectForReactionRoute(state, 0),
        StoryFlowGating.clueWordlePath(0),
      );
    });

    test('allows read-only replay of all clues', () {
      final state = readyState(isReadOnly: true);

      expect(StoryFlowGating.canAccessClue(state, 2), isTrue);
      expect(StoryFlowGating.canAccessReaction(state, 2), isTrue);
      expect(StoryFlowGating.canAccessResolution(state), isTrue);
    });

    test('nextRouteAfterReaction advances clues then resolution', () {
      expect(
        StoryFlowGating.nextRouteAfterReaction(0),
        StoryFlowGating.clueHintPath(1),
      );
      expect(
        StoryFlowGating.nextRouteAfterReaction(2),
        StoryFlowGating.resolutionPath,
      );
    });

    test('beginPath resumes mid-clue at wordle', () {
      final progress = StoryModeProgressModel(
        userId: 'user-1',
        caseId: '2026-06-18',
        currentClueIndex: 0,
        clueAttempts: const [2, 0, 0],
        clueGuesses: const [
          ['WRONG', 'STARE'],
          [],
          [],
        ],
        clueSolved: const [false, false, false],
        totalScore: 0,
      );
      final state = readyState(progress: progress);

      expect(
        StoryFlowGating.beginPath(state),
        StoryFlowGating.clueWordlePath(0),
      );
    });

    test('beginPath resumes next clue at hint when previous finished', () {
      final progress = StoryModeProgressModel(
        userId: 'user-1',
        caseId: '2026-06-18',
        currentClueIndex: 1,
        clueAttempts: const [2, 0, 0],
        clueGuesses: const [[], [], []],
        clueSolved: const [true, false, false],
        totalScore: 80,
      );
      final state = readyState(
        completedClues: const [true, false, false],
        progress: progress,
      );

      expect(
        StoryFlowGating.beginPath(state),
        StoryFlowGating.clueHintPath(1),
      );
    });
  });
}
