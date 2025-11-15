import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';

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

  Future<DataState<bool>> markGameAsCompleted(
    String gameId,
    bool isCorrect,
  );

  Future<DataState<bool>> removeGuessedWord(
    String gameId,
    String guessedWord,
  );

  Future<DataState<bool>> updateCompletedGames(
    int completedGames,
  );

  Future<DataState<bool>> updateStreak(
    int streak,
  );

  Future<DataState<bool>> updateTotalGames(
    int totalGames,
  );

  Future<DataState<UserGameStateEntity>> updateUserGameState(
    UserGameStateEntity userGameState,
  );

  Future<DataState<UserGameDataEntity>> updateUserSpecificGameData(
    UserGameDataEntity userGameData,
  );
}
