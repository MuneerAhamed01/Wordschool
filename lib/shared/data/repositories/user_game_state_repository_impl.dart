import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/data/data_source/user_game_state_service.dart';
import 'package:wordshool/shared/data/models/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/data/models/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';

class UserGameStateRepositoryImpl implements UserGameStateRepository {
  final UserGameStateDataSource _dataSource;
  final SessionRepository _sessionRepository;

  UserGameStateRepositoryImpl({
    required UserGameStateDataSource dataSource,
    required SessionRepository sessionRepository,
  })  : _dataSource = dataSource,
        _sessionRepository = sessionRepository;

  @override
  Future<DataState<UserGameStateEntity>> createUserGameState() async {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return DataError<UserGameStateEntity>(
        error: AppError(error: 'No current user', code: '401'),
      );
    }
    return _dataSource.createUserGameState(user.id);
  }

  @override
  Future<DataState<bool>> addGuessedWord(
    String gameId,
    String guessedWord,
  ) async {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return DataError<bool>(
        error: AppError(error: 'No current user', code: '401'),
      );
    }
    return _dataSource.addGuessedWord(user.id, gameId, guessedWord);
  }

  @override
  Future<DataState<UserGameDataEntity>> createUserSpecificGameData(
    String gameId,
  ) async {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return DataError<UserGameDataEntity>(
        error: AppError(
          error: 'No current user',
          code: '401',
        ),
      );
    }
    return _dataSource.createUserSpecificGameData(user.id, gameId);
  }

  @override
  Future<DataState<UserGameStateEntity>> getUserGameState() async {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return DataError<UserGameStateEntity>(
        error: AppError(
          error: 'No current user',
          code: '401',
        ),
      );
    }
    return _dataSource.getUserGameState(user.id);
  }

  @override
  Future<DataState<UserGameDataEntity>> getUserSpecificGameData(
    String gameId,
  ) async {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return DataError<UserGameDataEntity>(
          error: AppError(error: 'No current user', code: '401'));
    }
    return _dataSource.getUserSpecificGameData(user.id, gameId);
  }

  @override
  Future<DataState<bool>> markGameAsCompleted(
    String gameId,
    bool isCorrect,
  ) {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return Future.value(DataError<bool>(
          error: AppError(error: 'No current user', code: '401')));
    }
    return _dataSource.markGameAsCompleted(user.id, gameId, isCorrect);
  }

  @override
  Future<DataState<bool>> removeGuessedWord(
    String gameId,
    String guessedWord,
  ) {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return Future.value(DataError<bool>(
          error: AppError(error: 'No current user', code: '401')));
    }
    return _dataSource.removeGuessedWord(user.id, gameId, guessedWord);
  }

  @override
  Future<DataState<bool>> updateCompletedGames(
    int completedGames,
  ) {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return Future.value(DataError<bool>(
          error: AppError(error: 'No current user', code: '401')));
    }
    return _dataSource.updateCompletedGames(user.id, completedGames);
  }

  @override
  Future<DataState<bool>> updateStreak(int streak) {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return Future.value(DataError<bool>(
          error: AppError(error: 'No current user', code: '401')));
    }
    return _dataSource.updateStreak(user.id, streak);
  }

  @override
  Future<DataState<bool>> updateTotalGames(int totalGames) {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return Future.value(DataError<bool>(
          error: AppError(error: 'No current user', code: '401')));
    }
    return _dataSource.updateTotalGames(user.id, totalGames);
  }

  @override
  Future<DataState<UserGameStateEntity>> updateUserGameState(
    UserGameStateEntity userGameState,
  ) async {
    final model = UserGameStateModel(
      id: userGameState.id,
      streak: userGameState.streak,
      completedGames: userGameState.completedGames,
      totalGames: userGameState.totalGames,
      createdDate: userGameState.createdDate,
      updatedDate: userGameState.updatedDate,
    );
    return _dataSource.updateUserGameState(model);
  }

  @override
  Future<DataState<UserGameDataEntity>> updateUserSpecificGameData(
    UserGameDataEntity userGameData,
  ) async {
    final model = UserGameDataModel(
      id: userGameData.id,
      guessedWords: userGameData.guessedWords,
      isCompleted: userGameData.isCompleted,
      isCorrect: userGameData.isCorrect,
      createdDate: userGameData.createdDate,
      updatedDate: userGameData.updatedDate,
    );
    return _dataSource.updateUserSpecificGameData(model);
  }

  @override
  Future<DataState<UserGameStateEntity>> loadUserGameState() async {
    final user = _sessionRepository.getCurrentUser();
    if (user == null) {
      return DataError<UserGameStateEntity>(
        error: AppError(error: 'No current user', code: '401'),
      );
    }

    final res = await _dataSource.getUserGameState(user.id);
    if (res is DataSuccess<UserGameStateModel>) {
      return res;
    }
    final err = res as DataError<UserGameStateModel>;
    if (err.error?.code == '404') {
      final createRes = await _dataSource.createUserGameState(user.id);
      return createRes;
    }
    return DataError<UserGameStateEntity>(error: err.error);
  }
}
