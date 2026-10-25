import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/puzzle/domain/entities/session.dart';
import 'package:wordshool/features/crossword/puzzle/domain/repositories/puzzle_repository.dart';

class LoadPuzzleUseCase
    extends UseCase<DataState<PuzzleSessionEntity>, String> {
  LoadPuzzleUseCase({required PuzzleRepository repository})
      : _repository = repository;

  final PuzzleRepository _repository;

  @override
  Future<DataState<PuzzleSessionEntity>> call({required String param}) =>
      _repository.loadPuzzle(param);
}
