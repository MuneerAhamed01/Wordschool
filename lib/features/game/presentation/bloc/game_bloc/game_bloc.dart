import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/game/domain/usecase/load_today_word.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/usercases/guessed_word_usecase/add_guessed_word_usecase.dart';
import 'package:wordshool/shared/domains/usercases/guessed_word_usecase/utils/add_guessed_word_param.dart';
import 'package:wordshool/shared/domains/usercases/load_user_game_state_usecase.dart';
import 'package:wordshool/shared/domains/usercases/load_user_specific_game_state.dart';
import 'package:wordshool/shared/domains/usercases/mark_game_usecase/mark_game_completed_usecase.dart';
import 'package:wordshool/shared/domains/usercases/mark_game_usecase/utils/mark_game_completed_params.dart';

part 'game_event.dart';
part 'game_state.dart';
part 'game_bloc.freezed.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final LoadTodayWordUseCase _loadTodayWordUseCase;

  final LoadUserGameStateUseCase _loadUserGameStateUseCase;

  final LoadUserSpecificGameStateUseCase _loadUserSpecificGameStateUseCase;

  final AddGuessedWordUseCase _addGuessedWordUseCase;

  final MarkGameCompletedUseCase _markGameCompletedUseCase;

  GameBloc({
    required LoadTodayWordUseCase loadTodayWordUseCase,
    required LoadUserGameStateUseCase loadUserGameStateUseCase,
    required LoadUserSpecificGameStateUseCase loadUserSpecificGameStateUseCase,
    required AddGuessedWordUseCase addGuessedWordUseCase,
    required MarkGameCompletedUseCase markGameCompletedUseCase,
  })  : _loadTodayWordUseCase = loadTodayWordUseCase,
        _loadUserGameStateUseCase = loadUserGameStateUseCase,
        _loadUserSpecificGameStateUseCase = loadUserSpecificGameStateUseCase,
        _addGuessedWordUseCase = addGuessedWordUseCase,
        _markGameCompletedUseCase = markGameCompletedUseCase,
        super(const GameState.initial()) {
    on<_LoadTodayWord>(_onLoadTodayWord);
    on<_SubmitWord>(_onSubmitWord);
    on<_LoadUserGameState>(_onLoadUserGameState);
    on<_LoadUserSpecificGameData>(_onLoadUserSpecificGameData);
    on<_AddGuessedWord>(_onAddGuessedWord);
    on<_MarkGameCompleted>(_onMarkGameCompleted);
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
    final result = await _loadUserGameStateUseCase();
    if (result is DataSuccess) {
      emit(state.maybeMap(
          loaded: (state) => state.copyWith(userGameState: result.data!),
          orElse: () => state));
    } else {
      emit(GameState.error(result.error?.message ?? 'Something went wrong'));
    }
  }

  Future<void> _onLoadUserSpecificGameData(
    _LoadUserSpecificGameData event,
    Emitter<GameState> emit,
  ) async {
    final result = await _loadUserSpecificGameStateUseCase(param: event.gameId);
    if (result is DataSuccess) {
      emit(
        state.maybeMap(
          loaded: (state) => state.copyWith(userSpecificGameData: result.data!),
          orElse: () => state,
        ),
      );
    } else {
      emit(GameState.error(result.error?.message ?? 'Something went wrong'));
    }
  }

  Future<void> _onAddGuessedWord(
    _AddGuessedWord event,
    Emitter<GameState> emit,
  ) async {
    _addGuessedWordUseCase(
      param: AddGuessedWordParam(
        gameId: state.userSpecificGameData!.id,
        guessedWord: event.word,
      ),
    );
  }

  /// TODO: IF THIS IS NOT REFLECTING ON THE UI WE CAN HANDLE IT IN CLOUD FUNCTIONS
  Future<void> _onMarkGameCompleted(
    _MarkGameCompleted event,
    Emitter<GameState> emit,
  ) async {
    await _markGameCompletedUseCase(
      param: MarkGameCompletedParam(
        gameId: state.userSpecificGameData!.id,
        isCorrect: event.isCorrect,
      ),
    );
  }
}
