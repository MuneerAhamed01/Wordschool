import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/leaderboard/data/models/leaderboard.dart';

import '../../../crossword_fixtures.dart';

void main() {
  test('leaderboard doc and entry', () {
    final json = fixture('leaderboard');
    final entryJson = json['entry'] as Map<String, dynamic>;
    final me = LeaderboardEntryModel.fromJson(
        entryJson['data'] as Map<String, dynamic>,
        documentId: entryJson['id'] as String);
    final board = LeaderboardModel.fromJson(
        json['data'] as Map<String, dynamic>,
        documentId: json['id'] as String,
        me: me,
        myRank: 2);
    expect(board.boardId, 'crossword-2026-W43');
    expect(board.top.map((e) => e.uid), ['bob', 'alice']);
    expect(board.meInTop, isTrue);
    expect(me.points, 210);
    expect(board.updatedAt, isNotNull);
  });
}
