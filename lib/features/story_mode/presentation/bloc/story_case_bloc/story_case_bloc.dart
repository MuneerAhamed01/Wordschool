import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/usecases/load_today_detective_case.dart';

part 'story_case_event.dart';
part 'story_case_state.dart';
part 'story_case_bloc.freezed.dart';

class StoryCaseBloc extends Bloc<StoryCaseEvent, StoryCaseState> {
  StoryCaseBloc({
    required LoadTodayDetectiveCaseUseCase loadTodayDetectiveCaseUseCase,
  })  : _loadTodayDetectiveCaseUseCase = loadTodayDetectiveCaseUseCase,
        super(const StoryCaseState.initial()) {
    on<LoadTodayCase>(_onLoadTodayCase);
    on<Retry>(_onRetry);
    on<ProgressUpdated>(_onProgressUpdated);
    on<ResetForLogout>(_onResetForLogout);

    add(const StoryCaseEvent.loadTodayCase());
  }

  void resetForLogout() {
    add(const StoryCaseEvent.resetForLogout());
  }

  void _onResetForLogout(
    ResetForLogout event,
    Emitter<StoryCaseState> emit,
  ) {
    emit(const StoryCaseState.initial());
  }

  final LoadTodayDetectiveCaseUseCase _loadTodayDetectiveCaseUseCase;

  Future<void> _onLoadTodayCase(
    LoadTodayCase event,
    Emitter<StoryCaseState> emit,
  ) async {
    emit(const StoryCaseState.loading());

    final result = await _loadTodayDetectiveCaseUseCase();

    if (result is DataSuccess) {
      final data = result.data!;
      final progress = data.progress;

      if (progress?.completedAt != null) {
        emit(
          StoryCaseState.alreadyCompleted(
            detectiveCase: data.detectiveCase,
            progress: progress!,
          ),
        );
        return;
      }

      emit(
        StoryCaseState.loaded(
          detectiveCase: data.detectiveCase,
          progress: progress,
        ),
      );
      return;
    }

    emit(
      StoryCaseState.error(
        result.error?.message ?? 'Something went wrong',
      ),
    );
  }

  Future<void> _onRetry(Retry event, Emitter<StoryCaseState> emit) async {
    add(const StoryCaseEvent.loadTodayCase());
  }

  void _onProgressUpdated(
    ProgressUpdated event,
    Emitter<StoryCaseState> emit,
  ) {
    final current = state;
    current.whenOrNull(
      loaded: (detectiveCase, progress) {
        if (event.progress.completedAt != null) {
          emit(
            StoryCaseState.alreadyCompleted(
              detectiveCase: detectiveCase,
              progress: event.progress,
            ),
          );
          return;
        }

        emit(
          StoryCaseState.loaded(
            detectiveCase: detectiveCase,
            progress: event.progress,
          ),
        );
      },
    );
  }
}
