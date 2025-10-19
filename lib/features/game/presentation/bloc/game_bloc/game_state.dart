part of 'game_bloc.dart';

@freezed
class GameState with _$GameState {
  const factory GameState.initial() = _Initial;
  const factory GameState.loading() = _Loading;
  const factory GameState.loaded(String todayWord) = _Loaded;
  const factory GameState.error(String message) = _Error;
}
