import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_event.dart';
part 'game_state.dart';
part 'game_bloc.freezed.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(const GameState.initial()) {
    on<_LoadTodayWord>(_onLoadTodayWord);
    on<_SubmitWord>(_onSubmitWord);
  }

  Future<void> _onLoadTodayWord(
      _LoadTodayWord event, Emitter<GameState> emit) async {
    emit(const GameState.loading());
    // final todayWord = await _loadTodayWordUseCase();
    // emit(GameState.loaded(todayWord));
  }

  Future<void> _onSubmitWord(_SubmitWord event, Emitter<GameState> emit) async {
    emit(const GameState.loading());
    // final result = await _submitWordUseCase(event.word);
    // emit(GameState.loaded(result));
  }
}
