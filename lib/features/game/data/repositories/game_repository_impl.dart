import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/game/data/data_source/game_service.dart';
import 'package:wordshool/features/game/data/models/game.dart';
import 'package:wordshool/features/game/domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final GameDataSource _gameDataSource;

  GameRepositoryImpl({required GameDataSource gameDataSource})
      : _gameDataSource = gameDataSource;

  @override
  Future<DataState<GameModel>> loadTodayWord() {
    return _gameDataSource.loadTodayWord();
  }

  @override
  Future<DataState<bool>> submitWord(String word) {
    return _gameDataSource.submitWord(word);
  }
}
