import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/game/domain/entities/game.dart';

abstract class GameRepository {
  Future<DataState<GameEntity>> loadTodayWord();
  Future<DataState<bool>> submitWord(String word);
}
