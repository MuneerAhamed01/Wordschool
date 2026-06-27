import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';

sealed class StoryFlowEvent {
  const StoryFlowEvent();
}

final class Initialize extends StoryFlowEvent {
  const Initialize({
    required this.detectiveCase,
    this.progress,
    required this.isReadOnly,
  });

  final DetectiveCaseEntity detectiveCase;
  final StoryModeProgressEntity? progress;
  final bool isReadOnly;
}

final class MarkClueResolved extends StoryFlowEvent {
  const MarkClueResolved(this.index);

  final int index;
}

sealed class StoryFlowState {
  const StoryFlowState();

  int get clueCount => switch (this) {
        StoryFlowReady ready => ready.detectiveCase.clues.length,
        _ => 3,
      };

  int get firstIncompleteClueIndex => switch (this) {
        StoryFlowReady ready => ready.firstIncompleteClueIndex,
        _ => 0,
      };

  bool get allCluesComplete => switch (this) {
        StoryFlowReady ready => ready.allCluesComplete,
        _ => false,
      };

  bool get isReadOnly => switch (this) {
        StoryFlowReady ready => ready.isReadOnly,
        _ => false,
      };

  T maybeWhen<T>({
    T Function(
      DetectiveCaseEntity detectiveCase,
      List<bool> completedClues,
      bool isReadOnly,
      int resumeClueIndex,
    )? ready,
    required T Function() orElse,
  }) {
    if (this case StoryFlowReady(
          :final detectiveCase,
          :final completedClues,
          :final isReadOnly,
          :final resumeClueIndex,
        )) {
      return ready?.call(
            detectiveCase,
            completedClues,
            isReadOnly,
            resumeClueIndex,
          ) ??
          orElse();
    }
    return orElse();
  }

  T maybeMap<T>({
    T Function(StoryFlowReady state)? ready,
    required T Function() orElse,
  }) {
    if (this case StoryFlowReady state) {
      return ready?.call(state) ?? orElse();
    }
    return orElse();
  }
}

final class StoryFlowUninitialized extends StoryFlowState {
  const StoryFlowUninitialized();
}

final class StoryFlowReady extends StoryFlowState {
  const StoryFlowReady({
    required this.detectiveCase,
    required this.completedClues,
    required this.isReadOnly,
    required this.resumeClueIndex,
  });

  final DetectiveCaseEntity detectiveCase;
  final List<bool> completedClues;
  final bool isReadOnly;
  final int resumeClueIndex;

  int get firstIncompleteClueIndex {
    final index = completedClues.indexWhere((resolved) => !resolved);
    return index == -1 ? completedClues.length : index;
  }

  bool get allCluesComplete => completedClues.every((resolved) => resolved);

  StoryFlowReady copyWith({
    DetectiveCaseEntity? detectiveCase,
    List<bool>? completedClues,
    bool? isReadOnly,
    int? resumeClueIndex,
  }) {
    return StoryFlowReady(
      detectiveCase: detectiveCase ?? this.detectiveCase,
      completedClues: completedClues ?? this.completedClues,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      resumeClueIndex: resumeClueIndex ?? this.resumeClueIndex,
    );
  }
}

class StoryFlowBloc extends Bloc<StoryFlowEvent, StoryFlowState> {
  StoryFlowBloc() : super(const StoryFlowUninitialized()) {
    on<Initialize>(_onInitialize);
    on<MarkClueResolved>(_onMarkClueResolved);
  }

  void _onInitialize(Initialize event, Emitter<StoryFlowState> emit) {
    final current = state;
    if (current case StoryFlowReady ready
        when ready.detectiveCase.id == event.detectiveCase.id) {
      return;
    }

    final completedClues = _initialCompletedClues(
      clueCount: event.detectiveCase.clues.length,
      progress: event.progress,
      isReadOnly: event.isReadOnly,
    );
    final resumeClueIndex = _resumeClueIndex(completedClues);

    emit(
      StoryFlowReady(
        detectiveCase: event.detectiveCase,
        completedClues: completedClues,
        isReadOnly: event.isReadOnly,
        resumeClueIndex: resumeClueIndex,
      ),
    );
  }

  void _onMarkClueResolved(
    MarkClueResolved event,
    Emitter<StoryFlowState> emit,
  ) {
    final current = state;
    if (current case StoryFlowReady ready when !ready.isReadOnly) {
      final index = event.index;
      if (index < 0 || index >= ready.completedClues.length) {
        return;
      }

      final updated = List<bool>.from(ready.completedClues);
      updated[index] = true;

      emit(
        ready.copyWith(
          completedClues: updated,
          resumeClueIndex: _resumeClueIndex(updated),
        ),
      );
    }
  }

  static List<bool> _initialCompletedClues({
    required int clueCount,
    StoryModeProgressEntity? progress,
    required bool isReadOnly,
  }) {
    if (isReadOnly) {
      return List<bool>.filled(clueCount, true);
    }

    if (progress != null && progress.clueSolved.length == clueCount) {
      return List<bool>.from(progress.clueSolved);
    }

    return List<bool>.filled(clueCount, false);
  }

  static int _resumeClueIndex(List<bool> completedClues) {
    final index = completedClues.indexWhere((resolved) => !resolved);
    return index == -1 ? completedClues.length : index;
  }
}
