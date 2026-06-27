import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';
import 'package:wordshool/features/story_mode/domain/usecases/today_detective_case_result.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';

class LoadTodayDetectiveCaseUseCase
    extends UseCase<DataState<TodayDetectiveCaseResult>, void> {
  LoadTodayDetectiveCaseUseCase({
    required StoryCaseRepository storyCaseRepository,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _storyCaseRepository = storyCaseRepository,
        _getCurrentUserUseCase = getCurrentUserUseCase;

  final StoryCaseRepository _storyCaseRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  @override
  Future<DataState<TodayDetectiveCaseResult>> call({void param}) async {
    final caseResult = await _storyCaseRepository.getTodayCase();

    if (caseResult is! DataSuccess) {
      return DataError<TodayDetectiveCaseResult>(error: caseResult.error);
    }

    final currentUser = await _getCurrentUserUseCase();
    final progress = currentUser == null
        ? null
        : await _storyCaseRepository.getTodayProgress(currentUser.id);

    return DataSuccess<TodayDetectiveCaseResult>(
      data: TodayDetectiveCaseResult(
        detectiveCase: caseResult.data!,
        progress: progress,
      ),
    );
  }
}
