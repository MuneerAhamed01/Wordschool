import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';
import 'package:wordshool/features/crossword/shared/presentation/utils/format.dart';

/// Rank, avatar, name and XP.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.entry,
    this.isMe = false,
  });

  final int? rank;
  final LeaderboardEntryEntity entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) {
      1 => MyColors.yellow1,
      2 => MyColors.gray1,
      3 => MyColors.orange3,
      _ => null,
    };
    return Semantics(
      label:
          'Rank ${rank ?? '—'}, ${entry.displayName}${isMe ? ' (you)' : ''}, '
          '${entry.points} XP, ${entry.puzzlesSolved} puzzles',
      excludeSemantics: true,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isMe ? MyColors.successBg : MyColors.gameSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                rank == null ? '—' : '$rank',
                style: TextStyle(
                  color: medal ?? MyColors.navInactive,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: MyColors.gameSurfaceElevated,
              foregroundImage:
                  entry.photoUrl == null ? null : NetworkImage(entry.photoUrl!),
              child: Text(
                entry.displayName.isEmpty
                    ? '?'
                    : entry.displayName[0].toUpperCase(),
                style: const TextStyle(color: MyColors.white, fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isMe ? '${entry.displayName} (you)' : entry.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: MyColors.white, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${formatCount(entry.points)} XP',
              style: const TextStyle(
                color: MyColors.hint,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
