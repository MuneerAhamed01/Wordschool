import 'package:flutter/material.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';
import 'package:wordshool/shared/presentations/widgets/app_progress_bar.dart';
import 'package:wordshool/shared/presentations/widgets/category_visuals.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/home_tile.dart';

/// Home grid card: icon well, "18 / 42", name, progress bar.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.completed,
    required this.onTap,
  });

  final CrosswordCategoryEntity category;
  final int completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category.color);
    final total = category.publishedPuzzleCount;
    return HomeTile(
      semanticsLabel:
          '${category.name.en}, $completed of $total puzzles played',
      onTap: onTap,
      icon: categoryIcon(category.icon),
      iconColor: color,
      corner: '$completed / $total',
      title: category.name.en,
      footer: AppProgressBar(
        value: total == 0 ? 0 : completed / total,
        color: color,
      ),
    );
  }
}
