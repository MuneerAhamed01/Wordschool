import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/game/presentation/utils/constants.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/presentation/analytics/story_analytics.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_audio_manager.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/story_mode/domain/usecases/complete_story_case.dart';
import 'package:wordshool/features/story_mode/domain/usecases/complete_story_clue.dart';
import 'package:wordshool/features/story_mode/domain/usecases/save_clue_guess.dart';
import 'package:wordshool/features/story_mode/domain/usecases/utils/complete_story_case_param.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/domain/usecases/utils/complete_story_clue_param.dart';
import 'package:wordshool/features/story_mode/domain/usecases/utils/save_clue_guess_param.dart';

sealed class StoryClueEvent {
  const StoryClueEvent();
}

final class InitializeClue extends StoryClueEvent {
  const InitializeClue({
    required this.clueIndex,
    required this.caseId,
    required this.answer,
    required this.userId,
    this.progress,
  });

  final int clueIndex;
  final String caseId;
  final String answer;
  final String userId;
  final StoryModeProgressEntity? progress;
}

final class SubmitGuess extends StoryClueEvent {
  const SubmitGuess(this.word);

  final String word;
}

final class CompleteClue extends StoryClueEvent {
  const CompleteClue({required this.solved});

  final bool solved;
}

sealed class StoryClueState {
  const StoryClueState();

  T maybeWhen<T>({
    T Function()? initial,
    T Function(
      int clueIndex,
      String caseId,
      String answer,
      String userId,
      StoryModeProgressEntity? progress,
      bool isCompleted,
    )? ready,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return switch (this) {
      StoryClueInitial() => initial?.call() ?? orElse(),
      StoryClueReady(
        :final clueIndex,
        :final caseId,
        :final answer,
        :final userId,
        :final progress,
        :final isCompleted,
      ) =>
        ready?.call(
              clueIndex,
              caseId,
              answer,
              userId,
              progress,
              isCompleted,
            ) ??
            orElse(),
      StoryClueError(:final message) => error?.call(message) ?? orElse(),
    };
  }
}

final class StoryClueInitial extends StoryClueState {
  const StoryClueInitial();
}

final class StoryClueReady extends StoryClueState {
  const StoryClueReady({
    required this.clueIndex,
    required this.caseId,
    required this.answer,
    required this.userId,
    this.progress,
    this.isCompleted = false,
  });

  final int clueIndex;
  final String caseId;
  final String answer;
  final String userId;
  final StoryModeProgressEntity? progress;
  final bool isCompleted;

  int get attemptCount {
    final attempts = progress?.clueAttempts.elementAtOrNull(clueIndex);
    return attempts ?? 0;
  }

  List<String> get savedGuesses {
    return progress?.clueGuesses.elementAtOrNull(clueIndex) ?? const [];
  }

  bool get isClueFinished {
    if (isCompleted) return true;
    final progress = this.progress;
    if (progress == null) return false;
    if (clueIndex < progress.currentClueIndex) return true;
    return progress.clueSolved.elementAtOrNull(clueIndex) ?? false;
  }

  StoryClueReady copyWith({
    StoryModeProgressEntity? progress,
    bool? isCompleted,
  }) {
    return StoryClueReady(
      clueIndex: clueIndex,
      caseId: caseId,
      answer: answer,
      userId: userId,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

final class StoryClueError extends StoryClueState {
  const StoryClueError(this.message);

  final String message;
}

class StoryClueBloc extends Bloc<StoryClueEvent, StoryClueState> {
  StoryClueBloc({
    required SaveClueGuessUseCase saveClueGuessUseCase,
    required CompleteStoryClueUseCase completeStoryClueUseCase,
    required CompleteStoryCaseUseCase completeStoryCaseUseCase,
  })  : _saveClueGuessUseCase = saveClueGuessUseCase,
        _completeStoryClueUseCase = completeStoryClueUseCase,
        _completeStoryCaseUseCase = completeStoryCaseUseCase,
        super(const StoryClueInitial()) {
    on<InitializeClue>(_onInitializeClue);
    on<SubmitGuess>(_onSubmitGuess);
    on<CompleteClue>(_onCompleteClue);
  }

  final SaveClueGuessUseCase _saveClueGuessUseCase;
  final CompleteStoryClueUseCase _completeStoryClueUseCase;
  final CompleteStoryCaseUseCase _completeStoryCaseUseCase;

  void _onInitializeClue(InitializeClue event, Emitter<StoryClueState> emit) {
    emit(
      StoryClueReady(
        clueIndex: event.clueIndex,
        caseId: event.caseId,
        answer: event.answer.trim().toUpperCase(),
        userId: event.userId,
        progress: event.progress,
        isCompleted: _isClueFinishedFromProgress(
          clueIndex: event.clueIndex,
          progress: event.progress,
        ),
      ),
    );

    if (!_isClueFinishedFromProgress(
      clueIndex: event.clueIndex,
      progress: event.progress,
    )) {
      StoryAnalytics.clueStarted(clueIndex: event.clueIndex);
    }
  }

  Future<void> _onSubmitGuess(
    SubmitGuess event,
    Emitter<StoryClueState> emit,
  ) async {
    final current = state;
    if (current is! StoryClueReady || current.isClueFinished) {
      return;
    }

    if (current.attemptCount >= GameConstants.maxWords) {
      return;
    }

    final result = await _saveClueGuessUseCase(
      param: SaveClueGuessParam(
        userId: current.userId,
        caseId: current.caseId,
        clueIndex: current.clueIndex,
        guess: event.word,
      ),
    );

    if (result is DataSuccess<StoryModeProgressEntity>) {
      emit(current.copyWith(progress: result.data));
      return;
    }

    emit(
      StoryClueError(
        result.error?.message ?? 'Failed to save guess',
      ),
    );
  }

  Future<void> _onCompleteClue(
    CompleteClue event,
    Emitter<StoryClueState> emit,
  ) async {
    final current = state;
    if (current is! StoryClueReady || current.isClueFinished) {
      return;
    }

    final result = await _completeStoryClueUseCase(
      param: CompleteStoryClueParam(
        userId: current.userId,
        caseId: current.caseId,
        clueIndex: current.clueIndex,
        solved: event.solved,
      ),
    );

    if (result is DataSuccess<StoryModeProgressEntity>) {
      var progress = result.data!;

      if (current.clueIndex == StoryFlowGating.maxClueIndex) {
        final caseResult = await _completeStoryCaseUseCase(
          param: CompleteStoryCaseParam(
            userId: current.userId,
            caseId: current.caseId,
          ),
        );

        if (caseResult is DataSuccess<StoryModeProgressEntity>) {
          progress = caseResult.data!;
        }
      }

      emit(
        current.copyWith(
          progress: progress,
          isCompleted: true,
        ),
      );

      if (event.solved) {
        StoryAnalytics.clueSolved(
          clueIndex: current.clueIndex,
          attempts: progress.clueAttempts[current.clueIndex],
        );
        if (getIt.isRegistered<StoryAudioManager>()) {
          unawaited(getIt<StoryAudioManager>().playWin());
        }
      } else {
        StoryAnalytics.clueFailed(clueIndex: current.clueIndex);
        if (getIt.isRegistered<StoryAudioManager>()) {
          unawaited(getIt<StoryAudioManager>().playFail());
        }
      }
      return;
    }

    emit(
      StoryClueError(
        result.error?.message ?? 'Failed to complete clue',
      ),
    );
  }

  static bool _isClueFinishedFromProgress({
    required int clueIndex,
    StoryModeProgressEntity? progress,
  }) {
    if (progress == null) return false;
    if (clueIndex < progress.currentClueIndex) return true;
    return progress.clueSolved.elementAtOrNull(clueIndex) ?? false;
  }
}
