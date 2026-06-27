import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_case_bloc/story_case_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';

class StoryNarrativeScaffold extends StatelessWidget {
  const StoryNarrativeScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.continueLabel,
    required this.onContinue,
    this.headline,
  });

  final String title;
  final String? headline;
  final String body;
  final String continueLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (headline != null) ...[
                    Text(
                      headline!,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: AppButton(
              label: continueLabel,
              onTap: onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

class StoryModeShell extends StatefulWidget {
  const StoryModeShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<StoryModeShell> createState() => _StoryModeShellState();
}

class _StoryModeShellState extends State<StoryModeShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncFlowBloc(context.read<StoryCaseBloc>().state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoryCaseBloc, StoryCaseState>(
      listener: (context, state) => _syncFlowBloc(state),
      child: widget.child,
    );
  }

  void _syncFlowBloc(StoryCaseState state) {
    state.whenOrNull(
      loaded: (detectiveCase, progress) {
        context.read<StoryFlowBloc>().add(
              Initialize(
                detectiveCase: detectiveCase,
                progress: progress,
                isReadOnly: false,
              ),
            );
      },
      alreadyCompleted: (detectiveCase, progress) {
        context.read<StoryFlowBloc>().add(
              Initialize(
                detectiveCase: detectiveCase,
                progress: progress,
                isReadOnly: true,
              ),
            );
      },
    );
  }
}

class StoryFlowGate extends StatelessWidget {
  const StoryFlowGate({
    super.key,
    required this.clueIndex,
    required this.builder,
  });

  final int clueIndex;
  final Widget Function(
    BuildContext context,
    DetectiveCaseEntity detectiveCase,
    StoryFlowState flowState,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryFlowBloc, StoryFlowState>(
      builder: (context, flowState) {
        return flowState.maybeWhen(
          ready: (detectiveCase, completedClues, isReadOnly, resumeClueIndex) {
            return builder(context, detectiveCase, flowState);
          },
          orElse: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
