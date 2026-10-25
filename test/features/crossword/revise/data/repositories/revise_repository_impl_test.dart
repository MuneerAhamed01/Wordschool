import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/revise/data/data_source/revise_service.dart';
import 'package:wordshool/features/crossword/revise/data/models/revision_item.dart';
import 'package:wordshool/features/crossword/revise/data/repositories/revise_repository_impl.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/features/crossword/shared/data/repositories/changes_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';

import '../../../crossword_fakes.dart';

class _Source implements ReviseDataSource {
  bool fail = false;

  @override
  Future<DataState<List<RevisionItemModel>>> getRevisionItems(
          {RevisionItemEntity? after, required int limit}) async =>
      DataSuccess(data: const []);

  @override
  Future<DataState<void>> setRevisionMastered(String id, bool mastered) async =>
      fail ? dataError() : DataSuccess(data: null);
}

void main() {
  test('learning an item tells Home to re-count; a failure does not', () async {
    final source = _Source();
    final changes = CrosswordChangesRepositoryImpl();
    final repo = ReviseRepositoryImpl(source: source, changes: changes);
    final seen = <CrosswordChange>[];
    final sub = changes.changes.listen(seen.add);

    await repo.setRevisionMastered(questionId: 'q', mastered: true);
    source.fail = true;
    await repo.setRevisionMastered(questionId: 'q', mastered: true);
    await Future<void>.delayed(Duration.zero);

    expect(seen, [CrosswordChange.revisionChanged]);
    await sub.cancel();
  });
}
