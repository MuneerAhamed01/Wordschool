import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/utils/ist_date.dart';
import 'package:wordshool/features/crossword/home/domain/entities/daily.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';

/// Home's daily card: new · in progress · solved · unavailable.
class DailyPuzzleCard extends StatelessWidget {
  const DailyPuzzleCard({
    super.key,
    required this.daily,
    required this.progress,
    required this.onOpen,
    required this.onPlayCategory,
  });

  /// Null = no puzzle today.
  final CrosswordDailyEntity? daily;
  final CrosswordProgressEntity? progress;

  final VoidCallback onOpen;
  final VoidCallback onPlayCategory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final d = daily;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MyColors.gameSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MyColors.gameBorderSubtle),
      ),
      child: d == null
          ? _buildUnavailable(textTheme)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '●  DAILY · ${shortDateLabel(d.dateId)}',
                            style: textTheme.labelSmall?.copyWith(
                              color: MyColors.accentGlow,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            d.title.en,
                            style: textTheme.titleLarge?.copyWith(
                              color: MyColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${d.wordCount} clues · ${d.difficulty.label} · '
                            'about ${d.estimatedMinutes} min',
                            style: textTheme.bodySmall
                                ?.copyWith(color: MyColors.navInactive),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const _MiniGrid(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAction(d),
              ],
            ),
    );
  }

  Widget _buildAction(CrosswordDailyEntity d) {
    final p = progress;
    if (p != null && p.isCompleted) {
      final score = p.result?.score;
      return AppButton(
        key: const ValueKey('daily-action'),
        label: score == null ? 'View result' : 'View result · $score%',
        height: 48,
        variant: ButtonVariant.secondary,
        onTap: onOpen,
      );
    }
    final started = p != null && p.filledCount > 0;
    return Row(
      children: [
        Expanded(
          child: AppButton(
            key: const ValueKey('daily-action'),
            label: started
                ? 'Continue · ${p.filledCount} / ${_letterSquares(p.letters)}'
                : 'Start puzzle',
            height: 48,
            onTap: onOpen,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '+${d.xpReward} XP\non solve',
          textAlign: TextAlign.right,
          style: const TextStyle(
              color: MyColors.hint, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  /// Progress letters mark blocks with `#`; everything else is a square.
  static int _letterSquares(String letters) =>
      letters.length - '#'.allMatches(letters).length;

  Widget _buildUnavailable(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's puzzle is on its way",
          style: textTheme.titleMedium
              ?.copyWith(color: MyColors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Meanwhile, pick a category below.',
          style: textTheme.bodySmall?.copyWith(color: MyColors.navInactive),
        ),
        const SizedBox(height: 14),
        AppButton(
          label: 'Play a category',
          height: 48,
          variant: ButtonVariant.secondary,
          onTap: onPlayCategory,
        ),
      ],
    );
  }
}

/// Decorative 4×4 tile preview (64 px).
class _MiniGrid extends StatelessWidget {
  const _MiniGrid();

  static const _pattern = '..#.' '....' '.#..' '...#';

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 64,
        height: 64,
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < 16; i++)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _pattern[i] == '#'
                      ? MyColors.gridBlock
                      : (i == 5 ? MyColors.hint : MyColors.tileCorrect),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
