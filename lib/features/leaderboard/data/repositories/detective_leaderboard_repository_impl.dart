import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/iso_week_id.dart';
import 'package:wordshool/features/leaderboard/data/data_source/detective_leaderboard_service.dart';
import 'package:wordshool/features/leaderboard/domain/entities/detective_leaderboard_entry.dart';
import 'package:wordshool/features/leaderboard/domain/repositories/detective_leaderboard_repository.dart';

class DetectiveLeaderboardRepositoryImpl
    implements DetectiveLeaderboardRepository {
  DetectiveLeaderboardRepositoryImpl({
    required DetectiveLeaderboardDataSource dataSource,
  }) : _dataSource = dataSource;

  final DetectiveLeaderboardDataSource _dataSource;

  @override
  Future<DataState<DetectiveLeaderboardSnapshot>> loadWeeklyLeaderboard({
    required String? currentUserId,
    int topLimit = 50,
  }) {
    return _dataSource.loadWeeklyLeaderboard(
      weekId: IsoWeekId.current(),
      currentUserId: currentUserId,
      topLimit: topLimit,
    );
  }
}
