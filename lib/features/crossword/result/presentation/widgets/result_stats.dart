import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/result/presentation/widgets/stat_tile.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';
import 'package:wordshool/features/crossword/shared/presentation/utils/format.dart';

/// Time · Correct · XP · Day streak.
class ResultStats extends StatelessWidget {
  const ResultStats({super.key, required this.outcome});

  final CrosswordSubmitOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final result = outcome.result;
    return Row(
      children: [
        Expanded(
            child: StatTile(label: 'Time', value: formatClock(result.timeSec))),
        const SizedBox(width: 8),
        Expanded(
            child: StatTile(
                label: 'Correct',
                value: '${result.correctWords}/${result.totalWords}')),
        const SizedBox(width: 8),
        Expanded(
            child: StatTile(
                label: 'XP',
                value: '+${result.xpEarned}',
                color: MyColors.hint)),
        const SizedBox(width: 8),
        Expanded(
            child: StatTile(
                label: 'Day streak',
                value: '${outcome.currentStreak}',
                color: MyColors.streakAccent)),
      ],
    );
  }
}
