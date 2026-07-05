// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';

class SaveUserSessionUseCase
    extends UseCase<DataState<bool>, WordSchoolUserEntity> {
  final SessionRepository _sessionRepository;
  final UserGameStateRepository _userGameStateRepository;

  SaveUserSessionUseCase({
    required SessionRepository sessionRepository,
    required UserGameStateRepository userGameStateRepository,
  })  : _sessionRepository = sessionRepository,
        _userGameStateRepository = userGameStateRepository;

  @override
  Future<DataState<bool>> call({required WordSchoolUserEntity param}) async {
    final saveResult = await _sessionRepository.saveUser(param);
    if (saveResult is DataError<bool>) {
      return saveResult;
    }

    final ensureResult = await _userGameStateRepository.ensureUserGameState(
      param.id,
    );
    if (ensureResult is DataError) {
      return DataError<bool>(error: ensureResult.error);
    }

    return saveResult;
  }
}
