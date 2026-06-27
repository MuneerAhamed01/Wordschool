import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/utils/clue_type_labels.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';

class StoryWordleStubPage extends StatelessWidget {
  const StoryWordleStubPage({super.key, required this.clueIndex});

  final int clueIndex;

  @override
  Widget build(BuildContext context) {
    return StoryFlowGate(
      clueIndex: clueIndex,
      builder: (context, detectiveCase, flowState) {
        final clue = detectiveCase.clues[clueIndex];

        return GameScaffold(
          appBar: AppBar(
            title: Text(clueTypeLabel(clue.type)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Investigation puzzle',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: AppButton(
                  label: 'Solve clue',
                  onTap: () {
                    context.read<StoryFlowBloc>().add(
                          MarkClueResolved(clueIndex),
                        );
                    context.push(StoryFlowGating.clueReactionPath(clueIndex));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
