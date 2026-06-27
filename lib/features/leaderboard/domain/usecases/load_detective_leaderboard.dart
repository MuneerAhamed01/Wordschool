import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/leaderboard/domain/entities/detective_leaderboard_entry.dart';
import 'package:wordshool/features/leaderboard/domain/repositories/detective_leaderboard_repository.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';

class LoadDetectiveLeaderboardUseCase
    extends UseCase<DataState<DetectiveLeaderboardSnapshot>, void> {
  LoadDetectiveLeaderboardUseCase({
    required DetectiveLeaderboardRepository repository,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _repository = repository,
        _getCurrentUserUseCase = getCurrentUserUseCase;

  final DetectiveLeaderboardRepository _repository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  @override
  Future<DataState<DetectiveLeaderboardSnapshot>> call({void param}) async {
    final user = await _getCurrentUserUseCase();
    return _repository.loadWeeklyLeaderboard(currentUserId: user?.id);
  }
}
