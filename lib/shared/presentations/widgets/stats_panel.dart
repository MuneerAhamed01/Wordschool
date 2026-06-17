import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/presentations/widgets/glass_card.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key, required this.userGameState});

  final UserGameStateEntity userGameState;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          _StreakRow(streak: userGameState.streak),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Played',
                  value: '${userGameState.totalGames}',
                ),
              ),
              Container(width: 1, height: 36, color: MyColors.gameBorder),
              Expanded(
                child: _StatItem(
                  label: 'Won',
                  value: '${userGameState.completedGames}',
                ),
              ),
              if (userGameState.longestStreak > 0) ...[
                Container(width: 1, height: 36, color: MyColors.gameBorder),
                Expanded(
                  child: _StatItem(
                    label: 'Best',
                    value: '${userGameState.longestStreak}',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.local_fire_department_rounded,
            color: MyColors.streakAccent, size: 28),
        const SizedBox(width: 8),
        Text(
          '$streak',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: MyColors.streakAccent,
                fontSize: 36,
              ),
        ),
        const SizedBox(width: 6),
        Text(
          streak == 1 ? 'day streak' : 'day streak',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: MyColors.accentGlow,
              ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
