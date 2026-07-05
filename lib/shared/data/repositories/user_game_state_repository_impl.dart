import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/core/utils/streak_calculator.dart';
import 'package:wordshool/shared/data/data_source/user_game_state_service.dart';
import 'package:wordshool/shared/data/models/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/data/models/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';
import 'package:wordshool/shared/domains/usercases/mark_game_usecase/utils/mark_game_completed_params.dart';
import 'package:wordshool/shared/domains/usercases/mark_game_usecase/utils/mark_game_completed_result.dart';

class UserGameStateRepositoryImpl implements UserGameStateRepository {
  final UserGameStateDataSource _dataSource;
  final SessionRepository _sessionRepository;

  UserGameStateRepositoryImpl({
    required UserGameStateDataSource dataSource,
    required SessionRepository sessionRepository,
  })  : _dataSource = dataSource,
        _sessionRepository = sessionRepository;

  String? _currentUserId() {
    return _sessionRepository.getCurrentUser()?.id;
  }

  DataError<T> _noUserError<T>() {
    return DataError<T>(
      error: AppError(error: 'No current user', code: '401'),
    );
  }

  @override
  Future<DataState<UserGameStateEntity>> createUserGameState() async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();
    return _dataSource.createUserGameState(userId);
  }

  @override
  Future<DataState<UserGameStateEntity>> ensureUserGameState(
    String userId,
  ) async {
    return _dataSource.ensureUserGameState(userId);
  }

  @override
  Future<DataState<bool>> addGuessedWord(
    String gameId,
    String guessedWord,
  ) async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();
    return _dataSource.addGuessedWord(userId, gameId, guessedWord);
  }

  @override
  Future<DataState<UserGameDataEntity>> createUserSpecificGameData(
    String gameId,
  ) async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();
    return _dataSource.createUserSpecificGameData(userId, gameId);
  }

  @override
  Future<DataState<UserGameStateEntity>> getUserGameState() async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();
    return _dataSource.getUserGameState(userId);
  }

  @override
  Future<DataState<UserGameDataEntity>> getUserSpecificGameData(
    String gameId,
  ) async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();
    return _dataSource.getUserSpecificGameData(userId, gameId);
  }

  @override
  Future<DataState<MarkGameCompletedResult>> markGameAsCompleted(
    MarkGameCompletedParam param,
  ) async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();

    final existingGameData =
        await _dataSource.getUserSpecificGameData(userId, param.gameId);

    if (existingGameData is DataSuccess<UserGameDataModel>) {
      if (existingGameData.data!.isCompleted) {
        return DataSuccess<MarkGameCompletedResult>(
          data: const MarkGameCompletedResult(wasAlreadyCompleted: true),
        );
      }
    }

    final markResult = await _dataSource.markGameAsCompleted(
      userId,
      param.gameId,
      param.isCorrect,
    );

    if (markResult is! DataSuccess<bool>) {
      return DataError<MarkGameCompletedResult>(error: markResult.error);
    }

    if (param.isArchiveMode) {
      return DataSuccess<MarkGameCompletedResult>(
        data: const MarkGameCompletedResult(wasAlreadyCompleted: false),
      );
    }

    final todayDateId = DateHelper.todayDateId();
    if (param.gameId != todayDateId) {
      return DataSuccess<MarkGameCompletedResult>(
        data: const MarkGameCompletedResult(wasAlreadyCompleted: false),
      );
    }

    final userStateResult = await _dataSource.getUserGameState(userId);
    if (userStateResult is! DataSuccess<UserGameStateModel>) {
      return DataError<MarkGameCompletedResult>(error: userStateResult.error);
    }

    final streakUpdate = StreakCalculator.calculateAfterDailyCompletion(
      currentState: userStateResult.data!,
      completedGameDateId: param.gameId,
      isCorrect: param.isCorrect,
    );

    final streakResult = await _dataSource.updateStreak(
      userId,
      streakUpdate.streak,
      streakUpdate.lastStreakDate,
      streakUpdate.longestStreak,
      streakUpdate.completedGames,
      streakUpdate.totalGames,
    );

    if (streakResult is! DataSuccess<bool>) {
      return DataError<MarkGameCompletedResult>(error: streakResult.error);
    }

    return DataSuccess<MarkGameCompletedResult>(
      data: MarkGameCompletedResult(
        wasAlreadyCompleted: false,
        updatedStreak: streakUpdate.streak,
      ),
    );
  }

  @override
  Future<DataState<bool>> removeGuessedWord(
    String gameId,
    String guessedWord,
  ) async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();
    return _dataSource.removeGuessedWord(userId, gameId, guessedWord);
  }

  @override
  Future<DataState<UserGameStateEntity>> updateUserGameState(
    UserGameStateEntity userGameState,
  ) async {
    final model = UserGameStateModel(
      id: userGameState.id,
      streak: userGameState.streak,
      longestStreak: userGameState.longestStreak,
      lastStreakDate: userGameState.lastStreakDate,
      completedGames: userGameState.completedGames,
      totalGames: userGameState.totalGames,
      detectivePoints: userGameState.detectivePoints,
      storyModeStreak: userGameState.storyModeStreak,
      storyModeLongestStreak: userGameState.storyModeLongestStreak,
      lastStoryModeStreakDate: userGameState.lastStoryModeStreakDate,
      createdDate: userGameState.createdDate,
      updatedDate: userGameState.updatedDate,
    );
    return _dataSource.updateUserGameState(model);
  }

  @override
  Future<DataState<UserGameDataEntity>> updateUserSpecificGameData(
    UserGameDataEntity userGameData,
  ) async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();

    final model = UserGameDataModel(
      id: userGameData.id,
      guessedWords: userGameData.guessedWords,
      isCompleted: userGameData.isCompleted,
      isCorrect: userGameData.isCorrect,
      createdDate: userGameData.createdDate,
      updatedDate: userGameData.updatedDate,
    );
    return _dataSource.updateUserSpecificGameData(userId, model);
  }

  @override
  Future<DataState<UserGameStateEntity>> loadUserGameState() async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();

    final result = await _dataSource.getUserGameState(userId);
    if (result is DataSuccess<UserGameStateModel>) {
      return result;
    }

    final error = result as DataError<UserGameStateModel>;
    if (error.error?.code == '404') {
      return _dataSource.ensureUserGameState(userId);
    }

    return DataError<UserGameStateEntity>(error: error.error);
  }

  @override
  Future<DataState<UserGameDataEntity>> loadUserSpecificGameData(
    String gameId,
  ) async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();

    final result = await _dataSource.getUserSpecificGameData(userId, gameId);
    if (result is DataSuccess<UserGameDataModel>) {
      return result;
    }

    final error = result as DataError<UserGameDataModel>;
    if (error.error?.code == '404') {
      return _dataSource.createUserSpecificGameData(userId, gameId);
    }

    return DataError<UserGameDataEntity>(error: error.error);
  }

  @override
  Future<DataState<List<UserGameDataEntity>>> loadUserGameDataInRange(
    String startDateId,
    String endDateId,
  ) async {
    final userId = _currentUserId();
    if (userId == null) return _noUserError();
    return _dataSource.getUserGameDataInRange(
      userId,
      startDateId,
      endDateId,
    );
  }
}
