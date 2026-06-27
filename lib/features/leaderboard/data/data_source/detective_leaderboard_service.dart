import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/leaderboard/domain/entities/detective_leaderboard_entry.dart';

abstract class DetectiveLeaderboardDataSource {
  Future<DataState<DetectiveLeaderboardSnapshot>> loadWeeklyLeaderboard({
    required String weekId,
    required String? currentUserId,
    int topLimit = 50,
  });
}
