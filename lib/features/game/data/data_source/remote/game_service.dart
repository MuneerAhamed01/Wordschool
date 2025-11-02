import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/valid_words.dart';
import 'package:wordshool/features/game/data/data_source/game_service.dart';
import 'package:wordshool/features/game/data/models/game.dart';

class GameDataSourceImpl extends GameDataSource {
  final FirebaseFirestore _firestore;
  final ValidWords _validWords;

  GameDataSourceImpl(
      {required FirebaseFirestore firestore, required ValidWords validWords})
      : _firestore = firestore,
        _validWords = validWords;

  @override
  Future<DataState<GameModel>> loadTodayWord() async {
    try {
      final todayDate = DateTime.now().toIso8601String().split('T')[0];

      final response = await _firestore
          .collection(FirebaseCollections.games)
          .doc(todayDate)
          .get();

      if (!response.exists) {
        // No existing game, create new one
        final gameModel = await _createWordIfNotExist();
        return DataSuccess<GameModel>(data: gameModel);
      }

      final gameDoc = response.data();
      if (gameDoc == null) {
        return DataError<GameModel>(
          error: AppError(error: 'Game not found', code: '404'),
        );
      }
      return DataSuccess<GameModel>(data: GameModel.fromJson(gameDoc));
    } catch (e) {
      return DataError<GameModel>(
        error: AppError(error: e.toString(), code: '500'),
      );
    }
  }

  @override
  Future<DataState<bool>> submitWord(String word) async {
    return DataSuccess(data: true);
  }

  Future<GameModel> _createWordIfNotExist() async {
    try {
      await _validWords.loadWords();

      final randomWord = _validWords.validWords[
          DateTime.now().millisecondsSinceEpoch %
              _validWords.validWords.length];

      // CREATE ID BASED ON THE CURRENT DATE AND TIME
      final todayDate = DateTime.now().toIso8601String().split('T')[0];

      final gameModel = GameModel(
        id: todayDate,
        todayWord: randomWord,
        isCompleted: false,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseCollections.games)
          .doc(todayDate)
          .set(gameModel.toJson());

      return gameModel;
    } catch (e) {
      throw Exception('Failed to create new word: ${e.toString()}');
    }
  }
}
