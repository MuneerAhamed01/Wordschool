import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/game/data/models/game.dart';

abstract class GameDataSource {
  Future<DataState<GameModel>> loadTodayWord();
  Future<DataState<bool>> submitWord(String word);
}
