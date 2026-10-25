import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/category/presentation/bloc/category_puzzles_bloc.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';

import '../../../crossword_fakes.dart';
import '../../../crossword_fixtures.dart';
import '../../../fixtures_entities.dart';

void main() {
  late FakeCrosswordRepository repo;
  late FakeUseCases uc;

  setUp(() {
    repo = FakeCrosswordRepository();
    uc = FakeUseCases(repo);
  });

  CategoryPuzzlesBloc build() => CategoryPuzzlesBloc(
        loadCategory: uc.loadCategory,
        loadPuzzles: uc.loadPuzzles,
        loadMarks: uc.loadMarks,
        countCompleted: uc.countCompleted,
      );

  test('first page with the category from Home, then the next page', () async {
    final puzzle = examplePuzzle();
    repo.completedCount = 3;
    repo.puzzlePages = [
      Paged(items: [puzzle], hasMore: true),
      const Paged(items: [], hasMore: false),
    ];
    final bloc = build()
      ..add(const CategoryPuzzlesOpened('kerala-history',
          category: exampleCategory));
    await settle();
    var state = bloc.state as CategoryPuzzlesLoaded;
    expect(state.category, exampleCategory);
    expect(state.puzzles, [puzzle]);
    expect(state.hasMore, isTrue);
    expect(state.completedCount, 3);
    expect(repo.markRequests, [
      [puzzle.id]
    ]);

    bloc.add(const CategoryPuzzlesMoreRequested());
    await settle();
    state = bloc.state as CategoryPuzzlesLoaded;
    expect(repo.pageRequests, [null, 12]);
    expect(state.hasMore, isFalse);
    bloc.add(const CategoryPuzzlesMoreRequested());
    await settle();
    expect(repo.pageRequests, hasLength(2));
    await bloc.close();
  });

  test('a progress refresh during load-more keeps its marks', () async {
    final puzzle = examplePuzzle();
    repo.puzzlePages = [
      Paged(items: [puzzle], hasMore: true),
      const Paged(items: [], hasMore: false),
    ];
    final bloc = build()
      ..add(const CategoryPuzzlesOpened('kerala-history',
          category: exampleCategory));
    await settle();
    repo.marks = {
      puzzle.id: CrosswordProgressEntity(
          puzzleId: puzzle.id,
          status: CrosswordProgressStatus.completed,
          letters: ''),
    };
    bloc
      ..add(const CategoryPuzzlesMoreRequested())
      ..add(const CategoryPuzzlesProgressRefreshed());
    await settle();
    await settle();
    final state = bloc.state as CategoryPuzzlesLoaded;
    expect(state.progress[puzzle.id]!.isCompleted, isTrue);
    expect(state.hasMore, isFalse);
    await bloc.close();
  });

  test('a deep link loads the category; errors are shown', () async {
    repo.puzzlePages = [const Paged(items: [], hasMore: false)];
    var bloc = build()..add(const CategoryPuzzlesOpened('kerala-history'));
    await settle();
    expect(bloc.state, isA<CategoryPuzzlesFailed>());
    await bloc.close();

    repo.category = exampleCategory;
    repo.puzzlePages = [const Paged(items: [], hasMore: false)];
    bloc = build()..add(const CategoryPuzzlesOpened('kerala-history'));
    await settle();
    expect((bloc.state as CategoryPuzzlesLoaded).category, exampleCategory);
    await bloc.close();
  });
}
