import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/game/domain/usecase/load_today_word.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/usercases/load_user_game_state_usecase.dart';
import 'package:wordshool/shared/domains/usercases/load_user_specific_game_state.dart';

part 'game_event.dart';
part 'game_state.dart';
part 'game_bloc.freezed.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final LoadTodayWordUseCase _loadTodayWordUseCase;

  final LoadUserGameStateUseCase _loadUserGameStateUseCase;

  final LoadUserSpecificGameStateUseCase _loadUserSpecificGameStateUseCase;

  GameBloc({
    required LoadTodayWordUseCase loadTodayWordUseCase,
    required LoadUserGameStateUseCase loadUserGameStateUseCase,
    required LoadUserSpecificGameStateUseCase loadUserSpecificGameStateUseCase,
  })  : _loadTodayWordUseCase = loadTodayWordUseCase,
        _loadUserGameStateUseCase = loadUserGameStateUseCase,
        _loadUserSpecificGameStateUseCase = loadUserSpecificGameStateUseCase,
        super(const GameState.initial()) {
    on<_LoadTodayWord>(_onLoadTodayWord);
    on<_SubmitWord>(_onSubmitWord);
    on<_LoadUserGameState>(_onLoadUserGameState);
    on<_LoadUserSpecificGameData>(_onLoadUserSpecificGameData);
    add(_LoadTodayWord());
  }

  Future<void> _onLoadTodayWord(
      _LoadTodayWord event, Emitter<GameState> emit) async {
    emit(const GameState.loading());
    final result = await _loadTodayWordUseCase();

    if (result is DataSuccess) {
      emit(GameState.loaded(todayWord: result.data!.todayWord));
      add(_LoadUserGameState());
      add(_LoadUserSpecificGameData(result.data!.id));
    } else {
      emit(GameState.error(result.error?.message ?? 'Something went wrong'));
    }
  }

  Future<void> _onSubmitWord(_SubmitWord event, Emitter<GameState> emit) async {
    emit(const GameState.loading());
    // final result = await _submitWordUseCase(event.word);
    // emit(GameState.loaded(result));
  }

  Future<void> _onLoadUserGameState(
    _LoadUserGameState event,
    Emitter<GameState> emit,
  ) async {
    emit(const GameState.loading());
    final result = await _loadUserGameStateUseCase();
    if (result is DataSuccess) {
      final todayWord = state.whenOrNull(
          loaded: (todayWord, userGameState, userSpecificGameData) =>
              todayWord);
      emit(
          GameState.loaded(todayWord: todayWord!, userGameState: result.data!));
    } else {
      emit(GameState.error(result.error?.message ?? 'Something went wrong'));
    }
  }

  Future<void> _onLoadUserSpecificGameData(
    _LoadUserSpecificGameData event,
    Emitter<GameState> emit,
  ) async {
    emit(const GameState.loading());
    final result = await _loadUserSpecificGameStateUseCase(param: event.gameId);
    if (result is DataSuccess) {
      emit(
        GameState.loaded(
          todayWord: state.todayWord,
          userGameState: state.userGameState,
          userSpecificGameData: result.data!,
        ),
      );
    } else {
      emit(GameState.error(result.error?.message ?? 'Something went wrong'));
    }
  }
}
