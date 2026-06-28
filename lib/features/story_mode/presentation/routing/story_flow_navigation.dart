import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_home_page.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_audio_manager.dart';

/// Logical back navigation for story mode routes (go_router + nested pushes).
class StoryFlowNavigation {
  StoryFlowNavigation._();

  static bool isStoryLocation(String location) {
    return location == StoryHomePage.routeName ||
        location.startsWith('${StoryHomePage.routeName}/');
  }

  static String backPathForLocation(
    String location,
    StoryFlowState flowState,
  ) {
    if (location == StoryFlowGating.introPath) {
      return StoryFlowGating.homePath;
    }

    if (location == StoryFlowGating.resolutionPath) {
      return StoryFlowGating.homePath;
    }

    final hintMatch = RegExp(r'^/story/clue/(\d+)/hint$').firstMatch(location);
    if (hintMatch != null) {
      final index = int.parse(hintMatch.group(1)!);
      if (index <= StoryFlowGating.minClueIndex) {
        return StoryFlowGating.introPath;
      }
      return StoryFlowGating.clueReactionPath(index - 1);
    }

    final investigateMatch =
        RegExp(r'^/story/clue/(\d+)/investigate$').firstMatch(location);
    if (investigateMatch != null) {
      final index = int.parse(investigateMatch.group(1)!);
      return StoryFlowGating.clueHintPath(index);
    }

    final wordleMatch =
        RegExp(r'^/story/clue/(\d+)/wordle$').firstMatch(location);
    if (wordleMatch != null) {
      final index = int.parse(wordleMatch.group(1)!);
      if (flowState.isReadOnly) {
        return StoryFlowGating.clueReactionPath(index);
      }
      return StoryFlowGating.clueInvestigatePath(index);
    }

    final reactionMatch =
        RegExp(r'^/story/clue/(\d+)/reaction$').firstMatch(location);
    if (reactionMatch != null) {
      final index = int.parse(reactionMatch.group(1)!);
      return StoryFlowGating.clueWordlePath(index);
    }

    return StoryFlowGating.homePath;
  }

  static void handleBack(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location == StoryHomePage.routeName) {
      _exitStoryMode(context);
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    final flowState = context.read<StoryFlowBloc>().state;
    context.go(backPathForLocation(location, flowState));
  }

  static void _exitStoryMode(BuildContext context) {
    if (getIt.isRegistered<StoryAudioManager>()) {
      getIt<StoryAudioManager>().stopAll();
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(DashboardPage.routeName);
  }
}
