part of 'game_bloc.dart';

@freezed
class GameState with _$GameState {
  const factory GameState.initial() = _Initial;
  const factory GameState.loading() = _Loading;
  const factory GameState.loaded({
    required String todayWord,
    UserGameStateEntity? userGameState,
    UserGameDataEntity? userSpecificGameData,
  }) = _Loaded;
  const factory GameState.error(String message) = _Error;
}

extension GameStateX on GameState {
  String get todayWord =>
      whenOrNull(
        loaded: (todayWord, userGameState, userSpecificGameData) => todayWord,
      ) ??
      '';
  UserGameStateEntity? get userGameState => whenOrNull(
        loaded: (todayWord, userGameState, userSpecificGameData) =>
            userGameState,
      );
  UserGameDataEntity? get userSpecificGameData => whenOrNull(
        loaded: (todayWord, userGameState, userSpecificGameData) =>
            userSpecificGameData,
      );
}
