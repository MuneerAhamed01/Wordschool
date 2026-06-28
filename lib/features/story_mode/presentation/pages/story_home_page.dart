import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/utils/detective_score_calculator.dart';
import 'package:wordshool/features/story_mode/presentation/utils/case_outcome_labels.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_case_bloc/story_case_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_navigation.dart';
import 'package:wordshool/features/story_mode/presentation/theme/story_theme.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_banner_ad.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_detective_ui.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/typewriter_text.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';

class StoryHomePage extends StatelessWidget {
  static const String routeName = '/story';

  const StoryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetectiveScaffold(
      appBar: DetectiveAppBar(
        title: 'Detective Bureau',
        onBack: () => StoryFlowNavigation.handleBack(context),
      ),
      onBack: () => StoryFlowNavigation.handleBack(context),
      body: BlocBuilder<StoryCaseBloc, StoryCaseState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: StoryLoadingPulse()),
            loading: () => const Center(child: StoryLoadingPulse()),
            error: (message) => _buildError(context, message),
            loaded: (detectiveCase, progress) => _buildCasePreview(
              context,
              detectiveCase.title,
              detectiveCase.introduction,
            ),
            alreadyCompleted: (detectiveCase, progress) => _buildCasePreview(
              context,
              detectiveCase.title,
              detectiveCase.introduction,
              completed: true,
              progress: progress,
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassEvidencePanel(
          accentLabel: 'ALERT',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: StoryTheme.crimeRed.withValues(alpha: 0.9),
                size: 36,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Retry',
                variant: ButtonVariant.secondary,
                expand: false,
                onTap: () {
                  context.read<StoryCaseBloc>().add(const StoryCaseEvent.retry());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCasePreview(
    BuildContext context,
    String title,
    String introduction, {
    bool completed = false,
    StoryModeProgressEntity? progress,
  }) {
    final flowState = context.watch<StoryFlowBloc>().state;
    final canBegin = flowState.maybeMap(
      ready: (_) => true,
      orElse: () => false,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: MagnifyingGlassDecoration(size: 88, opacity: 0.7)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
          const SizedBox(height: 8),
          DetectiveCaseHeader(
            title: title,
            subtitle: completed ? 'Today\'s case — archived' : 'Today\'s case — active',
            stamp: completed
                ? DetectiveCaseStamp(
                    label: progress?.outcome != null
                        ? caseOutcomeLabel(progress!.outcome!)
                        : 'SOLVED',
                  )
                : null,
          ),
          if (completed && progress != null) ...[
            const SizedBox(height: 16),
            GlassEvidencePanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: StoryTheme.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${progress.totalScore} / ${DetectiveScoreCalculator.maxPointsPerDay} pts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: MyColors.streakAccent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const CrimeSceneTape(label: 'CLASSIFIED'),
          const SizedBox(height: 20),
          GlassEvidencePanel(
            accentLabel: 'BRIEFING',
            child: TypewriterText(
              text: introduction,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                  ),
            ),
          ),
          if (getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled) ...[
            const SizedBox(height: 16),
            const StoryBannerAd(),
          ],
          if (canBegin) ...[
            const SizedBox(height: 28),
            DetectiveActionButton(
              child: AppButton(
                label: _beginLabel(flowState, completed: completed),
                icon: completed
                    ? Icons.folder_open_rounded
                    : Icons.search_rounded,
                onTap: () {
                  context.push(StoryFlowGating.beginPath(flowState));
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _beginLabel(StoryFlowState flowState, {required bool completed}) {
    if (completed) {
      return 'Review case';
    }

    return flowState.maybeMap(
      ready: (state) {
        if (state.resumeClueIndex > StoryFlowGating.minClueIndex &&
            state.resumeClueIndex <= StoryFlowGating.maxClueIndex) {
          return 'Continue investigation';
        }
        return 'Begin investigation';
      },
      orElse: () => 'Begin investigation',
    );
  }
}
