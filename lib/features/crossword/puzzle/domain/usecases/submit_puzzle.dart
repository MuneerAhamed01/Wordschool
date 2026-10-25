import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/utils/submit_puzzle_param.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';

class SubmitCrosswordUseCase
    extends UseCase<DataState<CrosswordSubmitOutcome>, SubmitCrosswordParam> {
  SubmitCrosswordUseCase({required PuzzleRepository repository})
      : _repository = repository;

  final PuzzleRepository _repository;

  @override
  Future<DataState<CrosswordSubmitOutcome>> call(
          {required SubmitCrosswordParam param}) =>
      _repository.submit(
        progress: param.progress,
        revealedWordIds: param.revealedWordIds,
      );
}
