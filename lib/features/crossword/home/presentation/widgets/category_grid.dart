import 'package:flutter/material.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/category_tile.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/mistakes_tile.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';

/// Two-column grid of categories with "My mistakes" last.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.home,
    required this.onCategory,
    required this.onMistakes,
  });

  final CrosswordHomeEntity home;
  final ValueChanged<CrosswordCategoryEntity> onCategory;
  final VoidCallback onMistakes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 10) / 2;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in home.categories)
            SizedBox(
              width: width,
              child: CategoryTile(
                key: ValueKey('category-${c.id}'),
                category: c,
                completed: home.completedIn(c.id),
                onTap: () => onCategory(c),
              ),
            ),
          SizedBox(
            width: width,
            child: MistakesTile(count: home.revisionCount, onTap: onMistakes),
          ),
        ],
      );
    });
  }
}
