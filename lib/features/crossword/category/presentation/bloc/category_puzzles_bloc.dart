import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/count_completed.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/load_category.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/load_category_puzzles.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/load_puzzle_marks.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/utils/load_category_puzzles_param.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';

sealed class CategoryPuzzlesEvent {
  const CategoryPuzzlesEvent();
}

final class CategoryPuzzlesOpened extends CategoryPuzzlesEvent {
  const CategoryPuzzlesOpened(this.categoryId, {this.category});

  final String categoryId;

  /// Passed from Home to skip a read; loaded when null (deep link).
  final CrosswordCategoryEntity? category;
}

final class CategoryPuzzlesMoreRequested extends CategoryPuzzlesEvent {
  const CategoryPuzzlesMoreRequested();
}

/// Back from a puzzle: refresh solved/in-progress marks (cached, no read).
final class CategoryPuzzlesProgressRefreshed extends CategoryPuzzlesEvent {
  const CategoryPuzzlesProgressRefreshed();
}

sealed class CategoryPuzzlesState extends Equatable {
  const CategoryPuzzlesState();

  @override
  List<Object?> get props => [];
}

final class CategoryPuzzlesLoading extends CategoryPuzzlesState {
  const CategoryPuzzlesLoading();
}

final class CategoryPuzzlesFailed extends CategoryPuzzlesState {
  const CategoryPuzzlesFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CategoryPuzzlesLoaded extends CategoryPuzzlesState {
  const CategoryPuzzlesLoaded({
    required this.category,
    required this.puzzles,
    required this.progress,
    required this.hasMore,
    this.completedCount = 0,
    this.loadingMore = false,
    this.moreError,
  });

  final CrosswordCategoryEntity category;
  final List<CrosswordPuzzleEntity> puzzles;

  /// Marks for the puzzles shown, by puzzle id.
  final Map<String, CrosswordProgressEntity> progress;
  final bool hasMore;

  /// Completed puzzles in the whole category (header).
  final int completedCount;
  final bool loadingMore;
  final String? moreError;

  List<String> get puzzleIds => [for (final p in puzzles) p.id];

  CategoryPuzzlesLoaded copyWith({
    List<CrosswordPuzzleEntity>? puzzles,
    Map<String, CrosswordProgressEntity>? progress,
    bool? hasMore,
    int? completedCount,
    bool? loadingMore,
    String? moreError,
  }) =>
      CategoryPuzzlesLoaded(
        category: category,
        puzzles: puzzles ?? this.puzzles,
        progress: progress ?? this.progress,
        hasMore: hasMore ?? this.hasMore,
        completedCount: completedCount ?? this.completedCount,
        loadingMore: loadingMore ?? this.loadingMore,
        moreError: moreError,
      );

  @override
  List<Object?> get props => [
        category,
        puzzles,
        progress,
        hasMore,
        completedCount,
        loadingMore,
        moreError
      ];
}

/// Category list (CW-045): published puzzles 20 per page, with marks.
class CategoryPuzzlesBloc
    extends Bloc<CategoryPuzzlesEvent, CategoryPuzzlesState> {
  CategoryPuzzlesBloc({
    required LoadCrosswordCategoryUseCase loadCategory,
    required LoadCategoryPuzzlesUseCase loadPuzzles,
    required LoadPuzzleMarksUseCase loadMarks,
    required CountCompletedUseCase countCompleted,
  })  : _loadCategory = loadCategory,
        _loadPuzzles = loadPuzzles,
        _loadMarks = loadMarks,
        _countCompleted = countCompleted,
        super(const CategoryPuzzlesLoading()) {
    on<CategoryPuzzlesOpened>(_onOpened);
    on<CategoryPuzzlesMoreRequested>(_onMore);
    on<CategoryPuzzlesProgressRefreshed>(_onProgress);
  }

  final LoadCrosswordCategoryUseCase _loadCategory;
  final LoadCategoryPuzzlesUseCase _loadPuzzles;
  final LoadPuzzleMarksUseCase _loadMarks;
  final CountCompletedUseCase _countCompleted;

  CategoryPuzzlesLoaded? get _loaded =>
      state is CategoryPuzzlesLoaded ? state as CategoryPuzzlesLoaded : null;

  Future<void> _onOpened(
    CategoryPuzzlesOpened event,
    Emitter<CategoryPuzzlesState> emit,
  ) async {
    emit(const CategoryPuzzlesLoading());
    final categoryFuture = event.category != null
        ? Future.value(DataSuccess(data: event.category))
        : _loadCategory(param: event.categoryId);
    final pageFuture = _loadPuzzles(
        param: LoadCategoryPuzzlesParam(categoryId: event.categoryId));
    final countFuture = _countCompleted(param: event.categoryId);

    final category = await categoryFuture;
    final page = await pageFuture;
    if (category is DataError || category.data == null) {
      emit(CategoryPuzzlesFailed(
          category.error?.message ?? "Couldn't load this category."));
      return;
    }
    if (page is DataError || page.data == null) {
      emit(CategoryPuzzlesFailed(
          page.error?.message ?? "Couldn't load the puzzles."));
      return;
    }
    final puzzles = page.data!.items;
    final marks = await _loadMarks(param: [for (final p in puzzles) p.id]);
    emit(CategoryPuzzlesLoaded(
      category: category.data!,
      puzzles: puzzles,
      progress: marks.data ?? const {},
      hasMore: page.data!.hasMore,
      completedCount: (await countFuture).data ?? 0,
    ));
  }

  Future<void> _onMore(
    CategoryPuzzlesMoreRequested event,
    Emitter<CategoryPuzzlesState> emit,
  ) async {
    final current = _loaded;
    if (current == null || !current.hasMore || current.loadingMore) return;
    emit(current.copyWith(loadingMore: true));
    final page = await _loadPuzzles(
      param: LoadCategoryPuzzlesParam(
        categoryId: current.category.id,
        afterNumber:
            current.puzzles.isEmpty ? null : current.puzzles.last.number,
      ),
    );
    final items = page.data?.items ?? const <CrosswordPuzzleEntity>[];
    final marks = await _loadMarks(param: [for (final p in items) p.id]);
    // Build on the latest state: a progress refresh may have landed meanwhile.
    final latest = _loaded ?? current;
    if (page is DataError || page.data == null) {
      emit(latest.copyWith(
          loadingMore: false,
          moreError: page.error?.message ?? "Couldn't load more."));
      return;
    }
    emit(latest.copyWith(
      puzzles: [...latest.puzzles, ...items],
      progress: {...latest.progress, ...?marks.data},
      hasMore: page.data!.hasMore,
      loadingMore: false,
    ));
  }

  Future<void> _onProgress(
    CategoryPuzzlesProgressRefreshed event,
    Emitter<CategoryPuzzlesState> emit,
  ) async {
    final current = _loaded;
    if (current == null) return;
    final marks = await _loadMarks(param: current.puzzleIds);
    final count = await _countCompleted(param: current.category.id);
    final latest = _loaded;
    if (latest == null) return;
    emit(latest.copyWith(
      progress:
          marks.data == null ? null : {...latest.progress, ...marks.data!},
      completedCount: count.data,
    ));
  }
}
