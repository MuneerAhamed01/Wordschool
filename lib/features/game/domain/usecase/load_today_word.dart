import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/game/domain/entities/game.dart';
import 'package:wordshool/features/game/domain/repositories/game_repository.dart';

class LoadTodayWordUseCase extends UseCase<DataState<GameEntity>, Null> {
  final GameRepository _gameRepository;

  LoadTodayWordUseCase({required GameRepository gameRepository})
      : _gameRepository = gameRepository;

  @override
  Future<DataState<GameEntity>> call({Null param}) async {
    return _gameRepository.loadTodayWord();
  }
}
