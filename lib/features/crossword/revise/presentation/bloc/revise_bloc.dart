import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/load_revision_items.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/set_revision_mastered.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/utils/load_revision_items_param.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/utils/set_revision_mastered_param.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';

sealed class ReviseEvent {
  const ReviseEvent();
}

final class ReviseRequested extends ReviseEvent {
  const ReviseRequested();
}

final class ReviseMoreRequested extends ReviseEvent {
  const ReviseMoreRequested();
}

final class ReviseItemLearned extends ReviseEvent {
  const ReviseItemLearned(this.questionId);

  final String questionId;
}

sealed class ReviseState extends Equatable {
  const ReviseState();

  @override
  List<Object?> get props => [];
}

final class ReviseLoading extends ReviseState {
  const ReviseLoading();
}

final class ReviseFailed extends ReviseState {
  const ReviseFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ReviseLoaded extends ReviseState {
  const ReviseLoaded({
    required this.items,
    required this.hasMore,
    this.loadingMore = false,
    this.saving = const {},
    this.error,
  });

  final List<RevisionItemEntity> items;
  final bool hasMore;
  final bool loadingMore;

  /// Question ids being marked as learned.
  final Set<String> saving;

  /// Last failed action (snackbar).
  final String? error;

  ReviseLoaded copyWith({
    List<RevisionItemEntity>? items,
    bool? hasMore,
    bool? loadingMore,
    Set<String>? saving,
    String? error,
  }) =>
      ReviseLoaded(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
        saving: saving ?? this.saving,
        error: error,
      );

  @override
  List<Object?> get props => [items, hasMore, loadingMore, saving, error];
}

/// Revise tab / My mistakes (CW-050).
class ReviseBloc extends Bloc<ReviseEvent, ReviseState> {
  ReviseBloc({
    Stream<CrosswordChange>? changes,
    required LoadRevisionItemsUseCase loadItems,
    required SetRevisionMasteredUseCase setMastered,
  })  : _loadItems = loadItems,
        _setMastered = setMastered,
        super(const ReviseLoading()) {
    on<ReviseRequested>(_onRequested);
    on<ReviseMoreRequested>(_onMore);
    on<ReviseItemLearned>(_onLearned);
    // Own "learned" changes are already applied; only a submit adds items.
    _changes = changes
        ?.where((c) => c == CrosswordChange.puzzleSubmitted)
        .listen((_) => add(const ReviseRequested()));
  }

  final LoadRevisionItemsUseCase _loadItems;
  final SetRevisionMasteredUseCase _setMastered;
  StreamSubscription<CrosswordChange>? _changes;

  ReviseLoaded? get _loaded =>
      state is ReviseLoaded ? state as ReviseLoaded : null;

  Future<void> _onRequested(
      ReviseRequested event, Emitter<ReviseState> emit) async {
    if (_loaded == null) emit(const ReviseLoading());
    final page = await _loadItems(param: const LoadRevisionItemsParam());
    final message = page.error?.message ?? "Couldn't load your mistakes.";
    if (page is DataError || page.data == null) {
      // A failed refresh keeps the list on screen and says why.
      final loaded = _loaded;
      emit(loaded == null
          ? ReviseFailed(message)
          : loaded.copyWith(error: message));
      return;
    }
    emit(ReviseLoaded(items: page.data!.items, hasMore: page.data!.hasMore));
  }

  Future<void> _onMore(
      ReviseMoreRequested event, Emitter<ReviseState> emit) async {
    final current = _loaded;
    if (current == null || !current.hasMore || current.loadingMore) return;
    emit(current.copyWith(loadingMore: true));
    final page = await _loadItems(
        param: LoadRevisionItemsParam(after: current.items.last));
    final latest = _loaded ?? current;
    if (page is DataError || page.data == null) {
      emit(latest.copyWith(
          loadingMore: false,
          error: page.error?.message ?? "Couldn't load more."));
      return;
    }
    final known = latest.items.map((i) => i.questionId).toSet();
    emit(latest.copyWith(
      items: [
        ...latest.items,
        ...page.data!.items.where((i) => !known.contains(i.questionId)),
      ],
      hasMore: page.data!.hasMore,
      loadingMore: false,
    ));
  }

  Future<void> _onLearned(
      ReviseItemLearned event, Emitter<ReviseState> emit) async {
    final current = _loaded;
    if (current == null || current.saving.contains(event.questionId)) return;
    emit(current.copyWith(saving: {...current.saving, event.questionId}));
    final result = await _setMastered(
        param: SetRevisionMasteredParam(questionId: event.questionId));
    // A refresh may have replaced the state meanwhile.
    final latest = _loaded;
    if (latest == null) return;
    final saving = {...latest.saving}..remove(event.questionId);
    if (result is DataError) {
      emit(latest.copyWith(
          saving: saving,
          error: result.error?.message ?? "Couldn't save. Try again."));
      return;
    }
    emit(latest.copyWith(
      items:
          latest.items.where((i) => i.questionId != event.questionId).toList(),
      saving: saving,
    ));
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
