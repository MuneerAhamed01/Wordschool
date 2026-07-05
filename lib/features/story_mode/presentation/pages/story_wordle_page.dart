import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/enums/word_tile_type.dart';
import 'package:wordshool/core/utils/game_layout_metrics.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/game/presentation/bloc/word_cubit/word_cubit.dart';
import 'package:wordshool/features/game/presentation/utils/constants.dart';
import 'package:wordshool/features/game/presentation/utils/letter.dart';
import 'package:wordshool/features/game/presentation/utils/word.dart';
import 'package:wordshool/features/game/presentation/widgets/keyboard/keyboard.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_case_bloc/story_case_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_clue_bloc/story_clue_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_navigation.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_audio_manager.dart';
import 'package:wordshool/features/story_mode/presentation/utils/clue_type_labels.dart';
import 'package:wordshool/features/story_mode/presentation/theme/story_theme.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_detective_ui.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';
import 'package:wordshool/shared/presentations/widgets/wordle_tile/tile.dart';

part 'story_wordle_page_helper.dart';

class StoryWordlePage extends StatefulWidget {
  const StoryWordlePage({super.key, required this.clueIndex});

  final int clueIndex;

  @override
  State<StoryWordlePage> createState() => _StoryWordlePageState();
}

class _StoryWordlePageState extends State<StoryWordlePage>
    with StoryWordlePageHelper {
  final Map<int, VoidCallback> _shakeFunctions = {};
  bool _clueInitialized = false;
  bool _guessesRestored = false;
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return StoryFlowGate(
      clueIndex: widget.clueIndex,
      builder: (context, detectiveCase, flowState) {
        _initializeClueIfNeeded(context, detectiveCase, flowState);

        final clue = detectiveCase.clues[widget.clueIndex];

        return MultiBlocListener(
          listeners: [
            BlocListener<StoryClueBloc, StoryClueState>(
              listenWhen: (previous, current) {
                final wasFinished = previous.maybeWhen(
                  ready: (
                    clueIndex,
                    caseId,
                    answer,
                    userId,
                    progress,
                    isCompleted,
                  ) =>
                      isCompleted,
                  orElse: () => false,
                );
                final isFinished = current.maybeWhen(
                  ready: (
                    clueIndex,
                    caseId,
                    answer,
                    userId,
                    progress,
                    isCompleted,
                  ) =>
                      isCompleted,
                  orElse: () => false,
                );
                return !wasFinished && isFinished;
              },
              listener: (context, state) {
                state.maybeWhen(
                  ready: (
                    clueIndex,
                    caseId,
                    answer,
                    userId,
                    progress,
                    isCompleted,
                  ) {
                    if (progress != null) {
                      context.read<StoryCaseBloc>().add(
                            StoryCaseEvent.progressUpdated(progress),
                          );
                    }
                    context.read<StoryFlowBloc>().add(
                          UpdateProgress(progress!),
                        );
                    context.read<StoryFlowBloc>().add(
                          MarkClueResolved(widget.clueIndex),
                        );
                    _navigateToReaction(context);
                  },
                  orElse: () {},
                );
              },
            ),
          ],
          child: DetectiveScaffold(
            appBar: DetectiveAppBar(
              title: clueTypeLabel(clue.type),
              onBack: () => StoryFlowNavigation.handleBack(context),
            ),
            onBack: () => StoryFlowNavigation.handleBack(context),
            showMagnifier: false,
            body: BlocBuilder<StoryClueBloc, StoryClueState>(
              builder: (context, clueState) {
                return clueState.maybeWhen(
                  ready: (
                    clueIndex,
                    caseId,
                    answer,
                    userId,
                    progress,
                    isCompleted,
                  ) {
                    if (isCompleted) {
                      return const Center(child: StoryLoadingPulse());
                    }
                    return _buildContent(context);
                  },
                  error: (message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: GlassEvidencePanel(
                        accentLabel: 'ERROR',
                        child: Text(message, textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  orElse: () => const Center(child: StoryLoadingPulse()),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _initializeClueIfNeeded(
    BuildContext context,
    DetectiveCaseEntity detectiveCase,
    StoryFlowState flowState,
  ) {
    if (_clueInitialized || flowState.isReadOnly) {
      return;
    }

    final userId = getIt<SessionRepository>().getCurrentUser()?.id;
    if (userId == null) {
      return;
    }

    final progress = context.read<StoryCaseBloc>().state.whenOrNull(
          loaded: (_, progress) => progress,
        );

    _clueInitialized = true;
    context.read<StoryClueBloc>().add(
          InitializeClue(
            clueIndex: widget.clueIndex,
            caseId: detectiveCase.id,
            answer: detectiveCase.clues[widget.clueIndex].answer,
            userId: userId,
            progress: progress,
          ),
        );

    final clue = detectiveCase.clues[widget.clueIndex];
    final savedGuesses =
        progress?.clueGuesses.elementAtOrNull(widget.clueIndex) ?? const [];
    unawaited(
      _restoreInitialGuesses(
        caseId: detectiveCase.id,
        answer: clue.answer,
        guesses: savedGuesses,
      ),
    );
  }

  Future<void> _restoreInitialGuesses({
    required String caseId,
    required String answer,
    required List<String> guesses,
  }) async {
    if (_guessesRestored || guesses.isEmpty || !mounted) {
      _guessesRestored = true;
      return;
    }

    _guessesRestored = true;
    await context.read<WordCubit>().restoreGuesses(
          todayWord: answer,
          words: guesses,
        );
  }

  Future<void> _navigateToReaction(BuildContext context) async {
    if (_hasNavigated) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _hasNavigated) {
      return;
    }

    _hasNavigated = true;
    if (context.mounted) {
      context.push(StoryFlowGating.clueReactionPath(widget.clueIndex));
    }
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final flags = const GameLayoutFlags(
          hasBanner: false,
          hasHero: false,
          hasFooter: false,
          hasKeyboard: true,
          hasGuessCounter: true,
          hasEvidencePanel: true,
        );
        final metrics = GameLayoutMetrics.compute(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          flags: flags,
        );

        return GameLayoutScope(
          metrics: metrics,
          child: Column(
            children: [
              SizedBox(height: metrics.isCompact ? 4 : 8),
              Expanded(
                child: Center(
                  child: GlassEvidencePanel(
                    padding: EdgeInsets.all(metrics.isCompact ? 10 : 14),
                    accentLabel: 'CLUE',
                    animate: false,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _buildBoard(metrics),
                    ),
                  ),
                ),
              ),
              _buildGuessCounter(metrics),
              SizedBox(height: metrics.isCompact ? 4 : 8),
              _buildKeyboard(metrics),
              SizedBox(height: metrics.isCompact ? 4 : 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoard(GameLayoutMetrics metrics) {
    return BlocBuilder<WordCubit, List<Word>>(
      builder: (context, words) {
        final boardSide = metrics.boardSide;
        return SizedBox(
          width: boardSide,
          height: boardSide,
          child: GridView.builder(
            itemCount: GameConstants.maxWords * GameConstants.maxLetters,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: GameConstants.maxLetters,
              mainAxisSpacing: metrics.tileSpacing,
              crossAxisSpacing: metrics.tileSpacing,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, index) {
              final wordIndex = index ~/ GameConstants.maxLetters;
              final letterIndex = index % GameConstants.maxLetters;
              final word = words.elementAtOrNull(wordIndex);
              final letter = word?.letters.elementAtOrNull(letterIndex);

              return WordTile(
                tileType: letter?.type ?? WordTileType.none,
                value: letter?.letter ?? '',
                fontSize: metrics.tileFontSize,
                revealDelay: Duration(milliseconds: 100 * letterIndex),
                shakeCallBack: (fn) {
                  _shakeFunctions[index] = fn as VoidCallback;
                },
              );
            },
          ),
        )
            .animate()
            .fadeIn(duration: 350.ms, curve: Curves.easeOut);
      },
    );
  }

  Widget _buildGuessCounter(GameLayoutMetrics metrics) {
    return BlocBuilder<WordCubit, List<Word>>(
      builder: (context, words) {
        final done = words.where((word) => word.isCompleted).length;
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: metrics.isCompact ? 6 : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.manage_search_rounded,
                size: metrics.isCompact ? 16 : 18,
                color: StoryTheme.accent.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                'Deduction ${(done + 1).clamp(1, GameConstants.maxWords)} of ${GameConstants.maxWords}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: StoryTheme.narrativeText.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      fontSize: metrics.isCompact ? 13 : null,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeyboard(GameLayoutMetrics metrics) {
    return BlocBuilder<WordCubit, List<Word>>(
      builder: (context, words) {
        final orange = <String>{};
        final green = <String>{};
        final absent = <String>{};

        for (final word in words) {
          for (final letter in word.letters) {
            final character = letter.letter.toUpperCase();
            if (letter.type == WordTileType.orange) orange.add(character);
            if (letter.type == WordTileType.green) green.add(character);
            if (letter.type == WordTileType.none) absent.add(character);
          }
        }

        return CustomKeyboard(
          keyHeight: metrics.keyHeight,
          keyFontSize: metrics.keyFontSize,
          onKeyPressed: (value) {
            if (getIt.isRegistered<StoryAudioManager>()) {
              getIt<StoryAudioManager>().playKeyClick();
            }
            context.read<WordCubit>().addLetter(Letter(letter: value));
          },
          onEnterPressed: () => onSubmitWord(context),
          onBackspacePressed: () =>
              context.read<WordCubit>().removeLastLetter(),
          orangedList: orange.toList(),
          greenedList: green.toList(),
          disabledList: absent.toList(),
        );
      },
    );
  }
}
