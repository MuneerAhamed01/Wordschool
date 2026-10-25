import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';
import 'package:wordshool/features/crossword/home/domain/repositories/home_repository.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/utils/load_home_progress_param.dart';

class LoadHomeProgressUseCase
    extends UseCase<DataState<HomeProgressEntity>, LoadHomeProgressParam> {
  LoadHomeProgressUseCase({required HomeRepository repository})
      : _repository = repository;

  final HomeRepository _repository;

  @override
  Future<DataState<HomeProgressEntity>> call(
          {required LoadHomeProgressParam param}) =>
      _repository.loadHomeProgress(
        dailyPuzzleId: param.dailyPuzzleId,
        categoryIds: param.categoryIds,
      );
}
