import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/features/crossword/revise/domain/repositories/revise_repository.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/utils/load_revision_items_param.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';

class LoadRevisionItemsUseCase extends UseCase<
    DataState<Paged<RevisionItemEntity>>, LoadRevisionItemsParam> {
  LoadRevisionItemsUseCase({required ReviseRepository repository})
      : _repository = repository;

  final ReviseRepository _repository;

  @override
  Future<DataState<Paged<RevisionItemEntity>>> call(
          {required LoadRevisionItemsParam param}) =>
      _repository.getRevisionItems(after: param.after);
}
