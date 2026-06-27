import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/story_mode/presentation/analytics/story_analytics.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';

class CaseIntroPage extends StatelessWidget {
  static const String routeName = '/story/intro';

  const CaseIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryFlowBloc, StoryFlowState>(
      builder: (context, flowState) {
        return flowState.maybeWhen(
          ready: (detectiveCase, completedClues, isReadOnly, resumeClueIndex) {
            return StoryNarrativeScaffold(
              title: 'Case Introduction',
              headline: detectiveCase.title,
              body: detectiveCase.introduction,
              continueLabel: 'Continue',
              onContinue: () {
                StoryAnalytics.caseStarted();
                context.push(StoryFlowGating.introContinuePath(flowState));
              },
            );
          },
          orElse: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
