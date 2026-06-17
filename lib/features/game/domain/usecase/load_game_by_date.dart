import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/game/domain/entities/game.dart';
import 'package:wordshool/features/game/domain/repositories/game_repository.dart';

class LoadGameByDateUseCase extends UseCase<DataState<GameEntity>, String> {
  final GameRepository _gameRepository;

  LoadGameByDateUseCase({required GameRepository gameRepository})
      : _gameRepository = gameRepository;

  @override
  Future<DataState<GameEntity>> call({required String param}) async {
    return _gameRepository.loadGameByDate(param);
  }
}
