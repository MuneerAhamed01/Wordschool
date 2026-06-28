import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/utils/detective_score_calculator.dart';
import 'package:wordshool/features/story_mode/presentation/theme/story_theme.dart';
import 'package:wordshool/features/story_mode/presentation/utils/case_outcome_labels.dart';
import 'package:wordshool/features/story_mode/presentation/utils/clue_type_labels.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_detective_ui.dart';

class CaseScoreBreakdown extends StatelessWidget {
  const CaseScoreBreakdown({
    super.key,
    required this.detectiveCase,
    required this.progress,
  });

  final DetectiveCaseEntity detectiveCase;
  final StoryModeProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (progress.outcome != null) ...[
          Center(
            child: DetectiveCaseStamp(
              label: caseOutcomeLabel(progress.outcome!),
              color: MyColors.streakAccent,
            ),
          ),
          const SizedBox(height: 16),
        ],
        GlassEvidencePanel(
          accentLabel: 'SCORE',
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          animate: false,
          child: Column(
            children: [
              Text(
                '${progress.totalScore}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: StoryTheme.accent,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: StoryTheme.accent.withValues(alpha: 0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
              Text(
                'of ${DetectiveScoreCalculator.maxPointsPerDay} detective points',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: StoryTheme.narrativeText.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Clue breakdown',
          style: theme.textTheme.titleMedium?.copyWith(
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < detectiveCase.clues.length; index++)
          _ClueScoreRow(
            label: clueTypeLabel(detectiveCase.clues[index].type),
            solved: progress.clueSolved[index],
            attempts: progress.clueAttempts[index],
            points: DetectiveScoreCalculator.pointsForClue(
              solved: progress.clueSolved[index],
              attempts: progress.clueAttempts[index],
            ),
            index: index,
            animate: !disableAnimations,
          ),
      ],
    );
  }
}

class _ClueScoreRow extends StatelessWidget {
  const _ClueScoreRow({
    required this.label,
    required this.solved,
    required this.attempts,
    required this.points,
    required this.index,
    required this.animate,
  });

  final String label;
  final bool solved;
  final int attempts;
  final int points;
  final int index;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = solved
        ? '$attempts ${attempts == 1 ? 'attempt' : 'attempts'}'
        : 'Failed';

    Widget row = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassEvidencePanel(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        animate: false,
        child: Row(
          children: [
            Icon(
              solved ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: solved
                  ? StoryTheme.accent.withValues(alpha: 0.9)
                  : StoryTheme.crimeRed.withValues(alpha: 0.8),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodyLarge),
                  Text(
                    detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: StoryTheme.narrativeText.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$points pts',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: solved ? StoryTheme.accent : StoryTheme.crimeRed,
              ),
            ),
          ],
        ),
      ),
    );

    if (!animate) {
      return row;
    }

    return row
        .animate(delay: (80 * index).ms)
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.08, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
