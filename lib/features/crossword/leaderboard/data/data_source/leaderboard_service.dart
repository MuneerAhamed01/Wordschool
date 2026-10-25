import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/leaderboard/data/models/leaderboard.dart';

/// `leaderboards/{boardId}` (`top50`) and the player's own entry.
abstract class LeaderboardDataSource {
  Future<DataState<LeaderboardModel>> getLeaderboard(String boardId);
}
