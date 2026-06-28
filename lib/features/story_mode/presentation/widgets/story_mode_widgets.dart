import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_navigation.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_case_bloc/story_case_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/theme/story_theme.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_audio_manager.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_detective_ui.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/typewriter_text.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';

class StoryNarrativeScaffold extends StatelessWidget {
  const StoryNarrativeScaffold({
    super.key,
    required this.title,
    required this.continueLabel,
    required this.onContinue,
    this.headline,
    this.body,
    this.bodyWidget,
    this.useTypewriter = true,
    this.panelLabel,
  }) : assert(body != null || bodyWidget != null);

  final String title;
  final String? headline;
  final String? body;
  final Widget? bodyWidget;
  final bool useTypewriter;
  final String continueLabel;
  final VoidCallback onContinue;
  final String? panelLabel;

  @override
  Widget build(BuildContext context) {
    return DetectiveScaffold(
      appBar: DetectiveAppBar(
        title: title,
        onBack: () => StoryFlowNavigation.handleBack(context),
      ),
      onBack: () => StoryFlowNavigation.handleBack(context),
      showMagnifier: false,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (headline != null) ...[
                    DetectiveCaseHeader(title: headline!),
                    const SizedBox(height: 20),
                    const CrimeSceneTape(label: 'CASE FILE'),
                    const SizedBox(height: 20),
                  ],
                  GlassEvidencePanel(
                    accentLabel: panelLabel ?? 'EVIDENCE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (body != null && body!.isNotEmpty)
                          useTypewriter
                              ? TypewriterText(
                                  text: body!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                )
                              : Text(
                                  body!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                        if (bodyWidget != null) bodyWidget!,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: DetectiveActionButton(
              child: AppButton(
                label: continueLabel,
                onTap: onContinue,
              ),
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
  StoryAudioManager? _audioManager;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _initAudio();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final caseBloc = context.read<StoryCaseBloc>();
      caseBloc.state.whenOrNull(
        initial: () => caseBloc.add(const StoryCaseEvent.loadTodayCase()),
      );
      _syncFlowBloc(caseBloc.state);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (!identical(_router, router)) {
      _router?.routerDelegate.removeListener(_onRouteChanged);
      _router = router;
      _router!.routerDelegate.addListener(_onRouteChanged);
    }
  }

  void _onRouteChanged() {
    if (!mounted || _audioManager == null) return;

    final location =
        _router!.routerDelegate.currentConfiguration.uri.path;
    if (StoryFlowNavigation.isStoryLocation(location)) {
      _audioManager!.startStoryAmbience();
    } else {
      _audioManager!.stopAll();
    }
  }

  Future<void> _initAudio() async {
    if (!getIt.isRegistered<StoryAudioManager>()) {
      return;
    }
    _audioManager = getIt<StoryAudioManager>();
    await _audioManager!.initialize();
    if (!mounted) return;

    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    if (StoryFlowNavigation.isStoryLocation(location)) {
      await _audioManager!.startStoryAmbience();
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouteChanged);
    _audioManager?.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StoryTheme.dark(),
      child: BlocListener<StoryCaseBloc, StoryCaseState>(
        listener: (context, state) => _syncFlowBloc(state),
        child: StoryCaseProgressListener(child: widget.child),
      ),
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

class StoryCaseProgressListener extends StatelessWidget {
  const StoryCaseProgressListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoryCaseBloc, StoryCaseState>(
      listenWhen: (previous, current) {
        final previousProgress = previous.whenOrNull(
          loaded: (_, progress) => progress,
          alreadyCompleted: (_, progress) => progress,
        );
        final currentProgress = current.whenOrNull(
          loaded: (_, progress) => progress,
          alreadyCompleted: (_, progress) => progress,
        );
        return previousProgress != currentProgress && currentProgress != null;
      },
      listener: (context, state) {
        state.whenOrNull(
          loaded: (_, progress) {
            if (progress != null) {
              context.read<StoryFlowBloc>().add(UpdateProgress(progress));
            }
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
      },
      child: child,
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
          orElse: () => DetectiveScaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: StoryTheme.accent.withValues(alpha: 0.85),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StoryLoadingPulse extends StatelessWidget {
  const StoryLoadingPulse({super.key});

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: 36,
      height: 36,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: StoryTheme.accent.withValues(alpha: 0.9),
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) {
      return indicator;
    }

    return indicator
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.05, 1.05),
          duration: 900.ms,
        );
  }
}
