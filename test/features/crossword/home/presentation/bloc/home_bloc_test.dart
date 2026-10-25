import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';
import 'package:wordshool/features/crossword/home/presentation/bloc/home_bloc.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';

import '../../../crossword_fakes.dart';

void main() {
  late FakeCrosswordRepository repo;
  late FakeUseCases uc;

  setUp(() {
    repo = FakeCrosswordRepository();
    uc = FakeUseCases(repo);
  });

  CrosswordHomeBloc build() => CrosswordHomeBloc(
        loadHome: uc.loadHome,
        loadProgress: uc.loadHomeProgress,
        countRevision: uc.countRevision,
        changes: repo.changes,
        // 22 Oct 2026, 20:00 UTC = 23 Oct IST.
        clock: () => DateTime.utc(2026, 10, 22, 20),
      );

  test('loads with the IST date id', () async {
    final bloc = build()..add(const CrosswordHomeRequested());
    await settle();
    final state = bloc.state as CrosswordHomeLoaded;
    expect(state.home.todayId, '2026-10-23');
    await bloc.close();
  });

  test('an error shows a message; a silent reload keeps the data', () async {
    repo.home = dataError('offline');
    final bloc = build()..add(const CrosswordHomeRequested());
    await settle();
    expect(bloc.state, const CrosswordHomeFailed('offline'));

    repo.home = null;
    bloc.add(const CrosswordHomeRequested());
    await settle();
    expect(bloc.state, isA<CrosswordHomeLoaded>());
    repo.home = dataError('offline');
    bloc.add(const CrosswordHomeRequested(silent: true));
    await settle();
    expect(bloc.state, isA<CrosswordHomeLoaded>());
    await bloc.close();
  });

  test('progress refresh uses the marks; a submit reloads everything',
      () async {
    final bloc = build()..add(const CrosswordHomeRequested());
    await settle();
    repo.homeProgress =
        const HomeProgressEntity(completedByCategory: {'kerala-history': 1});
    bloc.add(const CrosswordHomeProgressRefreshed());
    await settle();
    final home = (bloc.state as CrosswordHomeLoaded).home;
    expect(home.completedIn('kerala-history'), 1);
    expect(repo.homeLoads, 1);

    repo.notify(CrosswordChange.puzzleSubmitted);
    await settle();
    await settle();
    expect(repo.homeLoads, 2);
    await bloc.close();
  });

  test('a learned mistake re-counts without reloading Home', () async {
    final bloc = build()..add(const CrosswordHomeRequested());
    await settle();
    repo.revisionCount = 7;
    repo.notify(CrosswordChange.revisionChanged);
    await settle();
    await settle();
    expect((bloc.state as CrosswordHomeLoaded).home.revisionCount, 7);
    expect(repo.revisionCounts, 1);
    expect(repo.homeLoads, 1);
    await bloc.close();
  });

  test('CrosswordHomeEntity daily progress and streak', () {
    const home = CrosswordHomeEntity(todayId: '2026-10-23');
    expect(home.dailyProgress, isNull);
    expect(home.currentStreak, 0);
    expect(home.completedIn('x'), 0);
  });
}
