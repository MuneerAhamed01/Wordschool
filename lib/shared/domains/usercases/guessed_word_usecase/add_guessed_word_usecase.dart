import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';
import 'package:wordshool/shared/domains/usercases/guessed_word_usecase/utils/add_guessed_word_param.dart';

class AddGuessedWordUseCase
    extends UseCase<DataState<bool>, AddGuessedWordParam> {
  final UserGameStateRepository _userGameStateRepository;

  AddGuessedWordUseCase(
      {required UserGameStateRepository userGameStateRepository})
      : _userGameStateRepository = userGameStateRepository;

  @override
  Future<DataState<bool>> call({required AddGuessedWordParam param}) async {
    return _userGameStateRepository.addGuessedWord(
      param.gameId,
      param.guessedWord,
    );
  }
}
