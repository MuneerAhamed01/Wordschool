import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/data/data_source/user_game_state_service.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';

/// Live monetization entitlements loaded from the signed-in user's game state.
class StoryEntitlementsService {
  StoryEntitlementsService({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UserGameStateDataSource userGameStateDataSource,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _userGameStateDataSource = userGameStateDataSource;

  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UserGameStateDataSource _userGameStateDataSource;

  UserGameStateEntity? _state;

  bool get hasRemoveAds => _state?.hasRemoveAds ?? false;

  bool get isDetectivePro => _state?.isDetectivePro ?? false;

  bool get shouldHideAds => hasRemoveAds || isDetectivePro;

  int get hintPackBalance => _state?.hintPackBalance ?? 0;

  bool get hasHintAllowance => isDetectivePro || hintPackBalance > 0;

  UserGameStateEntity? get currentState => _state;

  void updateFrom(UserGameStateEntity state) {
    _state = state;
  }

  Future<void> refresh() async {
    final user = await _getCurrentUserUseCase();
    if (user == null) {
      _state = null;
      return;
    }

    final result = await _userGameStateDataSource.getUserGameState(user.id);
    if (result is DataSuccess<UserGameStateEntity>) {
      _state = result.data;
    }
  }
}
