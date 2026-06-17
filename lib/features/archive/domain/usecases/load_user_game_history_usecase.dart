import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/features/archive/domain/usecases/utils/load_user_game_history_param.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';

class LoadUserGameHistoryUseCase
    extends UseCase<DataState<List<UserGameDataEntity>>, LoadUserGameHistoryParam> {
  final UserGameStateRepository _userGameStateRepository;

  LoadUserGameHistoryUseCase({
    required UserGameStateRepository userGameStateRepository,
  }) : _userGameStateRepository = userGameStateRepository;

  @override
  Future<DataState<List<UserGameDataEntity>>> call({
    required LoadUserGameHistoryParam param,
  }) async {
    final startDateId =
        DateHelper.monthStartDateId(param.year, param.month);
    final endDateId = DateHelper.monthEndDateId(param.year, param.month);

    return _userGameStateRepository.loadUserGameDataInRange(
      startDateId,
      endDateId,
    );
  }
}
