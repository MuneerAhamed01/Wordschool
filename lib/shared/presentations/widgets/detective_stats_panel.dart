import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/remote_config/story_mode_config.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/iso_week_id.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/leaderboard/domain/entities/detective_leaderboard_entry.dart';
import 'package:wordshool/features/leaderboard/domain/repositories/detective_leaderboard_repository.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';
import 'package:wordshool/shared/presentations/widgets/glass_card.dart';

class DetectiveStatsPanel extends StatefulWidget {
  const DetectiveStatsPanel({super.key, required this.userGameState});

  final UserGameStateEntity userGameState;

  @override
  State<DetectiveStatsPanel> createState() => _DetectiveStatsPanelState();
}

class _DetectiveStatsPanelState extends State<DetectiveStatsPanel> {
  DetectiveLeaderboardEntry? _weeklyEntry;
  int? _weeklyRank;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadWeeklyStats();
  }

  Future<void> _loadWeeklyStats() async {
    if (!getIt<StoryModeConfig>().isEnabledForUser(widget.userGameState.id)) {
      setState(() => _loaded = true);
      return;
    }

    final user = await getIt<GetCurrentUserUseCase>()();
    final result = await getIt<DetectiveLeaderboardRepository>()
        .loadWeeklyLeaderboard(currentUserId: user?.id);

    if (!mounted) return;

    if (result is DataSuccess) {
      setState(() {
        _weeklyEntry = result.data!.currentUserEntry;
        _weeklyRank = result.data!.currentUserRank;
        _loaded = true;
      });
    } else {
      setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!getIt<StoryModeConfig>().isEnabledForUser(widget.userGameState.id)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final weeklyPoints = _weeklyEntry?.totalPoints ?? 0;
    final rankLabel =
        _weeklyRank != null ? '#$_weeklyRank this week' : 'Unranked this week';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Detective progress',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetectiveStatItem(
                  label: 'Story streak',
                  value: '${widget.userGameState.storyModeStreak}',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
              Container(width: 1, height: 48, color: MyColors.gameBorder),
              Expanded(
                child: _DetectiveStatItem(
                  label: 'Weekly pts',
                  value: _loaded ? '$weeklyPoints' : '—',
                  icon: Icons.star_rounded,
                ),
              ),
              Container(width: 1, height: 48, color: MyColors.gameBorder),
              Expanded(
                child: _DetectiveStatItem(
                  label: 'Total pts',
                  value: '${widget.userGameState.detectivePoints}',
                  icon: Icons.emoji_events_outlined,
                ),
              ),
            ],
          ),
          if (_loaded) ...[
            const SizedBox(height: 12),
            Text(
              rankLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MyColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Week ${IsoWeekId.current()} (UTC)',
              style: theme.textTheme.labelLarge?.copyWith(
                color: MyColors.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetectiveStatItem extends StatelessWidget {
  const _DetectiveStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: MyColors.streakAccent, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: MyColors.accentGlow,
              ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}