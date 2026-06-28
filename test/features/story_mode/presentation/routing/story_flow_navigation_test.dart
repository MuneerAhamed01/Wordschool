import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_navigation.dart';

import 'story_flow_gating_test.dart';

void main() {
  group('StoryFlowNavigation', () {
    test('back from intro goes to story home', () {
      final state = readyState();

      expect(
        StoryFlowNavigation.backPathForLocation(
          StoryFlowGating.introPath,
          state,
        ),
        StoryFlowGating.homePath,
      );
    });

    test('back from clue 0 hint goes to intro', () {
      final state = readyState();

      expect(
        StoryFlowNavigation.backPathForLocation(
          StoryFlowGating.clueHintPath(0),
          state,
        ),
        StoryFlowGating.introPath,
      );
    });

    test('back from clue 1 hint goes to previous reaction', () {
      final state = readyState(completedClues: [true, false, false]);

      expect(
        StoryFlowNavigation.backPathForLocation(
          StoryFlowGating.clueHintPath(1),
          state,
        ),
        StoryFlowGating.clueReactionPath(0),
      );
    });

    test('back from investigate goes to hint for same clue', () {
      final state = readyState();

      expect(
        StoryFlowNavigation.backPathForLocation(
          StoryFlowGating.clueInvestigatePath(1),
          state,
        ),
        StoryFlowGating.clueHintPath(1),
      );
    });

    test('back from wordle goes to investigate when playing', () {
      final state = readyState();

      expect(
        StoryFlowNavigation.backPathForLocation(
          StoryFlowGating.clueWordlePath(0),
          state,
        ),
        StoryFlowGating.clueInvestigatePath(0),
      );
    });

    test('back from wordle goes to reaction in read-only mode', () {
      final state = readyState(isReadOnly: true);

      expect(
        StoryFlowNavigation.backPathForLocation(
          StoryFlowGating.clueWordlePath(1),
          state,
        ),
        StoryFlowGating.clueReactionPath(1),
      );
    });

    test('back from reaction goes to wordle', () {
      final state = readyState(completedClues: [true, false, false]);

      expect(
        StoryFlowNavigation.backPathForLocation(
          StoryFlowGating.clueReactionPath(0),
          state,
        ),
        StoryFlowGating.clueWordlePath(0),
      );
    });

    test('back from resolution goes to story home', () {
      final state = readyState(completedClues: [true, true, true]);

      expect(
        StoryFlowNavigation.backPathForLocation(
          StoryFlowGating.resolutionPath,
          state,
        ),
        StoryFlowGating.homePath,
      );
    });

    test('isStoryLocation matches story routes only', () {
      expect(StoryFlowNavigation.isStoryLocation('/story'), isTrue);
      expect(
        StoryFlowNavigation.isStoryLocation('/story/clue/0/wordle'),
        isTrue,
      );
      expect(StoryFlowNavigation.isStoryLocation('/home'), isFalse);
    });
  });
}
