import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';

abstract class LeaderboardRepository {
  /// `top50`, the player's own entry and rank on [boardId].
  Future<DataState<LeaderboardEntity>> getLeaderboard(String boardId);
}
