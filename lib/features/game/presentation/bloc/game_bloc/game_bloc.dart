import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/game/domain/usecase/load_today_word.dart';

part 'game_event.dart';
part 'game_state.dart';
part 'game_bloc.freezed.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final LoadTodayWordUseCase _loadTodayWordUseCase;

  GameBloc({required LoadTodayWordUseCase loadTodayWordUseCase})
      : _loadTodayWordUseCase = loadTodayWordUseCase,
        super(const GameState.initial()) {
    on<_LoadTodayWord>(_onLoadTodayWord);
    on<_SubmitWord>(_onSubmitWord);

    add(_LoadTodayWord());
  }

  Future<void> _onLoadTodayWord(
      _LoadTodayWord event, Emitter<GameState> emit) async {
    emit(const GameState.loading());
    final result = await _loadTodayWordUseCase();

    if (result is DataSuccess) {
      emit(GameState.loaded(result.data!.todayWord));
    } else {
      emit(GameState.error(result.error?.message ?? 'Something went wrong'));
    }
  }

  Future<void> _onSubmitWord(_SubmitWord event, Emitter<GameState> emit) async {
    emit(const GameState.loading());
    // final result = await _submitWordUseCase(event.word);
    // emit(GameState.loaded(result));
  }
}
