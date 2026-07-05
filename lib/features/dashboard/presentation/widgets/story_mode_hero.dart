import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/remote_config/story_mode_config.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/iso_week_id.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/leaderboard/domain/entities/detective_leaderboard_entry.dart';
import 'package:wordshool/features/leaderboard/domain/repositories/detective_leaderboard_repository.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/utils/detective_score_calculator.dart';
import 'package:wordshool/features/story_mode/presentation/theme/story_theme.dart';
import 'package:wordshool/features/story_mode/presentation/utils/case_outcome_labels.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';
import 'package:wordshool/shared/presentations/widgets/pressable_scale.dart';

class StoryModeHero extends StatefulWidget {
  const StoryModeHero({
    super.key,
    required this.userGameState,
    required this.onOpen,
    this.todayStoryProgress,
    this.expanded = false,
  });

  final UserGameStateEntity userGameState;
  final StoryModeProgressEntity? todayStoryProgress;
  final VoidCallback onOpen;
  final bool expanded;

  @override
  State<StoryModeHero> createState() => _StoryModeHeroState();
}

class _StoryModeHeroState extends State<StoryModeHero> {
  DetectiveLeaderboardEntry? _weeklyEntry;
  int? _weeklyRank;
  bool _loaded = false;

  bool get _isCompleted => widget.todayStoryProgress?.completedAt != null;

  @override
  void initState() {
    super.initState();
    _loadWeeklyStats();
  }

  @override
  void didUpdateWidget(covariant StoryModeHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userGameState != widget.userGameState) {
      _loadWeeklyStats();
    }
  }

  Future<void> _loadWeeklyStats() async {
    if (!getIt<StoryModeConfig>().isEnabledForUser(widget.userGameState.id)) {
      if (mounted) setState(() => _loaded = true);
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
    final theme = Theme.of(context);
    final weeklyPoints = _weeklyEntry?.totalPoints ?? 0;
    final rankLabel =
        _weeklyRank != null ? '#$_weeklyRank this week' : 'Unranked';

    return Container(
      width: double.infinity,
      height: widget.expanded ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StoryTheme.accent.withValues(alpha: 0.4),
            StoryTheme.accent.withValues(alpha: 0.08),
            MyColors.gameBorder.withValues(alpha: 0.15),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: StoryTheme.accent.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.5),
          color: MyColors.gameSurface.withValues(alpha: 0.96),
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.expanded ? 18 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: StoryTheme.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: StoryTheme.accent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: StoryTheme.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCompleted ? 'Case closed!' : 'Detective Case',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _statusSubtitle(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: MyColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: StoryTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: StoryTheme.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'STORY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: StoryTheme.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.expanded ? 14 : 12),
              if (widget.expanded)
                Expanded(child: _statsPanel(weeklyPoints))
              else
                _statsPanel(weeklyPoints),
              if (_loaded) ...[
                SizedBox(height: widget.expanded ? 8 : 6),
                Text(
                  '$rankLabel · Week ${IsoWeekId.current()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MyColors.textMuted,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: widget.expanded ? 12 : 10),
              _DetectivePlayButton(
                height: widget.expanded ? 52 : 44,
                label: _playLabel(),
                icon: _playIcon(),
                onTap: widget.onOpen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsPanel(int weeklyPoints) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: widget.expanded ? 16 : 10,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: MyColors.gameBackground.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: StoryTheme.accent.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: _ProgressStat(
                icon: Icons.local_fire_department_rounded,
                value: '${widget.userGameState.storyModeStreak}',
                label: 'Streak',
                expanded: widget.expanded,
              ),
            ),
          ),
          _divider,
          Expanded(
            child: Center(
              child: _ProgressStat(
                icon: Icons.star_rounded,
                value: _loaded ? '$weeklyPoints' : '—',
                label: 'Weekly',
                expanded: widget.expanded,
              ),
            ),
          ),
          _divider,
          Expanded(
            child: Center(
              child: _ProgressStat(
                icon: Icons.emoji_events_outlined,
                value: '${widget.userGameState.detectivePoints}',
                label: 'Total',
                expanded: widget.expanded,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _divider => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: MyColors.gameBorder.withValues(alpha: 0.6),
      );

  String _statusSubtitle() {
    if (!_isCompleted) {
      return 'A new mystery drops every day';
    }

    final progress = widget.todayStoryProgress!;
    final outcome = progress.outcome;
    if (outcome != null) {
      return '${caseOutcomeLabel(outcome)} · ${progress.totalScore}/${DetectiveScoreCalculator.maxPointsPerDay} pts';
    }
    return '${progress.totalScore}/${DetectiveScoreCalculator.maxPointsPerDay} pts scored today';
  }

  String _playLabel() {
    if (!_isCompleted) return 'Play Today\'s Case';
    return 'Review Today\'s Case';
  }

  IconData _playIcon() {
    if (_isCompleted) return Icons.folder_open_rounded;
    return Icons.play_arrow_rounded;
  }
}

class _DetectivePlayButton extends StatelessWidget {
  const _DetectivePlayButton({
    required this.onTap,
    required this.height,
    required this.label,
    required this.icon,
  });

  final VoidCallback onTap;
  final double height;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              StoryTheme.accent,
              StoryTheme.accent.withValues(alpha: 0.82),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: StoryTheme.accent.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: StoryTheme.background,
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: StoryTheme.background,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.icon,
    required this.value,
    required this.label,
    this.expanded = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final roomy = expanded && constraints.maxHeight > 56;
        final iconSize = roomy ? 20.0 : 16.0;
        final valueSize = roomy ? 18.0 : 14.0;

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: StoryTheme.accent, size: iconSize),
              SizedBox(height: roomy ? 6 : 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: StoryTheme.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: valueSize,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MyColors.textMuted,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
