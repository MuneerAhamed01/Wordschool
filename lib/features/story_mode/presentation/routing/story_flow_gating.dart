import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_home_page.dart';

class StoryFlowGating {
  StoryFlowGating._();

  static const int minClueIndex = 0;
  static const int maxClueIndex = 2;

  static bool isValidClueIndex(int? index) {
    if (index == null) {
      return false;
    }
    return index >= minClueIndex && index <= maxClueIndex;
  }

  static bool canAccessClue(StoryFlowState state, int index) {
    if (!isValidClueIndex(index)) {
      return false;
    }

    return state.maybeMap(
      ready: (readyState) {
        if (readyState.isReadOnly) {
          return true;
        }
        return index <= state.firstIncompleteClueIndex;
      },
      orElse: () => false,
    );
  }

  static bool canAccessResolution(StoryFlowState state) {
    return state.maybeMap(
      ready: (readyState) {
        if (readyState.isReadOnly) {
          return true;
        }
        return readyState.allCluesComplete;
      },
      orElse: () => false,
    );
  }

  static String clueHintPath(int index) => '/story/clue/$index/hint';

  static String clueInvestigatePath(int index) => '/story/clue/$index/investigate';

  static String clueWordlePath(int index) => '/story/clue/$index/wordle';

  static String clueReactionPath(int index) => '/story/clue/$index/reaction';

  static const String introPath = '/story/intro';

  static const String resolutionPath = '/story/resolution';

  static String homePath = StoryHomePage.routeName;

  static String beginPath(StoryFlowState state) {
    return state.maybeMap(
      ready: (readyState) {
        final resume = readyState.resumeClueIndex;
        if (resume > minClueIndex && resume <= maxClueIndex) {
          return clueHintPath(resume);
        }
        return introPath;
      },
      orElse: () => introPath,
    );
  }

  static String introContinuePath(StoryFlowState state) {
    return state.maybeMap(
      ready: (readyState) {
        final resume = readyState.resumeClueIndex;
        if (resume <= maxClueIndex) {
          return clueHintPath(resume);
        }
        return resolutionPath;
      },
      orElse: () => clueHintPath(minClueIndex),
    );
  }

  static String investigateContinuePath(StoryFlowState state, int index) {
    return state.maybeMap(
      ready: (readyState) {
        if (readyState.isReadOnly) {
          return clueReactionPath(index);
        }
        return clueWordlePath(index);
      },
      orElse: () => clueWordlePath(index),
    );
  }

  static String nextRouteAfterReaction(int index) {
    if (index >= maxClueIndex) {
      return resolutionPath;
    }
    return clueHintPath(index + 1);
  }

  static bool canAccessReaction(StoryFlowState state, int index) {
    if (!canAccessClue(state, index)) {
      return false;
    }

    return state.maybeMap(
      ready: (readyState) {
        if (readyState.isReadOnly) {
          return true;
        }
        return readyState.completedClues[index];
      },
      orElse: () => false,
    );
  }

  static String redirectForReactionRoute(
    StoryFlowState state,
    int? index,
  ) {
    if (!isValidClueIndex(index)) {
      return homePath;
    }

    if (canAccessReaction(state, index!)) {
      return '';
    }

    if (canAccessClue(state, index) && !state.isReadOnly) {
      return clueWordlePath(index);
    }

    return redirectForClueRoute(state, index);
  }

  static String redirectForClueRoute(
    StoryFlowState state,
    int? index,
  ) {
    if (!isValidClueIndex(index)) {
      return homePath;
    }

    if (!canAccessClue(state, index!)) {
      return clueHintPath(state.firstIncompleteClueIndex.clamp(minClueIndex, maxClueIndex));
    }

    return '';
  }

  static String redirectForResolution(StoryFlowState state) {
    if (!canAccessResolution(state)) {
      final resume = state.firstIncompleteClueIndex.clamp(minClueIndex, maxClueIndex);
      return clueHintPath(resume);
    }
    return '';
  }

  static String redirectForWordle(StoryFlowState state, int? index) {
    final clueRedirect = redirectForClueRoute(state, index);
    if (clueRedirect.isNotEmpty) {
      return clueRedirect;
    }

    return state.maybeMap(
      ready: (readyState) {
        if (readyState.isReadOnly) {
          return clueReactionPath(index!);
        }
        return '';
      },
      orElse: () => homePath,
    );
  }
}
