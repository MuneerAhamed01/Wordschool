part of 'game_bloc.dart';

@freezed
class GameState with _$GameState {
  const factory GameState.initial() = _Initial;
  const factory GameState.loading() = _Loading;
  const factory GameState.loaded({
    required String todayWord,
    required String gameDateId,
    required GameMode gameMode,
    UserGameStateEntity? userGameState,
    UserGameDataEntity? userSpecificGameData,
  }) = _Loaded;
  const factory GameState.error(String message) = _Error;
}

extension GameStateX on GameState {
  String get todayWord =>
      whenOrNull(
        loaded: (todayWord, gameDateId, gameMode, userGameState,
                userSpecificGameData) =>
            todayWord,
      ) ??
      '';

  String get gameDateId =>
      whenOrNull(
        loaded: (todayWord, gameDateId, gameMode, userGameState,
                userSpecificGameData) =>
            gameDateId,
      ) ??
      '';

  GameMode get gameMode =>
      whenOrNull(
        loaded: (todayWord, gameDateId, gameMode, userGameState,
                userSpecificGameData) =>
            gameMode,
      ) ??
      GameMode.daily;

  UserGameStateEntity? get userGameState => whenOrNull(
        loaded: (todayWord, gameDateId, gameMode, userGameState,
                userSpecificGameData) =>
            userGameState,
      );

  UserGameDataEntity? get userSpecificGameData => whenOrNull(
        loaded: (todayWord, gameDateId, gameMode, userGameState,
                userSpecificGameData) =>
            userSpecificGameData,
      );

  bool get isArchiveMode => gameMode == GameMode.archive;

  bool get isGameAlreadyCompleted =>
      userSpecificGameData?.isCompleted ?? false;
}
