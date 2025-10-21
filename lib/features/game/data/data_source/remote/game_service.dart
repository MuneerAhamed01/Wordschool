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
      final response = await _firestore
          .collection(FirebaseCollections.games)
          .orderBy('createdDate', descending: true)
          .limit(1)
          .get();

      if (response.docs.isEmpty) {
        // No existing game, create new one
        final gameModel = await _createWordIfNotExist();
        return DataSuccess<GameModel>(data: gameModel);
      }

      final gameDoc = response.docs.first;
      final gameData = gameDoc.data();
      final createdDate = (gameData['createdDate'] as Timestamp).toDate();
      final now = DateTime.now();

      // Check if game is from today
      final isToday = createdDate.year == now.year &&
          createdDate.month == now.month &&
          createdDate.day == now.day;

      if (isToday) {
        // Return existing game from today
        return DataSuccess<GameModel>(
          data: GameModel.fromJson(gameData),
        );
      } else {  
        // Create new game for today
        final gameModel = await _createWordIfNotExist();
        return DataSuccess<GameModel>(data: gameModel);
      }
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

      final gameModel = GameModel(
        todayWord: randomWord,
        isCompleted: false,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseCollections.games)
          .add(gameModel.toJson());

      return gameModel;
    } catch (e) {
      throw Exception('Failed to create new word: ${e.toString()}');
    }
  }
}
