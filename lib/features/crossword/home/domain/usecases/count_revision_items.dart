import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/home/domain/repositories/home_repository.dart';

/// The "My mistakes" count on Home.
class CountRevisionItemsUseCase extends UseCase<DataState<int>, void> {
  CountRevisionItemsUseCase({required HomeRepository repository})
      : _repository = repository;

  final HomeRepository _repository;

  @override
  Future<DataState<int>> call({void param}) => _repository.countRevisionItems();
}
