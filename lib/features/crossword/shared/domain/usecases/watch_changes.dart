import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/changes_repository.dart';

/// Emits after a submit or a "My mistakes" change.
class WatchCrosswordChangesUseCase
    extends UseCase<Stream<CrosswordChange>, void> {
  WatchCrosswordChangesUseCase({required CrosswordChangesRepository repository})
      : _repository = repository;

  final CrosswordChangesRepository _repository;

  @override
  Stream<CrosswordChange> call({void param}) => _repository.changes;
}
