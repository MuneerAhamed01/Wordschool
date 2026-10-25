import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/widgets/leaderboard_row.dart';

/// The player's own row, pinned under the list.
class MyRankBar extends StatelessWidget {
  const MyRankBar({super.key, required this.board});

  final LeaderboardEntity board;

  @override
  Widget build(BuildContext context) {
    final me = board.me;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: MyColors.navBarBackground,
        border: Border(top: BorderSide(color: MyColors.gameBorderSubtle)),
      ),
      child: me == null
          ? const Text(
              'Finish a puzzle this week to get a rank.',
              key: ValueKey('my-rank-empty'),
              style: TextStyle(color: MyColors.navInactive),
            )
          : LeaderboardRow(
              key: const ValueKey('my-rank'),
              rank: board.myRank,
              entry: me,
              isMe: true,
            ),
    );
  }
}
