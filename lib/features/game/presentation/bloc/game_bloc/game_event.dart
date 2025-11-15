part of 'game_bloc.dart';

@freezed
class GameEvent with _$GameEvent {
  const factory GameEvent.loadTodayWord() = _LoadTodayWord;
  const factory GameEvent.loadUserGameState() = _LoadUserGameState;
  const factory GameEvent.loadUserSpecificGameData(String gameId) = _LoadUserSpecificGameData;
  const factory GameEvent.submitWord(String word) = _SubmitWord;
}
