import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// One colour swatch with its meaning.
class GridLegend extends StatelessWidget {
  const GridLegend({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: MyColors.gameBorder),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style:
                const TextStyle(color: MyColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
