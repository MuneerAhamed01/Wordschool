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

  CollectionReference<Map<String, dynamic>> _userGameStateCollection() {
    return _firestore.collection(FirebaseCollections.userGameStates);
  }

  CollectionReference<Map<String, dynamic>> _userGameDataCollection(
    String userId,
  ) {
    return _userGameStateCollection()
        .doc(userId)
        .collection(FirebaseCollections.userGameData);
  }

  @override
  Future<DataState<UserGameStateModel>> createUserGameState(
    String userId,
  ) async {
    try {
      final gameStateDoc = _userGameStateCollection().doc(userId);
      final emptyUserData = UserGameStateModel(
        id: gameStateDoc.id,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );
      await gameStateDoc.set(emptyUserData.toJson());
      return DataSuccess<UserGameStateModel>(data: emptyUserData);
    } catch (error) {
      return DataError<UserGameStateModel>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<bool>> addGuessedWord(
    String userId,
    String gameId,
    String guessedWord,
  ) async {
    try {
      await _userGameDataCollection(userId).doc(gameId).update({
        'guessedWords': FieldValue.arrayUnion([guessedWord]),
        'updatedDate': FieldValue.serverTimestamp(),
      });
      return DataSuccess<bool>(data: true);
    } catch (error) {
      return DataError<bool>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<UserGameDataModel>> createUserSpecificGameData(
    String userId,
    String gameId,
  ) async {
    try {
      final gameDataDoc = _userGameDataCollection(userId).doc(gameId);
      final emptyGameData = UserGameDataModel(
        id: gameDataDoc.id,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );
      await gameDataDoc.set(emptyGameData.toJson());
      return DataSuccess<UserGameDataModel>(data: emptyGameData);
    } catch (error) {
      return DataError<UserGameDataModel>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<UserGameStateModel>> getUserGameState(String userId) async {
    try {
      final gameStateDoc = await _userGameStateCollection().doc(userId).get();
      if (!gameStateDoc.exists) {
        return DataError<UserGameStateModel>(
          error: AppError(error: 'Game state not found', code: '404'),
        );
      }
      return DataSuccess<UserGameStateModel>(
        data: UserGameStateModel.fromJson(gameStateDoc.data() ?? {}),
      );
    } catch (error) {
      return DataError<UserGameStateModel>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<UserGameDataModel>> getUserSpecificGameData(
    String userId,
    String gameId,
  ) async {
    try {
      final gameDataDoc =
          await _userGameDataCollection(userId).doc(gameId).get();

      if (!gameDataDoc.exists) {
        return DataError<UserGameDataModel>(
          error: AppError(error: 'Game data not found', code: '404'),
        );
      }

      return DataSuccess<UserGameDataModel>(
        data: UserGameDataModel.fromJson(gameDataDoc.data() ?? {}),
      );
    } catch (error) {
      return DataError<UserGameDataModel>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<List<UserGameDataModel>>> getUserGameDataInRange(
    String userId,
    String startDateId,
    String endDateId,
  ) async {
    try {
      final snapshot = await _userGameDataCollection(userId)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDateId)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endDateId)
          .get();

      final gameDataList = snapshot.docs.map((document) {
        final data = Map<String, dynamic>.from(document.data());
        data.putIfAbsent('id', () => document.id);
        return UserGameDataModel.fromJson(data);
      }).toList();

      return DataSuccess<List<UserGameDataModel>>(data: gameDataList);
    } catch (error) {
      return DataError<List<UserGameDataModel>>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<bool>> markGameAsCompleted(
    String userId,
    String gameId,
    bool isCorrect,
  ) async {
    try {
      await _userGameDataCollection(userId).doc(gameId).update({
        'isCompleted': true,
        'isCorrect': isCorrect,
        'updatedDate': FieldValue.serverTimestamp(),
      });
      return DataSuccess<bool>(data: true);
    } catch (error) {
      return DataError<bool>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<bool>> removeGuessedWord(
    String userId,
    String gameId,
    String guessedWord,
  ) async {
    try {
      await _userGameDataCollection(userId).doc(gameId).update({
        'guessedWords': FieldValue.arrayRemove([guessedWord]),
        'updatedDate': FieldValue.serverTimestamp(),
      });
      return DataSuccess<bool>(data: true);
    } catch (error) {
      return DataError<bool>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<bool>> updateStreak(
    String userId,
    int streak,
    String lastStreakDate,
    int longestStreak,
    int completedGames,
    int totalGames,
  ) async {
    try {
      await _userGameStateCollection().doc(userId).update({
        'streak': streak,
        'lastStreakDate': lastStreakDate,
        'longestStreak': longestStreak,
        'completedGames': completedGames,
        'totalGames': totalGames,
        'updatedDate': FieldValue.serverTimestamp(),
      });
      return DataSuccess<bool>(data: true);
    } catch (error) {
      return DataError<bool>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<UserGameStateModel>> updateUserGameState(
    UserGameStateModel userGameState,
  ) async {
    try {
      await _userGameStateCollection()
          .doc(userGameState.id)
          .update(userGameState.toJson());
      return DataSuccess<UserGameStateModel>(data: userGameState);
    } catch (error) {
      return DataError<UserGameStateModel>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<UserGameDataModel>> updateUserSpecificGameData(
    String userId,
    UserGameDataModel userGameData,
  ) async {
    try {
      await _userGameDataCollection(userId)
          .doc(userGameData.id)
          .update(userGameData.toJson());
      return DataSuccess<UserGameDataModel>(data: userGameData);
    } catch (error) {
      return DataError<UserGameDataModel>(
        error: AppError(error: error.toString(), code: '500'),
      );
    }
  }
}
