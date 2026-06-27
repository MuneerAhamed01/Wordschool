import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/utils/clue_type_labels.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';

class StoryHintPage extends StatelessWidget {
  const StoryHintPage({super.key, required this.clueIndex});

  final int clueIndex;

  @override
  Widget build(BuildContext context) {
    return StoryFlowGate(
      clueIndex: clueIndex,
      builder: (context, detectiveCase, flowState) {
        final clue = detectiveCase.clues[clueIndex];

        return StoryNarrativeScaffold(
          title: clueTypeLabel(clue.type),
          body: clue.hint,
          continueLabel: 'Continue',
          onContinue: () {
            context.push(StoryFlowGating.clueInvestigatePath(clueIndex));
          },
        );
      },
    );
  }
}
