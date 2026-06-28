import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/presentations/widgets/pressable_scale.dart';

class DailyPuzzleHero extends StatelessWidget {
  const DailyPuzzleHero({
    super.key,
    required this.userGameState,
    required this.todayGameData,
    required this.onPlay,
    this.expanded = false,
  });

  final UserGameStateEntity userGameState;
  final UserGameDataEntity? todayGameData;
  final VoidCallback onPlay;
  final bool expanded;

  bool get _isCompleted => todayGameData?.isCompleted == true;
  bool get _isWin => todayGameData?.isCorrect == true;

  double get _winRate {
    if (userGameState.totalGames == 0) return 0;
    return userGameState.completedGames / userGameState.totalGames;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = _buildContent(theme);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MyColors.accentGlow.withValues(alpha: 0.35),
            MyColors.tileCorrect.withValues(alpha: 0.12),
            MyColors.gameBorder.withValues(alpha: 0.2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: MyColors.accentGlow.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
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
          padding: EdgeInsets.all(expanded ? 18 : 14),
          child: expanded ? SizedBox.expand(child: content) : content,
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _DailyBadge(isCompleted: _isCompleted, isWin: _isWin),
            const Spacer(),
            _MiniTilePreview(isCompleted: _isCompleted, isWin: _isWin),
          ],
        ),
        SizedBox(height: expanded ? 16 : 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _StreakRing(
              streak: userGameState.streak,
              winRate: _winRate,
              isCompletedToday: _isCompleted,
              isWinToday: _isWin,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isCompleted
                        ? (_isWin ? 'Case closed!' : 'Puzzle played')
                        : 'Today\'s puzzle',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusSubtitle(),
                    maxLines: expanded ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: MyColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (expanded) const Spacer(),
        if (!expanded) const SizedBox(height: 12),
        _MiniStatsRow(userGameState: userGameState),
        if (expanded) const Spacer(),
        if (!expanded) const SizedBox(height: 12),
        _PlayButton(
          label: _playLabel(),
          icon: _playIcon(),
          onTap: onPlay,
          height: expanded ? 52 : 44,
        ),
      ],
    );
  }

  String _statusSubtitle() {
    if (!_isCompleted) {
      return 'One word. Six guesses. Can you crack it?';
    }
    if (_isWin) {
      final guesses = todayGameData!.guessedWords.length;
      return 'Solved in $guesses ${guesses == 1 ? 'guess' : 'guesses'}. Nice work!';
    }
    return 'Come back tomorrow — or review your grid now.';
  }

  String _playLabel() {
    if (!_isCompleted) return 'Play Today\'s Puzzle';
    return _isWin ? 'Review Win' : 'Review Result';
  }

  IconData _playIcon() {
    if (_isCompleted && _isWin) return Icons.emoji_events_rounded;
    if (_isCompleted) return Icons.grid_on_rounded;
    return Icons.play_arrow_rounded;
  }
}

class _DailyBadge extends StatelessWidget {
  const _DailyBadge({required this.isCompleted, required this.isWin});

  final bool isCompleted;
  final bool isWin;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? (isWin ? MyColors.tileCorrect : MyColors.streakAccent)
        : MyColors.accentGlow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted
                ? (isWin ? Icons.check_rounded : Icons.schedule_rounded)
                : Icons.bolt_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted ? (isWin ? 'SOLVED' : 'PLAYED') : 'DAILY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.1,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniTilePreview extends StatelessWidget {
  const _MiniTilePreview({required this.isCompleted, required this.isWin});

  final bool isCompleted;
  final bool isWin;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        Color fill = MyColors.gameBorder.withValues(alpha: 0.5);
        if (isCompleted && isWin) {
          fill = MyColors.tileCorrect.withValues(alpha: 0.85);
        } else if (isCompleted) {
          fill = index < 3
              ? MyColors.tilePresent.withValues(alpha: 0.7)
              : MyColors.tileAbsent.withValues(alpha: 0.7);
        }

        return Container(
          width: 22,
          height: 22,
          margin: EdgeInsets.only(left: index == 0 ? 0 : 4),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: MyColors.gameBorder.withValues(alpha: 0.8),
            ),
          ),
        );
      }),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.height,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [MyColors.accentGlow, MyColors.tileCorrect],
          ),
          boxShadow: [
            BoxShadow(
              color: MyColors.accentGlow.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: MyColors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: MyColors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakRing extends StatelessWidget {
  const _StreakRing({
    required this.streak,
    required this.winRate,
    required this.isCompletedToday,
    required this.isWinToday,
  });

  final int streak;
  final double winRate;
  final bool isCompletedToday;
  final bool isWinToday;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final ringColor = isCompletedToday
        ? (isWinToday ? MyColors.tileCorrect : MyColors.streakAccent)
        : MyColors.accentGlow;

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(_size, _size),
            painter: _RingPainter(
              progress: winRate.clamp(0.0, 1.0),
              accent: ringColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompletedToday
                    ? (isWinToday
                        ? Icons.check_circle_rounded
                        : Icons.nightlight_round)
                    : Icons.local_fire_department_rounded,
                color: ringColor,
                size: 14,
              ),
              Text(
                '$streak',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ringColor,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      fontSize: 16,
                    ),
              ),
              Text(
                'streak',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MyColors.textMuted,
                      fontSize: 9,
                      letterSpacing: 0.2,
                      height: 1,
                    ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const stroke = 4.0;

    final track = Paint()
      ..color = MyColors.gameBorder.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..shader = SweepGradient(
        colors: [
          accent.withValues(alpha: 0.35),
          accent,
          accent.withValues(alpha: 0.85),
        ],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}

class _MiniStatsRow extends StatelessWidget {
  const _MiniStatsRow({required this.userGameState});

  final UserGameStateEntity userGameState;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _Chip(label: 'Played', value: '${userGameState.totalGames}'),
        _Chip(label: 'Won', value: '${userGameState.completedGames}'),
        if (userGameState.longestStreak > 0)
          _Chip(label: 'Best', value: '${userGameState.longestStreak}'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MyColors.gameBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.gameBorder.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: MyColors.accentGlow,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: 3),
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
  }
}
