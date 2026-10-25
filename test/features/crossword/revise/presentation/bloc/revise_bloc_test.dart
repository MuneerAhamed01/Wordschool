import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/revise/presentation/bloc/revise_bloc.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';

import '../../../crossword_fakes.dart';
import '../../../fixtures_entities.dart';

void main() {
  late FakeCrosswordRepository repo;
  late FakeUseCases uc;

  setUp(() {
    repo = FakeCrosswordRepository();
    uc = FakeUseCases(repo);
  });

  ReviseBloc build() => ReviseBloc(
        loadItems: uc.loadRevision,
        setMastered: uc.setMastered,
        changes: repo.changes,
      );

  test('loads, pages after the last item, and removes a learned one', () async {
    repo.revisionPages = [
      Paged(
          items: [revisionItem('a', 20), revisionItem('b', 19)], hasMore: true),
      Paged(
          items: [revisionItem('b', 19), revisionItem('c', 18)],
          hasMore: false),
    ];
    final bloc = build()..add(const ReviseRequested());
    await settle();
    bloc.add(const ReviseMoreRequested());
    await settle();
    var state = bloc.state as ReviseLoaded;
    expect(state.items.map((i) => i.questionId), ['a', 'b', 'c']);
    expect(repo.revisionRequests, [null, 'b']);

    bloc.add(const ReviseItemLearned('b'));
    await settle();
    state = bloc.state as ReviseLoaded;
    expect(repo.mastered, ['b']);
    expect(state.items.map((i) => i.questionId), ['a', 'c']);

    repo.failMastered = true;
    bloc.add(const ReviseItemLearned('a'));
    await settle();
    state = bloc.state as ReviseLoaded;
    expect(state.items, hasLength(2));
    expect(state.error, isNotNull);
    await bloc.close();
  });

  test('a failed refresh keeps the list; learning still works', () async {
    repo.revisionPages = [
      Paged(items: [revisionItem('a', 20)], hasMore: false),
    ];
    final bloc = build()..add(const ReviseRequested());
    await settle();
    // Refresh fails (no pages left) while "learned" is in flight.
    bloc
      ..add(const ReviseItemLearned('a'))
      ..add(const ReviseRequested());
    await settle();
    await settle();
    final state = bloc.state as ReviseLoaded;
    expect(state.items, isEmpty);
    expect(repo.mastered, ['a']);
    await bloc.close();
  });

  test('reloads after a submit, not after its own changes', () async {
    repo.revisionPages = [
      const Paged(items: [], hasMore: false),
      const Paged(items: [], hasMore: false),
    ];
    final bloc = build()..add(const ReviseRequested());
    await settle();
    repo.notify(CrosswordChange.revisionChanged);
    await settle();
    expect(repo.revisionRequests, hasLength(1));
    repo.notify(CrosswordChange.puzzleSubmitted);
    await settle();
    await settle();
    expect(repo.revisionRequests, hasLength(2));
    await bloc.close();
  });

  test('an error state on first load', () async {
    final bloc = build()..add(const ReviseRequested());
    await settle();
    expect(bloc.state, isA<ReviseFailed>());
    await bloc.close();
  });
}
