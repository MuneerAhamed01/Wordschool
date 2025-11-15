import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';

class LoadUserSpecificGameStateUseCase extends UseCase<DataState<UserGameDataEntity>, String> {
  final UserGameStateRepository _userGameStateRepository;

  LoadUserSpecificGameStateUseCase({required UserGameStateRepository userGameStateRepository})
      : _userGameStateRepository = userGameStateRepository;

  @override
  Future<DataState<UserGameDataEntity>> call({required String param}) async {
    return _userGameStateRepository.loadUserSpecificGameData(param);
  }
}