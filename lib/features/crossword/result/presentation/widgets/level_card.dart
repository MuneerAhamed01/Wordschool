import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/result/domain/utils/xp_level.dart';
import 'package:wordshool/features/crossword/shared/presentation/utils/format.dart';
import 'package:wordshool/shared/presentations/widgets/app_progress_bar.dart';

/// "Level 4 · 285 / 400 XP" with a progress bar.
class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.level});

  final LevelProgress level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MyColors.gameSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Level ${level.level}',
                  style: const TextStyle(
                      color: MyColors.white, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '${formatCount(level.xpIntoLevel)} / '
                '${formatCount(level.xpForLevel)} XP',
                style: const TextStyle(
                    color: MyColors.navInactive,
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppProgressBar(
              value: level.fraction, color: MyColors.hint, height: 6),
        ],
      ),
    );
  }
}
