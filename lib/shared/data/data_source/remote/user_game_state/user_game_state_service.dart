import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/data/data_source/user_game_state_service.dart';
import 'package:wordshool/shared/data/models/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/data/models/user_game_state/user_game_state.dart';

class UserGameStateDataSourceImpl extends UserGameStateDataSource {
  final FirebaseFirestore _firestore;

  UserGameStateDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<DataState<UserGameStateModel>> createUserGameState(
    String userId,
  ) async {
    try {
      final gameStateDoc =
          _firestore.collection(FirebaseCollections.userGameStates).doc(userId);

      final emptyUserData = UserGameStateModel(
        id: gameStateDoc.id,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );
      await gameStateDoc.set(emptyUserData.toJson());
      return DataSuccess<UserGameStateModel>(data: emptyUserData);
    } catch (e) {
      return DataError<UserGameStateModel>(
        error: AppError(error: e.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<bool>> addGuessedWord(
      String userId, String gameId, String guessedWord) async {
    try {
      final gameDataDoc = _firestore
          .collection(FirebaseCollections.userGameStates)
          .doc(userId)
          .collection(FirebaseCollections.userGameData)
          .doc(gameId);

      await gameDataDoc.update({
        'guessedWords': FieldValue.arrayUnion([guessedWord]),
      });

      return DataSuccess<bool>(data: true);
    } catch (e) {
      return DataError<bool>(error: AppError(error: e.toString(), code: '500'));
    }
  }

  @override
  Future<DataState<UserGameDataModel>> createUserSpecificGameData(
    String userId,
    String gameId,
  ) async {
    try {
      final gameDataDoc = _firestore
          .collection(FirebaseCollections.userGameStates)
          .doc(userId)
          .collection(FirebaseCollections.userGameData)
          .doc(gameId);

      final emptyGameData = UserGameDataModel(
        id: gameDataDoc.id,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );
      await gameDataDoc.set(emptyGameData.toJson());
      return DataSuccess<UserGameDataModel>(data: emptyGameData);
    } catch (e) {
      return DataError<UserGameDataModel>(
        error: AppError(error: e.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<UserGameStateModel>> getUserGameState(String userId) async {
    try {
      final gameStateDoc = await _firestore
          .collection(FirebaseCollections.userGameStates)
          .doc(userId)
          .get();
      if (!gameStateDoc.exists) {
        return DataError<UserGameStateModel>(
            error: AppError(error: 'Game state not found', code: '404'));
      }
      return DataSuccess<UserGameStateModel>(
          data: UserGameStateModel.fromJson(gameStateDoc.data() ?? {}));
    } catch (e) {
      return DataError<UserGameStateModel>(
          error: AppError(error: e.toString(), code: '500'));
    }
  }

  @override
  Future<DataState<UserGameDataModel>> getUserSpecificGameData(
      String userId, String gameId) async {
    try {
      final gameDataDoc = await _firestore
          .collection(FirebaseCollections.userGameStates)
          .doc(userId)
          .collection(FirebaseCollections.userGameData)
          .doc(gameId)
          .get();

      if (!gameDataDoc.exists) {
        return DataError<UserGameDataModel>(
            error: AppError(error: 'Game data not found', code: '404'));
      }

      return DataSuccess<UserGameDataModel>(
        data: UserGameDataModel.fromJson(gameDataDoc.data() ?? {}),
      );
    } catch (e) {
      return DataError<UserGameDataModel>(
          error: AppError(error: e.toString(), code: '500'));
    }
  }

  @override
  Future<DataState<bool>> markGameAsCompleted(
      String userId, String gameId, bool isCorrect) async {
    try {
      final gameDataDoc = _firestore
          .collection(FirebaseCollections.userGameStates)
          .doc(userId)
          .collection(FirebaseCollections.userGameData)
          .doc(gameId);

      gameDataDoc.update({'isCompleted': true, 'isCorrect': isCorrect});
      return DataSuccess<bool>(data: true);
    } catch (e) {
      return DataError<bool>(error: AppError(error: e.toString(), code: '500'));
    }
  }

  @override
  Future<DataState<bool>> removeGuessedWord(
    String userId,
    String gameId,
    String guessedWord,
  ) async {
    try {
      final gameDataDoc = _firestore
          .collection(FirebaseCollections.userGameStates)
          .doc(userId)
          .collection(FirebaseCollections.userGameData)
          .doc(gameId);

      gameDataDoc.update({
        'guessedWords': FieldValue.arrayRemove([guessedWord]),
      });
      return DataSuccess<bool>(data: true);
    } catch (e) {
      return DataError<bool>(error: AppError(error: e.toString(), code: '500'));
    }
  }

  @override
  Future<DataState<bool>> updateCompletedGames(
      String userId, int completedGames) async {
    try {
      final gameStateDoc =
          _firestore.collection(FirebaseCollections.userGameStates).doc(userId);

      gameStateDoc.update({'completedGames': completedGames});
      return DataSuccess<bool>(data: true);
    } catch (e) {
      return DataError<bool>(error: AppError(error: e.toString(), code: '500'));
    }
  }

  @override
  Future<DataState<bool>> updateStreak(String userId, int streak) {
    throw UnimplementedError();
  }

  @override
  Future<DataState<bool>> updateTotalGames(
      String userId, int totalGames) async {
    try {
      final gameStateDoc =
          _firestore.collection(FirebaseCollections.userGameStates).doc(userId);

      await gameStateDoc.update({'totalGames': totalGames});

      return DataSuccess<bool>(data: true);
    } catch (e) {
      return DataError<bool>(error: AppError(error: e.toString(), code: '500'));
    }
  }

  @override
  Future<DataState<UserGameStateModel>> updateUserGameState(
      UserGameStateModel userGameState) async {
    try {
      final gameStateDoc = _firestore
          .collection(FirebaseCollections.userGameStates)
          .doc(userGameState.id);

      await gameStateDoc.update(userGameState.toJson());
      return DataSuccess<UserGameStateModel>(data: userGameState);
    } catch (e) {
      return DataError<UserGameStateModel>(
          error: AppError(error: e.toString(), code: '500'));
    }
  }

  @override
  Future<DataState<UserGameDataModel>> updateUserSpecificGameData(
      UserGameDataModel userGameData) async {
    try {
      final gameDataDoc = _firestore
          .collection(FirebaseCollections.userGameStates)
          .doc(userGameData.id)
          .collection(FirebaseCollections.userGameData)
          .doc(userGameData.id);

      await gameDataDoc.update(userGameData.toJson());
      return DataSuccess<UserGameDataModel>(data: userGameData);
    } catch (e) {
      return DataError<UserGameDataModel>(
        error: AppError(error: e.toString(), code: '500'),
      );
    }
  }
}
