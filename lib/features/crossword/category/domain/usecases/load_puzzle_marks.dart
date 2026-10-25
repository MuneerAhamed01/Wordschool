import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/category/domain/repositories/category_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

/// Solved / in-progress marks for the puzzle ids shown.
class LoadPuzzleMarksUseCase extends UseCase<
    DataState<Map<String, CrosswordProgressEntity>>, List<String>> {
  LoadPuzzleMarksUseCase({required CategoryRepository repository})
      : _repository = repository;

  final CategoryRepository _repository;

  @override
  Future<DataState<Map<String, CrosswordProgressEntity>>> call(
          {required List<String> param}) =>
      _repository.getPuzzleMarks(param);
}
