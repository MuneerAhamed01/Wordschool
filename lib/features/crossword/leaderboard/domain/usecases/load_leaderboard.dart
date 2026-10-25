import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/repositories/leaderboard_repository.dart';

class LoadLeaderboardUseCase
    extends UseCase<DataState<LeaderboardEntity>, String> {
  LoadLeaderboardUseCase({required LeaderboardRepository repository})
      : _repository = repository;

  final LeaderboardRepository _repository;

  @override
  Future<DataState<LeaderboardEntity>> call({required String param}) =>
      _repository.getLeaderboard(param);
}
