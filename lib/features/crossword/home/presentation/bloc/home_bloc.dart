import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/ist_date.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/count_revision_items.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/load_home.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/load_home_progress.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/utils/load_home_param.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/utils/load_home_progress_param.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';

sealed class CrosswordHomeEvent {
  const CrosswordHomeEvent();
}

/// First load, pull-to-refresh, and after a submit.
final class CrosswordHomeRequested extends CrosswordHomeEvent {
  const CrosswordHomeRequested({this.silent = false});

  /// Keep showing the current data while reloading.
  final bool silent;
}

/// Back from a puzzle: re-read marks from the session cache (no reads).
final class CrosswordHomeProgressRefreshed extends CrosswordHomeEvent {
  const CrosswordHomeProgressRefreshed();
}

/// A "My mistakes" item changed: re-count them (one aggregation read).
final class CrosswordHomeRevisionChanged extends CrosswordHomeEvent {
  const CrosswordHomeRevisionChanged();
}

sealed class CrosswordHomeState extends Equatable {
  const CrosswordHomeState();

  @override
  List<Object?> get props => [];
}

final class CrosswordHomeLoading extends CrosswordHomeState {
  const CrosswordHomeLoading();
}

final class CrosswordHomeLoaded extends CrosswordHomeState {
  const CrosswordHomeLoaded(this.home);

  final CrosswordHomeEntity home;

  @override
  List<Object?> get props => [home];
}

final class CrosswordHomeFailed extends CrosswordHomeState {
  const CrosswordHomeFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Crossword Home (CW-044).
class CrosswordHomeBloc extends Bloc<CrosswordHomeEvent, CrosswordHomeState> {
  CrosswordHomeBloc({
    required LoadCrosswordHomeUseCase loadHome,
    required LoadHomeProgressUseCase loadProgress,
    required CountRevisionItemsUseCase countRevision,
    Stream<CrosswordChange>? changes,
    DateTime Function()? clock,
  })  : _loadHome = loadHome,
        _loadProgress = loadProgress,
        _countRevision = countRevision,
        _clock = clock ?? DateTime.now,
        super(const CrosswordHomeLoading()) {
    on<CrosswordHomeRequested>(_onRequested);
    on<CrosswordHomeProgressRefreshed>(_onProgress);
    on<CrosswordHomeRevisionChanged>(_onRevisionChanged);
    _changes = changes?.listen(_onChange);
  }

  final LoadCrosswordHomeUseCase _loadHome;
  final LoadHomeProgressUseCase _loadProgress;
  final CountRevisionItemsUseCase _countRevision;
  final DateTime Function() _clock;
  StreamSubscription<CrosswordChange>? _changes;

  void _onChange(CrosswordChange change) => add(switch (change) {
        CrosswordChange.puzzleSubmitted =>
          const CrosswordHomeRequested(silent: true),
        CrosswordChange.revisionChanged => const CrosswordHomeRevisionChanged(),
      });

  Future<void> _onRequested(
    CrosswordHomeRequested event,
    Emitter<CrosswordHomeState> emit,
  ) async {
    final keep = event.silent && state is CrosswordHomeLoaded;
    if (!keep) emit(const CrosswordHomeLoading());
    final result = await _loadHome(
        param: LoadCrosswordHomeParam(todayId: istTodayId(_clock())));
    if (result is DataSuccess && result.data != null) {
      emit(CrosswordHomeLoaded(result.data!));
    } else if (!keep) {
      emit(CrosswordHomeFailed(
          result.error?.message ?? 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onProgress(
    CrosswordHomeProgressRefreshed event,
    Emitter<CrosswordHomeState> emit,
  ) async {
    final before = state;
    if (before is! CrosswordHomeLoaded) return;
    final home = before.home;
    final progress = await _loadProgress(
      param: LoadHomeProgressParam(
        dailyPuzzleId: home.daily?.puzzleId,
        categoryIds: [for (final c in home.categories) c.id],
      ),
    );
    final latest = state;
    if (progress.data == null || latest is! CrosswordHomeLoaded) return;
    emit(CrosswordHomeLoaded(latest.home.copyWith(progress: progress.data)));
  }

  Future<void> _onRevisionChanged(
    CrosswordHomeRevisionChanged event,
    Emitter<CrosswordHomeState> emit,
  ) async {
    if (state is! CrosswordHomeLoaded) return;
    final count = await _countRevision();
    final latest = state;
    if (count.data == null || latest is! CrosswordHomeLoaded) return;
    emit(CrosswordHomeLoaded(latest.home.copyWith(revisionCount: count.data)));
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
