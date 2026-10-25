import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/revise/data/models/revision_item.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';

/// `users/{uid}/revisionItems` ("My mistakes").
abstract class ReviseDataSource {
  /// Unlearned items, `lastWrongAt` desc then id desc; [after] is the last
  /// item already shown.
  Future<DataState<List<RevisionItemModel>>> getRevisionItems({
    RevisionItemEntity? after,
    required int limit,
  });

  Future<DataState<void>> setRevisionMastered(String questionId, bool mastered);
}
