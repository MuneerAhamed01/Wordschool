import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';
import 'package:wordshool/features/story_mode/domain/usecases/utils/complete_story_case_param.dart';

class CompleteStoryCaseUseCase
    extends UseCase<DataState<StoryModeProgressEntity>, CompleteStoryCaseParam> {
  CompleteStoryCaseUseCase({required StoryCaseRepository storyCaseRepository})
      : _storyCaseRepository = storyCaseRepository;

  final StoryCaseRepository _storyCaseRepository;

  @override
  Future<DataState<StoryModeProgressEntity>> call({
    required CompleteStoryCaseParam param,
  }) {
    return _storyCaseRepository.completeStoryCase(
      userId: param.userId,
      caseId: param.caseId,
    );
  }
}
