import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/utils/save_progress_param.dart';

class SaveCrosswordProgressUseCase
    extends UseCase<DataState<void>, SaveCrosswordProgressParam> {
  SaveCrosswordProgressUseCase({required PuzzleRepository repository})
      : _repository = repository;

  final PuzzleRepository _repository;

  @override
  Future<DataState<void>> call({required SaveCrosswordProgressParam param}) =>
      _repository.saveProgress(
        progress: param.progress,
        create: param.create,
        revealedCells: param.revealedCells,
        revealedWordIds: param.revealedWordIds,
      );
}
