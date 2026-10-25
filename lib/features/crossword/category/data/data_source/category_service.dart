import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/shared/data/models/category.dart';
import 'package:wordshool/features/crossword/shared/data/models/puzzle.dart';

/// One category and its published puzzles (rules require the filters).
abstract class CategoryDataSource {
  Future<DataState<CrosswordCategoryModel>> getCategory(String categoryId);

  /// `status == published`, `number` desc.
  Future<DataState<List<CrosswordPuzzleModel>>> getPuzzles({
    required String categoryId,
    int? afterNumber,
    required int limit,
  });
}
