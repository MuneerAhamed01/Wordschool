import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/features/crossword/category/presentation/bloc/category_puzzles_bloc.dart';
import 'package:wordshool/features/crossword/category/presentation/widgets/category_header.dart';
import 'package:wordshool/features/crossword/category/presentation/widgets/puzzle_list.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/skeleton_box.dart';
import 'package:wordshool/shared/presentations/widgets/state_message.dart';

/// Category list (`design/screens/psc-crossword.md#1b`, CW-045).
class CategoryPuzzlesPage extends StatelessWidget {
  const CategoryPuzzlesPage({super.key, required this.categoryId});

  static const routeName = AppRoutes.category;

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      body: BlocBuilder<CategoryPuzzlesBloc, CategoryPuzzlesState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CategoryHeader(state: state),
              Expanded(
                child: switch (state) {
                  CategoryPuzzlesLoading() => ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (var i = 0; i < 6; i++) ...[
                          const SkeletonBox(height: 72),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  CategoryPuzzlesFailed(:final message) => StateMessage.error(
                      message: message,
                      onAction: () => context
                          .read<CategoryPuzzlesBloc>()
                          .add(CategoryPuzzlesOpened(categoryId)),
                    ),
                  CategoryPuzzlesLoaded() => PuzzleList(state: state),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
