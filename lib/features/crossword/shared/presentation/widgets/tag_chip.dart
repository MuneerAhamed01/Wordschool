import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// Small rounded label, e.g. difficulty.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.background = MyColors.gameSurfaceElevated,
    this.foreground = MyColors.textSecondary,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: foreground, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
