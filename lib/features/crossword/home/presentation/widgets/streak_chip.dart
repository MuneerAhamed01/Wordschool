import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// Flame + day count (`accent.streak` on `accent.streakBg`).
class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final active = days > 0;
    return Semantics(
      label: '$days day streak',
      excludeSemantics: true,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? MyColors.streakBg : MyColors.gameSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded,
                size: 18,
                color: active ? MyColors.streakAccent : MyColors.navInactive),
            const SizedBox(width: 4),
            Text(
              '$days',
              style: TextStyle(
                color: active ? MyColors.streakAccent : MyColors.navInactive,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
