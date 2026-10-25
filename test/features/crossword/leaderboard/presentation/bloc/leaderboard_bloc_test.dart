import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';

import '../../../crossword_fakes.dart';

void main() {
  late FakeCrosswordRepository repo;
  late FakeUseCases uc;

  setUp(() {
    repo = FakeCrosswordRepository();
    uc = FakeUseCases(repo);
  });

  test('reads this IST week board and reloads after a submit', () async {
    repo.leaderboard = const LeaderboardEntity(boardId: 'crossword-2026-W44');
    final bloc = LeaderboardBloc(
      loadLeaderboard: uc.loadLeaderboard,
      myUid: 'alice',
      changes: repo.changes,
      clock: () => DateTime.utc(2026, 10, 25, 20), // Mon 01:30 IST
    )..add(const LeaderboardRequested());
    await settle();
    expect(repo.boardRequests, ['crossword-2026-W44']);
    expect((bloc.state as LeaderboardLoaded).myUid, 'alice');
    repo.notify(CrosswordChange.revisionChanged);
    await settle();
    expect(repo.boardRequests, hasLength(1));
    repo.notify(CrosswordChange.puzzleSubmitted);
    await settle();
    expect(repo.boardRequests, hasLength(2));
    await bloc.close();
  });

  test('error state', () async {
    final bloc =
        LeaderboardBloc(loadLeaderboard: uc.loadLeaderboard, myUid: null)
          ..add(const LeaderboardRequested());
    await settle();
    expect(bloc.state, isA<LeaderboardFailed>());
    await bloc.close();
  });

  test('dataError() helper carries the message', () {
    expect(dataError<int>('x').error!.message, 'x');
  });
}
