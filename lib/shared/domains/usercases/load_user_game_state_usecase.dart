import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';

class LoadUserGameStateUseCase
    extends UseCase<DataState<UserGameStateEntity>, void> {
  final UserGameStateRepository _userGameStateRepository;

  LoadUserGameStateUseCase(
      {required UserGameStateRepository userGameStateRepository})
      : _userGameStateRepository = userGameStateRepository;

  @override
  Future<DataState<UserGameStateEntity>> call({void param}) async {
    return _userGameStateRepository.getUserGameState();
  }
}
