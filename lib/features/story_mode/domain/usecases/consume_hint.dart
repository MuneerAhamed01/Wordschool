import 'package:wordshool/core/monetization/story_entitlements.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/shared/data/data_source/user_game_state_service.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';

enum HintConsumptionSource { hintPack, detectivePro, rewardedAd }

class ConsumeHintResult {
  const ConsumeHintResult({
    required this.consumed,
    this.source,
  });

  final bool consumed;
  final HintConsumptionSource? source;
}

class ConsumeHintUseCase extends UseCase<DataState<ConsumeHintResult>, void> {
  ConsumeHintUseCase({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UserGameStateDataSource userGameStateDataSource,
    StoryEntitlementsService? entitlementsService,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _userGameStateDataSource = userGameStateDataSource,
        _entitlementsService = entitlementsService;

  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UserGameStateDataSource _userGameStateDataSource;
  final StoryEntitlementsService? _entitlementsService;

  @override
  Future<DataState<ConsumeHintResult>> call({void param}) async {
    final user = await _getCurrentUserUseCase();
    if (user == null) {
      return DataError(
        error: AppError.validation(message: 'Sign in to use hints'),
      );
    }

    final stateResult =
        await _userGameStateDataSource.getUserGameState(user.id);
    if (stateResult is! DataSuccess) {
      return DataError(error: stateResult.error);
    }

    final state = stateResult.data!;
    if (state.isDetectivePro) {
      return DataSuccess(
        data: const ConsumeHintResult(
          consumed: true,
          source: HintConsumptionSource.detectivePro,
        ),
      );
    }

    if (state.hintPackBalance > 0) {
      await _userGameStateDataSource.updateHintPackBalance(
        user.id,
        state.hintPackBalance - 1,
      );
      await _entitlementsService?.refresh();
      return DataSuccess(
        data: const ConsumeHintResult(
          consumed: true,
          source: HintConsumptionSource.hintPack,
        ),
      );
    }

    return DataSuccess(
      data: const ConsumeHintResult(consumed: false),
    );
  }
}
