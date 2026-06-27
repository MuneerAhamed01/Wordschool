import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';
import 'package:wordshool/features/story_mode/domain/usecases/utils/save_clue_guess_param.dart';

class SaveClueGuessUseCase
    extends UseCase<DataState<StoryModeProgressEntity>, SaveClueGuessParam> {
  SaveClueGuessUseCase({required StoryCaseRepository storyCaseRepository})
      : _storyCaseRepository = storyCaseRepository;

  final StoryCaseRepository _storyCaseRepository;

  @override
  Future<DataState<StoryModeProgressEntity>> call({
    required SaveClueGuessParam param,
  }) {
    return _storyCaseRepository.saveClueGuess(
      userId: param.userId,
      caseId: param.caseId,
      clueIndex: param.clueIndex,
      guess: param.guess,
    );
  }
}
