import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/revise/data/data_source/revise_service.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/features/crossword/revise/domain/repositories/revise_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/changes_repository.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';

class ReviseRepositoryImpl implements ReviseRepository {
  ReviseRepositoryImpl({
    required ReviseDataSource source,
    required CrosswordChangesRepository changes,
  })  : _source = source,
        _changes = changes;

  final ReviseDataSource _source;
  final CrosswordChangesRepository _changes;

  @override
  Future<DataState<Paged<RevisionItemEntity>>> getRevisionItems({
    RevisionItemEntity? after,
  }) async {
    final result =
        await _source.getRevisionItems(after: after, limit: Paged.pageSize);
    if (result is DataError) return DataError(error: result.error);
    final items = result.data ?? const [];
    return DataSuccess(
      data: Paged(items: items, hasMore: items.length == Paged.pageSize),
    );
  }

  @override
  Future<DataState<void>> setRevisionMastered({
    required String questionId,
    required bool mastered,
  }) async {
    final result = await _source.setRevisionMastered(questionId, mastered);
    if (result is DataSuccess) _changes.notify(CrosswordChange.revisionChanged);
    return result;
  }
}
