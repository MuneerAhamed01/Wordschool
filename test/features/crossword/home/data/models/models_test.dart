import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/home/data/models/daily.dart';
import 'package:wordshool/features/crossword/home/data/models/player_profile.dart';

import '../../../crossword_fixtures.dart';

void main() {
  test('daily doc', () {
    final (data, id) = fixtureDoc('daily');
    final daily = CrosswordDailyModel.fromJson(data, documentId: id);
    expect(daily.dateId, '2026-10-22');
    expect(daily.puzzleId, 'kerala-history-0012');
    expect(daily.wordCount, 7);
    expect(CrosswordDailyModel.fromJson(daily.toJson(), documentId: id), daily);
  });

  test('user doc', () {
    final (data, id) = fixtureDoc('user');
    final profile = PlayerProfileModel.fromJson(data, documentId: id);
    expect(profile.xp, 1285);
    expect(profile.crossword.currentStreak, 4);
    expect(profile.crossword.bestTimeSec, 141);
    // A doc without stats (made by the profile write) still parses.
    final fresh = PlayerProfileModel.fromJson({'displayName': 'Guest 0042'},
        documentId: 'g');
    expect(fresh.xp, 0);
    expect(fresh.crossword.played, 0);
  });
}
