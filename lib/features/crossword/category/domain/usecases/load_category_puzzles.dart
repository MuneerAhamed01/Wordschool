import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/category/domain/repositories/category_repository.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/utils/load_category_puzzles_param.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';

class LoadCategoryPuzzlesUseCase extends UseCase<
    DataState<Paged<CrosswordPuzzleEntity>>, LoadCategoryPuzzlesParam> {
  LoadCategoryPuzzlesUseCase({required CategoryRepository repository})
      : _repository = repository;

  final CategoryRepository _repository;

  @override
  Future<DataState<Paged<CrosswordPuzzleEntity>>> call(
          {required LoadCategoryPuzzlesParam param}) =>
      _repository.getCategoryPuzzles(
        categoryId: param.categoryId,
        afterNumber: param.afterNumber,
      );
}
