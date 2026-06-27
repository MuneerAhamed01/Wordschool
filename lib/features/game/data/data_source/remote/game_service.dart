import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/core/utils/valid_words.dart';
import 'package:wordshool/features/game/data/data_source/game_service.dart';
import 'package:wordshool/features/game/data/models/game.dart';

class GameDataSourceImpl extends GameDataSource {
  final FirebaseFirestore _firestore;
  final ValidWords _validWords;

  GameDataSourceImpl({
    required FirebaseFirestore firestore,
    required ValidWords validWords,
  })  : _firestore = firestore,
        _validWords = validWords;

  @override
  Future<DataState<GameModel>> loadTodayWord() async {
    return loadGameByDate(DateHelper.todayDateId());
  }

  @override
  Future<DataState<GameModel>> loadGameByDate(String dateId) async {
    try {
      if (!DateHelper.isValidDateId(dateId)) {
        return DataError<GameModel>(
          error: AppError.validation(
            message: 'Invalid date format',
            error: 'Invalid date format',
          ),
        );
      }

      if (DateHelper.isFutureDateId(dateId)) {
        return DataError<GameModel>(
          error: AppError.validation(
            message: 'Future games are not available',
            error: 'Future games are not available',
          ),
        );
      }

      final response = await _firestore
          .collection(FirebaseCollections.games)
          .doc(dateId)
          .get();

      if (!response.exists) {
        if (dateId == DateHelper.todayDateId() ||
            !DateHelper.isFutureDateId(dateId)) {
          final gameModel = await _createGameForDate(dateId);
          return DataSuccess<GameModel>(data: gameModel);
        }

        return DataError<GameModel>(
          error: AppError.notFound(
            message: 'Game not found for $dateId',
            error: 'Game not found for $dateId',
          ),
        );
      }

      final gameDoc = response.data();
      if (gameDoc == null) {
        return DataError<GameModel>(
          error: AppError.notFound(
            message: 'Game not found',
            error: 'Game not found',
          ),
        );
      }

      return DataSuccess<GameModel>(data: GameModel.fromJson(gameDoc));
    } catch (error, stackTrace) {
      return DataError<GameModel>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'GameDataSource.loadGameByDate',
      );
    }
  }

  @override
  Future<DataState<bool>> submitWord(String word) async {
    return DataSuccess(data: true);
  }

  Future<GameModel> _createGameForDate(String dateId) async {
    await _validWords.loadWords();

    final wordIndex = dateId.hashCode.abs() % _validWords.answerWords.length;
    final randomWord = _validWords.answerWords[wordIndex];

    final gameModel = GameModel(
      id: dateId,
      todayWord: randomWord,
      isCompleted: false,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
    );

    await _firestore
        .collection(FirebaseCollections.games)
        .doc(dateId)
        .set(gameModel.toJson());

    return gameModel;
  }
}
