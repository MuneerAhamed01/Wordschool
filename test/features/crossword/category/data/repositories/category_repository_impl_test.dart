import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/category/data/data_source/category_service.dart';
import 'package:wordshool/features/crossword/category/data/repositories/category_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/data/data_source/progress_service.dart';
import 'package:wordshool/features/crossword/shared/data/models/category.dart';
import 'package:wordshool/features/crossword/shared/data/models/progress.dart';
import 'package:wordshool/features/crossword/shared/data/models/puzzle.dart';
import 'package:wordshool/features/crossword/shared/data/repositories/progress_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

import '../../../crossword_fakes.dart';
import '../../../crossword_fixtures.dart';

class _Source implements CategoryDataSource {
  @override
  Future<DataState<CrosswordCategoryModel>> getCategory(String id) async =>
      dataError();

  @override
  Future<DataState<List<CrosswordPuzzleModel>>> getPuzzles({
    required String categoryId,
    int? afterNumber,
    required int limit,
  }) async =>
      DataSuccess(data: List.filled(limit, examplePuzzle()));
}

class _NoProgress implements ProgressDataSource {
  @override
  Future<DataState<int>> countCompleted(String categoryId) async =>
      DataSuccess(data: 0);

  @override
  Future<DataState<CrosswordProgressModel?>> getProgress(String id) async =>
      DataSuccess(data: null);

  @override
  Future<DataState<List<CrosswordProgressModel>>> getProgressFor(
          List<String> ids) async =>
      DataSuccess(data: const []);

  @override
  Future<DataState<void>> saveProgress(CrosswordProgressEntity progress,
          {required bool create}) async =>
      DataSuccess(data: null);
}

void main() {
  test('a full page means there may be more', () async {
    final repo = CategoryRepositoryImpl(
      source: _Source(),
      progress: CrosswordProgressRepositoryImpl(source: _NoProgress()),
    );
    final page = (await repo.getCategoryPuzzles(categoryId: 'x')).data!;
    expect(page.items, hasLength(20));
    expect(page.hasMore, isTrue);
  });
}
