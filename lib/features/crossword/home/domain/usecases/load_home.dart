import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';
import 'package:wordshool/features/crossword/home/domain/repositories/home_repository.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/utils/load_home_param.dart';

class LoadCrosswordHomeUseCase
    extends UseCase<DataState<CrosswordHomeEntity>, LoadCrosswordHomeParam> {
  LoadCrosswordHomeUseCase({required HomeRepository repository})
      : _repository = repository;

  final HomeRepository _repository;

  @override
  Future<DataState<CrosswordHomeEntity>> call(
          {required LoadCrosswordHomeParam param}) =>
      _repository.loadHome(todayId: param.todayId);
}
