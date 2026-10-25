import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';

/// The category list screen.
abstract class CategoryRepository {
  Future<DataState<CrosswordCategoryEntity>> getCategory(String categoryId);

  /// Published puzzles, `number` desc, 20 per page; pass the last number
  /// seen to get the next page.
  Future<DataState<Paged<CrosswordPuzzleEntity>>> getCategoryPuzzles({
    required String categoryId,
    int? afterNumber,
  });

  /// The player's progress for the puzzles shown, by puzzle id.
  Future<DataState<Map<String, CrosswordProgressEntity>>> getPuzzleMarks(
      List<String> puzzleIds);

  Future<DataState<int>> countCompleted(String categoryId);
}
