import 'package:go_router/go_router.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';

int? parseStoryClueIndex(GoRouterState state) {
  return int.tryParse(state.pathParameters['index'] ?? '');
}

String? redirectStoryReactionRoute(
  StoryFlowBloc flowBloc,
  GoRouterState state,
) {
  final redirect = StoryFlowGating.redirectForReactionRoute(
    flowBloc.state,
    parseStoryClueIndex(state),
  );
  return redirect.isEmpty ? null : redirect;
}

String? redirectStoryClueRoute(
  StoryFlowBloc flowBloc,
  GoRouterState state,
) {
  final redirect = StoryFlowGating.redirectForClueRoute(
    flowBloc.state,
    parseStoryClueIndex(state),
  );
  return redirect.isEmpty ? null : redirect;
}

String? redirectStoryWordleRoute(
  StoryFlowBloc flowBloc,
  GoRouterState state,
) {
  final index = parseStoryClueIndex(state);
  final clueRedirect = StoryFlowGating.redirectForClueRoute(
    flowBloc.state,
    index,
  );
  if (clueRedirect.isNotEmpty) {
    return clueRedirect;
  }

  final wordleRedirect = StoryFlowGating.redirectForWordle(flowBloc.state, index);
  return wordleRedirect.isEmpty ? null : wordleRedirect;
}

String? redirectStoryResolution(StoryFlowBloc flowBloc) {
  final redirect = StoryFlowGating.redirectForResolution(flowBloc.state);
  return redirect.isEmpty ? null : redirect;
}
