import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/shared/data/data_source/progress_service.dart';
import 'package:wordshool/features/crossword/shared/data/models/progress.dart';
import 'package:wordshool/features/crossword/shared/data/repositories/progress_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

import '../../../crossword_fakes.dart';

class _Source implements ProgressDataSource {
  final docs = <String, CrosswordProgressModel>{};
  final getCalls = <String>[];
  final forCalls = <List<String>>[];
  final countCalls = <String>[];
  int completed = 2;
  bool failSave = false;

  @override
  Future<DataState<CrosswordProgressModel?>> getProgress(String id) async {
    getCalls.add(id);
    return DataSuccess(data: docs[id]);
  }

  @override
  Future<DataState<List<CrosswordProgressModel>>> getProgressFor(
      List<String> ids) async {
    forCalls.add(ids);
    return DataSuccess(data: [
      for (final id in ids)
        if (docs[id] != null) docs[id]!
    ]);
  }

  @override
  Future<DataState<int>> countCompleted(String categoryId) async {
    countCalls.add(categoryId);
    return DataSuccess(data: completed);
  }

  @override
  Future<DataState<void>> saveProgress(CrosswordProgressEntity progress,
          {required bool create}) async =>
      failSave ? dataError() : DataSuccess(data: null);
}

CrosswordProgressModel _doc(String id, {bool completed = false}) =>
    CrosswordProgressModel(
      puzzleId: id,
      letters: '',
      status: completed
          ? CrosswordProgressStatus.completed
          : CrosswordProgressStatus.inProgress,
    );

void main() {
  late _Source source;
  late CrosswordProgressRepositoryImpl repo;

  setUp(() {
    source = _Source();
    repo = CrosswordProgressRepositoryImpl(source: source);
  });

  test('one puzzle is read once, including "not started"', () async {
    expect((await repo.getProgress('a-0001')).data, isNull);
    expect((await repo.getProgress('a-0001')).data, isNull);
    expect(source.getCalls, ['a-0001']);
  });

  test('a page of ids is read in chunks of 30 and only once', () async {
    source.docs['a-0002'] = _doc('a-0002');
    final ids = [for (var i = 1; i <= 35; i++) 'a-${'$i'.padLeft(4, '0')}'];
    final marks = (await repo.getProgressFor(ids)).data!;
    expect(marks.keys, ['a-0002']);
    expect(source.forCalls.map((c) => c.length), [30, 5]);
    await repo.getProgressFor(ids);
    expect(source.forCalls, hasLength(2));
  });

  test('a first submit bumps the cached category count', () async {
    expect((await repo.countCompleted('a')).data, 2);
    repo.markCompleted(_doc('a-0003', completed: true));
    expect((await repo.countCompleted('a')).data, 3);
    // Opening it again (already completed) doesn't count twice.
    repo.markCompleted(_doc('a-0003', completed: true));
    expect((await repo.countCompleted('a')).data, 3);
    expect(source.countCalls, ['a']);
  });

  test('a save shows at once; a failed first save is forgotten', () async {
    final save = repo.saveProgress(_doc('a-0004'), create: true);
    expect((await repo.getProgressFor(['a-0004'])).data!.keys, ['a-0004']);
    await save;

    source.failSave = true;
    await repo.saveProgress(_doc('a-0005'), create: true);
    expect((await repo.getProgress('a-0005')).data, isNull);
    expect(source.getCalls, ['a-0005']);
  });
}
