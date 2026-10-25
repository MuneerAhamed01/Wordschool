import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// Thin rounded progress bar: 4 px (category tiles) or 6 px (level bar).
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color = MyColors.accentGlow,
    this.height = 4,
  });

  /// 0–1 (clamped).
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: MyColors.gameBorderSubtle),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.isNaN ? 0 : value.clamp(0, 1),
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
