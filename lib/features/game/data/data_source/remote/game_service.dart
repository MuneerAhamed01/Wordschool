import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/game/data/data_source/game_service.dart';
import 'package:wordshool/features/game/data/models/game.dart';

class GameDataSourceImpl extends GameDataSource {
  final FirebaseFirestore _firestore;

  GameDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<DataState<GameModel>> loadTodayWord() async {
    try {
      final response = await _firestore
          .collection(FirebaseCollections.games)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (response.docs.isEmpty) {
        return DataError<GameModel>(
          error: AppError(error: 'No game found', code: '404'),
        );
      }

      final gameDoc = response.docs.first;

      return DataSuccess<GameModel>(data: GameModel.fromJson(gameDoc.data()));
    } catch (e) {
      return DataError<GameModel>(
          error: AppError(error: e.toString(), code: '500'));
    }
  }

  @override
  Future<DataState<bool>> submitWord(String word) async {
    return DataSuccess(data: true);
  }
}
