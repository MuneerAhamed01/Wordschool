import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';
import 'package:wordshool/shared/domains/usercases/mark_game_usecase/utils/mark_game_completed_params.dart';
import 'package:wordshool/shared/domains/usercases/mark_game_usecase/utils/mark_game_completed_result.dart';

class MarkGameCompletedUseCase
    extends UseCase<DataState<MarkGameCompletedResult>, MarkGameCompletedParam> {
  final UserGameStateRepository _userGameStateRepository;

  MarkGameCompletedUseCase({
    required UserGameStateRepository userGameStateRepository,
  }) : _userGameStateRepository = userGameStateRepository;

  @override
  Future<DataState<MarkGameCompletedResult>> call({
    required MarkGameCompletedParam param,
  }) async {
    return _userGameStateRepository.markGameAsCompleted(param);
  }
}
