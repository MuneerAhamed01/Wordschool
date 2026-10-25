import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/category/domain/repositories/category_repository.dart';

/// Completed puzzles in a category (the header's "3 / 12 played").
class CountCompletedUseCase extends UseCase<DataState<int>, String> {
  CountCompletedUseCase({required CategoryRepository repository})
      : _repository = repository;

  final CategoryRepository _repository;

  @override
  Future<DataState<int>> call({required String param}) =>
      _repository.countCompleted(param);
}
