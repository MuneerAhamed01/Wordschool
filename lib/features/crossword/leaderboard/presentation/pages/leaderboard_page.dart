import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/widgets/leaderboard_row.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/widgets/my_rank_bar.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/skeleton_box.dart';
import 'package:wordshool/shared/presentations/widgets/state_message.dart';

/// Ranks tab (CW-051): this week's top 50, own row pinned at the bottom.
/// The [LeaderboardBloc] comes from the router.
class LeaderboardPage extends StatelessWidget {
  static const String routeName = AppRoutes.ranks;
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LeaderboardBloc>();
    return GameScaffold(
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._buildTitle(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  bloc.add(const LeaderboardRequested());
                  await bloc.stream.firstWhere((s) => s is! LeaderboardLoading);
                },
                child: _buildBody(bloc, state),
              ),
            ),
            if (state is LeaderboardLoaded) MyRankBar(board: state.board),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTitle() => const [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
          child: Text(
            'This week',
            style: TextStyle(
                color: MyColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Crossword XP since Monday (IST). Updates every 15 minutes.',
            style: TextStyle(color: MyColors.navInactive, fontSize: 12),
          ),
        ),
      ];

  Widget _buildBody(LeaderboardBloc bloc, LeaderboardState state) {
    return switch (state) {
      LeaderboardLoading() => _buildSkeleton(),
      LeaderboardFailed(:final message) => StateMessage.error(
          message: message,
          onAction: () => bloc.add(const LeaderboardRequested()),
        ),
      LeaderboardLoaded(:final board, :final myUid) =>
        board.top.isEmpty ? _buildEmpty() : _buildList(board, myUid),
    };
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < 8; i++) ...[
          const SkeletonBox(height: 56, radius: 12),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(children: const [
      SizedBox(height: 80),
      StateMessage(
        icon: Icons.emoji_events_outlined,
        title: 'No scores yet this week',
        message: 'Finish a puzzle to get on the board.',
      ),
    ]);
  }

  Widget _buildList(LeaderboardEntity board, String? myUid) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: board.top.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) => LeaderboardRow(
        rank: i + 1,
        entry: board.top[i],
        isMe: board.top[i].uid == myUid,
      ),
    );
  }
}
