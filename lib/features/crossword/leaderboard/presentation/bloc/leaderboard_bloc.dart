import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/usecases/load_leaderboard.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/utils/board_id.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';

sealed class LeaderboardEvent {
  const LeaderboardEvent();
}

final class LeaderboardRequested extends LeaderboardEvent {
  const LeaderboardRequested();
}

sealed class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

final class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

final class LeaderboardFailed extends LeaderboardState {
  const LeaderboardFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded(this.board, {required this.myUid});

  final LeaderboardEntity board;
  final String? myUid;

  @override
  List<Object?> get props => [board, myUid];
}

/// Ranks tab (CW-051): this IST week's crossword board.
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc({
    Stream<CrosswordChange>? changes,
    required LoadLeaderboardUseCase loadLeaderboard,
    required String? myUid,
    DateTime Function()? clock,
  })  : _loadLeaderboard = loadLeaderboard,
        _myUid = myUid,
        _clock = clock ?? DateTime.now,
        super(const LeaderboardLoading()) {
    on<LeaderboardRequested>(_onRequested);
    _changes = changes
        ?.where((c) => c == CrosswordChange.puzzleSubmitted)
        .listen((_) => add(const LeaderboardRequested()));
  }

  final LoadLeaderboardUseCase _loadLeaderboard;
  final String? _myUid;
  final DateTime Function() _clock;

  /// This IST week's board, like the server.
  String get boardId => weeklyBoardId(_clock());

  Future<void> _onRequested(
      LeaderboardRequested event, Emitter<LeaderboardState> emit) async {
    if (state is! LeaderboardLoaded) emit(const LeaderboardLoading());
    final result = await _loadLeaderboard(param: boardId);
    if (result is DataSuccess && result.data != null) {
      emit(LeaderboardLoaded(result.data!, myUid: _myUid));
    } else {
      emit(LeaderboardFailed(
          result.error?.message ?? "Couldn't load the leaderboard."));
    }
  }

  StreamSubscription<CrosswordChange>? _changes;

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
