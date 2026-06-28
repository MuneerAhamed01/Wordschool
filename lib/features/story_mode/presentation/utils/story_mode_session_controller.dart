import 'package:wordshool/core/monetization/story_entitlements.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_case_bloc/story_case_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_audio_manager.dart';

/// Bridges router-scoped story blocs with app-wide logout so a new sign-in
/// always loads that user's progress instead of the previous session.
class StoryModeSessionController {
  StoryCaseBloc? _caseBloc;
  StoryFlowBloc? _flowBloc;

  void bind({
    required StoryCaseBloc caseBloc,
    required StoryFlowBloc flowBloc,
  }) {
    _caseBloc = caseBloc;
    _flowBloc = flowBloc;
  }

  Future<void> resetOnLogout() async {
    _flowBloc?.resetForLogout();
    _caseBloc?.resetForLogout();

    if (getIt.isRegistered<StoryAudioManager>()) {
      await getIt<StoryAudioManager>().stopAll();
    }

    if (getIt.isRegistered<StoryEntitlementsService>()) {
      await getIt<StoryEntitlementsService>().refresh();
    }
  }
}
