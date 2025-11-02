import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/data/models/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/data/models/user_game_state/user_game_state.dart';

abstract class UserGameStateDataSource {
  Future<DataState<UserGameStateModel>> createUserGameState(String userId);

  Future<DataState<UserGameStateModel>> getUserGameState(String userId);

  Future<DataState<UserGameStateModel>> updateUserGameState(
    UserGameStateModel userGameState,
  );

  Future<DataState<UserGameDataModel>> createUserSpecificGameData(
    String userId,
    String gameId,
  );

  Future<DataState<UserGameDataModel>> getUserSpecificGameData(
    String userId,
    String gameId,
  );

  Future<DataState<UserGameDataModel>> updateUserSpecificGameData(
    UserGameDataModel userGameData,
  );

  Future<DataState<bool>> markGameAsCompleted(
    String userId,
    String gameId,
    bool isCorrect,
  );

  Future<DataState<bool>> addGuessedWord(
    String userId,
    String gameId,
    String guessedWord,
  );

  Future<DataState<bool>> removeGuessedWord(
    String userId,
    String gameId,
    String guessedWord,
  );

  Future<DataState<bool>> updateCompletedGames(
    String userId,
    int completedGames,
  );

  Future<DataState<bool>> updateTotalGames(String userId, int totalGames);

  Future<DataState<bool>> updateStreak(String userId, int streak);
}
