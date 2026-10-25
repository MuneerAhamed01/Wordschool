import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/category/presentation/bloc/category_puzzles_bloc.dart';
import 'package:wordshool/shared/presentations/widgets/category_visuals.dart';

/// Back button, category icon and name, "3 / 12 played".
class CategoryHeader extends StatelessWidget {
  const CategoryHeader({super.key, required this.state});

  final CategoryPuzzlesState state;

  @override
  Widget build(BuildContext context) {
    final loaded =
        state is CategoryPuzzlesLoaded ? state as CategoryPuzzlesLoaded : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.arrow_back_rounded, color: MyColors.white),
            onPressed: () => context.pop(),
          ),
          if (loaded != null) ...[
            Icon(categoryIcon(loaded.category.icon),
                color: categoryColor(loaded.category.color)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loaded.category.name.en,
                    style: const TextStyle(
                        color: MyColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  ),
                  Text(
                    '${loaded.completedCount} / '
                    '${loaded.category.publishedPuzzleCount} played',
                    style: const TextStyle(
                        color: MyColors.navInactive, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
