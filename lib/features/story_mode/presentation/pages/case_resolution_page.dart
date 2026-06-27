import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_home_page.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';

class CaseResolutionPage extends StatelessWidget {
  static const String routeName = '/story/resolution';

  const CaseResolutionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryFlowBloc, StoryFlowState>(
      builder: (context, flowState) {
        return flowState.maybeWhen(
          ready: (detectiveCase, completedClues, isReadOnly, resumeClueIndex) {
            return StoryNarrativeScaffold(
              title: 'Case Resolution',
              headline: detectiveCase.title,
              body: '${detectiveCase.resolution}\n\n'
                  'Score and outcome — Phase 5',
              continueLabel: 'Return to case file',
              onContinue: () => context.go(StoryHomePage.routeName),
            );
          },
          orElse: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class CaseResolutionGate extends StatelessWidget {
  const CaseResolutionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryFlowBloc, StoryFlowState>(
      builder: (context, flowState) {
        if (!StoryFlowGating.canAccessResolution(flowState)) {
          return const Center(child: CircularProgressIndicator());
        }
        return const CaseResolutionPage();
      },
    );
  }
}
