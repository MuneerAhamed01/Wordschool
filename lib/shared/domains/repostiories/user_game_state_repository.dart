import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/usercases/mark_game_usecase/utils/mark_game_completed_params.dart';
import 'package:wordshool/shared/domains/usercases/mark_game_usecase/utils/mark_game_completed_result.dart';

abstract class UserGameStateRepository {
  Future<DataState<UserGameStateEntity>> createUserGameState();

  Future<DataState<bool>> addGuessedWord(
    String gameId,
    String guessedWord,
  );

  Future<DataState<UserGameDataEntity>> createUserSpecificGameData(
    String gameId,
  );

  Future<DataState<UserGameStateEntity>> getUserGameState();

  Future<DataState<UserGameDataEntity>> getUserSpecificGameData(
    String gameId,
  );

  Future<DataState<MarkGameCompletedResult>> markGameAsCompleted(
    MarkGameCompletedParam param,
  );

  Future<DataState<bool>> removeGuessedWord(
    String gameId,
    String guessedWord,
  );

  Future<DataState<UserGameStateEntity>> updateUserGameState(
    UserGameStateEntity userGameState,
  );

  Future<DataState<UserGameDataEntity>> updateUserSpecificGameData(
    UserGameDataEntity userGameData,
  );

  Future<DataState<UserGameStateEntity>> loadUserGameState();

  Future<DataState<UserGameDataEntity>> loadUserSpecificGameData(String gameId);

  Future<DataState<List<UserGameDataEntity>>> loadUserGameDataInRange(
    String startDateId,
    String endDateId,
  );
}
