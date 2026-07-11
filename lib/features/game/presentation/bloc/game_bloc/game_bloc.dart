import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/enums/game_mode.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/game/domain/usecase/load_game_by_date.dart';
import 'package:wordshool/features/game/presentation/utils/game_load_config.dart';
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
  final LoadGameByDateUseCase _loadGameByDateUseCase;
  final LoadUserGameStateUseCase _loadUserGameStateUseCase;
  final LoadUserSpecificGameStateUseCase _loadUserSpecificGameStateUseCase;
  final AddGuessedWordUseCase _addGuessedWordUseCase;
  final MarkGameCompletedUseCase _markGameCompletedUseCase;
  final GameLoadConfig _loadConfig;

  GameBloc({
    required LoadGameByDateUseCase loadGameByDateUseCase,
    required LoadUserGameStateUseCase loadUserGameStateUseCase,
    required LoadUserSpecificGameStateUseCase loadUserSpecificGameStateUseCase,
    required AddGuessedWordUseCase addGuessedWordUseCase,
    required MarkGameCompletedUseCase markGameCompletedUseCase,
    required GameLoadConfig loadConfig,
  })  : _loadGameByDateUseCase = loadGameByDateUseCase,
        _loadUserGameStateUseCase = loadUserGameStateUseCase,
        _loadUserSpecificGameStateUseCase = loadUserSpecificGameStateUseCase,
        _addGuessedWordUseCase = addGuessedWordUseCase,
        _markGameCompletedUseCase = markGameCompletedUseCase,
        _loadConfig = loadConfig,
        super(const GameState.initial()) {
    on<_LoadGame>(_onLoadGame);
    on<_SubmitWord>(_onSubmitWord);
    on<_LoadUserGameState>(_onLoadUserGameState);
    on<_LoadUserSpecificGameData>(_onLoadUserSpecificGameData);
    on<_AddGuessedWord>(_onAddGuessedWord);
    on<_MarkGameCompleted>(_onMarkGameCompleted);
    add(const _LoadGame());
  }

  Future<void> _onLoadGame(_LoadGame event, Emitter<GameState> emit) async {
    emit(const GameState.loading());

    final result =
        await _loadGameByDateUseCase(param: _loadConfig.gameDateId);

    if (result is DataSuccess) {
      emit(
        GameState.loaded(
          todayWord: result.data!.todayWord,
          gameDateId: result.data!.id,
          gameMode: _loadConfig.gameMode,
        ),
      );
      add(const _LoadUserGameState());
      add(_LoadUserSpecificGameData(result.data!.id));
    } else {
      emit(GameState.error(result.error?.message ?? 'Something went wrong'));
    }
  }

  Future<void> _onSubmitWord(_SubmitWord event, Emitter<GameState> emit) async {
    emit(const GameState.loading());
  }

  Future<void> _onLoadUserGameState(
    _LoadUserGameState event,
    Emitter<GameState> emit,
  ) async {
    final result = await _loadUserGameStateUseCase();
    if (result is DataSuccess) {
      emit(
        state.maybeMap(
          loaded: (loadedState) =>
              loadedState.copyWith(userGameState: result.data!),
          orElse: () => state,
        ),
      );
    } else {
      emit(GameState.error(result.error?.message ?? 'Something went wrong'));
    }
  }

  Future<void> _onLoadUserSpecificGameData(
    _LoadUserSpecificGameData event,
    Emitter<GameState> emit,
  ) async {
    final result =
        await _loadUserSpecificGameStateUseCase(param: event.gameId);
    if (result is DataSuccess) {
      emit(
        state.maybeMap(
          loaded: (loadedState) =>
              loadedState.copyWith(userSpecificGameData: result.data!),
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
    if (state.isGameAlreadyCompleted) return;

    await _addGuessedWordUseCase(
      param: AddGuessedWordParam(
        gameId: state.userSpecificGameData!.id,
        guessedWord: event.word,
      ),
    );
  }

  Future<void> _onMarkGameCompleted(
    _MarkGameCompleted event,
    Emitter<GameState> emit,
  ) async {
    if (state.isGameAlreadyCompleted) return;

    await _markGameCompletedUseCase(
      param: MarkGameCompletedParam(
        gameId: state.userSpecificGameData!.id,
        isCorrect: event.isCorrect,
        isArchiveMode: state.isArchiveMode,
      ),
    );

    final gameId = state.userSpecificGameData!.id;
    final userStateResult = await _loadUserGameStateUseCase();
    final gameDataResult =
        await _loadUserSpecificGameStateUseCase(param: gameId);

    emit(
      state.maybeMap(
        loaded: (loadedState) => loadedState.copyWith(
          userGameState: userStateResult is DataSuccess
              ? userStateResult.data!
              : loadedState.userGameState,
          userSpecificGameData: gameDataResult is DataSuccess
              ? gameDataResult.data!
              : loadedState.userSpecificGameData,
        ),
        orElse: () => state,
      ),
    );
  }
}
