import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/leaderboard/data/data_source/leaderboard_service.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  LeaderboardRepositoryImpl({required LeaderboardDataSource source})
      : _source = source;

  final LeaderboardDataSource _source;

  @override
  Future<DataState<LeaderboardEntity>> getLeaderboard(String boardId) =>
      _source.getLeaderboard(boardId);
}
