part of 'dashboard_bloc.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = _Initial;
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.loaded({
    required UserGameStateEntity userGameState,
    UserGameDataEntity? todayGameData,
  }) = _Loaded;
  const factory DashboardState.error(String message) = _Error;
}
