import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: MyColors.streakAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MyColors.streakAccent.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded,
              size: 16, color: MyColors.streakAccent),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: MyColors.streakAccent,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}
