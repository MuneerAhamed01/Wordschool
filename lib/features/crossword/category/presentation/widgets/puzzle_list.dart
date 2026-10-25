import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/features/crossword/category/presentation/bloc/category_puzzles_bloc.dart';
import 'package:wordshool/features/crossword/category/presentation/widgets/puzzle_row.dart';
import 'package:wordshool/shared/presentations/widgets/state_message.dart';

/// The paged puzzle list; asks for the next page near the end.
class PuzzleList extends StatelessWidget {
  const PuzzleList({super.key, required this.state});

  final CategoryPuzzlesLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.puzzles.isEmpty) {
      return const StateMessage(
        icon: Icons.grid_off_rounded,
        title: 'No puzzles yet',
        message: 'New puzzles in this category are on their way.',
      );
    }
    final bloc = context.read<CategoryPuzzlesBloc>();
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 300) {
          bloc.add(const CategoryPuzzlesMoreRequested());
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: state.puzzles.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i == state.puzzles.length) {
            return state.moreError != null
                ? TextButton(
                    onPressed: () =>
                        bloc.add(const CategoryPuzzlesMoreRequested()),
                    child: const Text('Couldn\'t load more · Try again'),
                  )
                : const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
          }
          final puzzle = state.puzzles[i];
          return PuzzleRow(
            puzzle: puzzle,
            progress: state.progress[puzzle.id],
            onTap: () async {
              await context.push(AppRoutes.puzzleOf(puzzle.id));
              bloc.add(const CategoryPuzzlesProgressRefreshed());
            },
          );
        },
      ),
    );
  }
}
