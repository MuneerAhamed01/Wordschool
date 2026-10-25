import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

const _icons = <String, IconData>{
  'history_edu': Icons.history_edu,
  'account_balance': Icons.account_balance,
  'public': Icons.public,
  'map': Icons.map_outlined,
  'science': Icons.science_outlined,
  'menu_book': Icons.menu_book,
  'gavel': Icons.gavel,
  'eco': Icons.eco_outlined,
  'sports_cricket': Icons.sports_cricket,
  'palette': Icons.palette_outlined,
  'calculate': Icons.calculate_outlined,
  'translate': Icons.translate,
};

IconData categoryIcon(String name) => _icons[name] ?? Icons.folder_outlined;

/// Parses a stored `#RRGGBB` category colour.
Color categoryColor(String hex) {
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null ? MyColors.tileCorrect : Color(0xFF000000 | value);
}

/// Rounded coloured square with the category icon.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  final String icon;
  final String color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = categoryColor(color);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: tint.withValues(alpha: 0.6)),
      ),
      child: Icon(categoryIcon(icon), color: tint, size: size * 0.5),
    );
  }
}
