import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/category/domain/repositories/category_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';

class LoadCrosswordCategoryUseCase
    extends UseCase<DataState<CrosswordCategoryEntity>, String> {
  LoadCrosswordCategoryUseCase({required CategoryRepository repository})
      : _repository = repository;

  final CategoryRepository _repository;

  @override
  Future<DataState<CrosswordCategoryEntity>> call({required String param}) =>
      _repository.getCategory(param);
}
