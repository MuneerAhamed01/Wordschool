part of 'game_bloc.dart';

@freezed
class GameEvent with _$GameEvent {
  const factory GameEvent.loadTodayWord() = _LoadTodayWord;
  const factory GameEvent.loadUserGameState() = _LoadUserGameState;
  const factory GameEvent.loadUserSpecificGameData(String gameId) = _LoadUserSpecificGameData;
  const factory GameEvent.addGuessedWord(String word) = _AddGuessedWord;
  const factory GameEvent.removeGuessedWord(String word) = _RemoveGuessedWord;
  const factory GameEvent.markGameCompleted(bool isCorrect) = _MarkGameCompleted;
  const factory GameEvent.submitWord(String word) = _SubmitWord;
}
