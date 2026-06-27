import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/utils/detective_score_calculator.dart';
import 'package:wordshool/features/story_mode/presentation/utils/case_outcome_labels.dart';
import 'package:wordshool/features/story_mode/presentation/utils/clue_type_labels.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (progress.outcome != null) ...[
          Text(
            caseOutcomeLabel(progress.outcome!),
            style: theme.textTheme.titleLarge?.copyWith(
              color: MyColors.streakAccent,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          '${progress.totalScore} / ${DetectiveScoreCalculator.maxPointsPerDay} detective points',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Clue breakdown',
          style: theme.textTheme.titleMedium,
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
  });

  final String label;
  final bool solved;
  final int attempts;
  final int points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = solved
        ? '$attempts ${attempts == 1 ? 'attempt' : 'attempts'}'
        : 'Failed';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '$points pts',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
