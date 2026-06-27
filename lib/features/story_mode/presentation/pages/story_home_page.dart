import 'package:flutter/material.dart';
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
import 'package:wordshool/features/story_mode/presentation/widgets/story_banner_ad.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/typewriter_text.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';

class StoryHomePage extends StatelessWidget {
  static const String routeName = '/story';

  const StoryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      appBar: AppBar(
        title: const Text('Detective Case'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: BlocBuilder<StoryCaseBloc, StoryCaseState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) {
              return _buildError(context, message);
            },
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          if (completed) ...[
            const SizedBox(height: 12),
            Text(
              'Case completed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MyColors.streakAccent,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (progress?.outcome != null) ...[
              const SizedBox(height: 8),
              Text(
                caseOutcomeLabel(progress!.outcome!),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (progress != null) ...[
              const SizedBox(height: 8),
              Text(
                '${progress.totalScore} / ${DetectiveScoreCalculator.maxPointsPerDay} points',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
          const SizedBox(height: 24),
          TypewriterText(
            text: introduction,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled) ...[
            const SizedBox(height: 16),
            const StoryBannerAd(),
          ],
          if (canBegin) ...[
            const SizedBox(height: 32),
            AppButton(
              label: _beginLabel(flowState, completed: completed),
              onTap: () {
                context.push(StoryFlowGating.beginPath(flowState));
              },
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
