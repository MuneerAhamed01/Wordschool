import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/revise/domain/repositories/revise_repository.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/utils/set_revision_mastered_param.dart';

class SetRevisionMasteredUseCase
    extends UseCase<DataState<void>, SetRevisionMasteredParam> {
  SetRevisionMasteredUseCase({required ReviseRepository repository})
      : _repository = repository;

  final ReviseRepository _repository;

  @override
  Future<DataState<void>> call({required SetRevisionMasteredParam param}) =>
      _repository.setRevisionMastered(
        questionId: param.questionId,
        mastered: param.mastered,
      );
}
