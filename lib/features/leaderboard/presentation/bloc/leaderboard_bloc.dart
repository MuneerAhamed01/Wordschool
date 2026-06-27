import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/leaderboard/domain/entities/detective_leaderboard_entry.dart';
import 'package:wordshool/features/leaderboard/domain/usecases/load_detective_leaderboard.dart';

sealed class LeaderboardEvent {
  const LeaderboardEvent();
}

final class LoadLeaderboard extends LeaderboardEvent {
  const LoadLeaderboard();
}

sealed class LeaderboardState {
  const LeaderboardState();
}

final class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

final class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

final class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded(this.snapshot);

  final DetectiveLeaderboardSnapshot snapshot;
}

final class LeaderboardError extends LeaderboardState {
  const LeaderboardError(this.message);

  final String message;
}

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc({
    required LoadDetectiveLeaderboardUseCase loadDetectiveLeaderboardUseCase,
  })  : _loadDetectiveLeaderboardUseCase = loadDetectiveLeaderboardUseCase,
        super(const LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoad);
    add(const LoadLeaderboard());
  }

  final LoadDetectiveLeaderboardUseCase _loadDetectiveLeaderboardUseCase;

  Future<void> _onLoad(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());

    final result = await _loadDetectiveLeaderboardUseCase();
    if (result is DataSuccess<DetectiveLeaderboardSnapshot>) {
      emit(LeaderboardLoaded(result.data!));
      return;
    }

    emit(
      LeaderboardError(
        result.error?.message ?? 'Failed to load leaderboard',
      ),
    );
  }
}
