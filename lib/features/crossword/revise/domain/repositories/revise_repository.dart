import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';

/// "My mistakes".
abstract class ReviseRepository {
  /// Unlearned items, newest first, 20 per page; [after] = last item shown.
  Future<DataState<Paged<RevisionItemEntity>>> getRevisionItems({
    RevisionItemEntity? after,
  });

  Future<DataState<void>> setRevisionMastered({
    required String questionId,
    required bool mastered,
  });
}
