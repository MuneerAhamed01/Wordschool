import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/monetization/story_entitlements.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/usercases/load_user_game_state_usecase.dart';
import 'package:wordshool/shared/domains/usercases/load_user_specific_game_state.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';
part 'dashboard_bloc.freezed.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final LoadUserGameStateUseCase _loadUserGameStateUseCase;
  final LoadUserSpecificGameStateUseCase _loadUserSpecificGameStateUseCase;

  DashboardBloc({
    required LoadUserGameStateUseCase loadUserGameStateUseCase,
    required LoadUserSpecificGameStateUseCase loadUserSpecificGameStateUseCase,
  })  : _loadUserGameStateUseCase = loadUserGameStateUseCase,
        _loadUserSpecificGameStateUseCase = loadUserSpecificGameStateUseCase,
        super(const DashboardState.initial()) {
    on<LoadDashboard>(_onLoadDashboard);
    add(const DashboardEvent.loadDashboard());
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    final showLoading =
        state.whenOrNull(loaded: (_, __) => true) != true;

    if (showLoading) {
      emit(const DashboardState.loading());
    }

    final todayId = DateHelper.todayDateId();
    final userStateResult = await _loadUserGameStateUseCase();
    final todayGameResult =
        await _loadUserSpecificGameStateUseCase(param: todayId);

    if (userStateResult is DataSuccess<UserGameStateEntity>) {
      if (getIt.isRegistered<StoryEntitlementsService>()) {
        getIt<StoryEntitlementsService>()
            .updateFrom(userStateResult.data!);
      }

      final todayGame = todayGameResult is DataSuccess<UserGameDataEntity>
          ? todayGameResult.data
          : null;
      emit(DashboardState.loaded(
        userGameState: userStateResult.data!,
        todayGameData: todayGame,
      ));
    } else if (showLoading) {
      emit(DashboardState.error(
        userStateResult.error?.message ?? 'Failed to load dashboard',
      ));
    }
  }
}
