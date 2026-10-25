import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/category/data/data_source/category_service.dart';
import 'package:wordshool/features/crossword/category/domain/repositories/category_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/progress_repository.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required CategoryDataSource source,
    required CrosswordProgressRepository progress,
  })  : _source = source,
        _progress = progress;

  final CategoryDataSource _source;
  final CrosswordProgressRepository _progress;

  @override
  Future<DataState<CrosswordCategoryEntity>> getCategory(String categoryId) =>
      _source.getCategory(categoryId);

  @override
  Future<DataState<Paged<CrosswordPuzzleEntity>>> getCategoryPuzzles({
    required String categoryId,
    int? afterNumber,
  }) async {
    final result = await _source.getPuzzles(
      categoryId: categoryId,
      afterNumber: afterNumber,
      limit: Paged.pageSize,
    );
    if (result is DataError) return DataError(error: result.error);
    final items = result.data ?? const [];
    return DataSuccess(
      data: Paged(items: items, hasMore: items.length == Paged.pageSize),
    );
  }

  @override
  Future<DataState<Map<String, CrosswordProgressEntity>>> getPuzzleMarks(
          List<String> puzzleIds) =>
      _progress.getProgressFor(puzzleIds);

  @override
  Future<DataState<int>> countCompleted(String categoryId) =>
      _progress.countCompleted(categoryId);
}
