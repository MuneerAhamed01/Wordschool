import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/auto_puzzle.dart';

/// Above the grid after "Auto-create puzzle": what was built and how to try
/// again, or why nothing could be built.
class AutoPuzzleCard extends StatelessWidget {
  const AutoPuzzleCard({
    super.key,
    required this.result,
    required this.categoryName,
    required this.checkedCount,
    required this.fitCount,
    required this.size,
    required this.onTryAnother,
    required this.onOptions,
    required this.onOpenQuestions,
  });

  /// Null when no grid could be built.
  final AutoPuzzleResult? result;
  final String categoryName;

  /// Checked questions in the category.
  final int checkedCount;

  /// Of those, how many can go on a [size] × [size] grid.
  final int fitCount;
  final int size;
  final VoidCallback onTryAnother;
  final VoidCallback onOptions;
  final VoidCallback onOpenQuestions;

  @override
  Widget build(BuildContext context) {
    final failed = result == null;
    return Card(
      color: failed ? MyColors.warnBg : MyColors.infoBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMessage(context, failed),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: failed
                  ? [
                      FilledButton.icon(
                        onPressed: onOpenQuestions,
                        icon: const Icon(Icons.quiz_outlined, size: 18),
                        label: const Text('Go to Questions'),
                      ),
                      _buildOptionsButton(),
                    ]
                  : [
                      FilledButton.icon(
                        onPressed: onTryAnother,
                        icon: const Icon(Icons.casino_outlined, size: 18),
                        label: const Text('Try another'),
                      ),
                      _buildOptionsButton(),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, bool failed) {
    final color = failed ? MyColors.warnText : MyColors.infoText;
    final textTheme = Theme.of(context).textTheme;
    final r = result;
    final title = r == null
        ? 'Not enough checked questions in $categoryName to build a grid'
        : 'Auto-created: ${r.used.length} words, ${r.crossings} crossings '
            'from $checkedCount checked question${checkedCount == 1 ? '' : 's'}.';
    final body = r == null
        ? 'Have $fitCount that fit a $size×$size grid — need at least 2 that '
            'cross. Add or check questions first.'
        : 'Check every clue and fact, then save. Nothing is saved until you do.';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(failed ? Icons.info_outline : Icons.auto_awesome, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: textTheme.titleSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(body, style: textTheme.bodyMedium?.copyWith(color: color)),
              if (r != null)
                for (final note in r.notes)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• $note',
                        style: textTheme.bodySmall?.copyWith(color: color)),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsButton() => OutlinedButton.icon(
        onPressed: onOptions,
        icon: const Icon(Icons.tune, size: 18),
        label: const Text('Options'),
      );
}
