import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/archive/domain/usecases/load_user_game_history_usecase.dart';
import 'package:wordshool/features/archive/domain/usecases/utils/load_user_game_history_param.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';

part 'archive_event.dart';
part 'archive_state.dart';
part 'archive_bloc.freezed.dart';

class ArchiveBloc extends Bloc<ArchiveEvent, ArchiveState> {
  final LoadUserGameHistoryUseCase _loadUserGameHistoryUseCase;

  ArchiveBloc({
    required LoadUserGameHistoryUseCase loadUserGameHistoryUseCase,
  })  : _loadUserGameHistoryUseCase = loadUserGameHistoryUseCase,
        super(const ArchiveState.initial()) {
    on<LoadMonth>(_onLoadMonth);
    on<PreviousMonth>(_onPreviousMonth);
    on<NextMonth>(_onNextMonth);

    final now = DateTime.now();
    add(ArchiveEvent.loadMonth(year: now.year, month: now.month));
  }

  Future<void> _onLoadMonth(
    LoadMonth event,
    Emitter<ArchiveState> emit,
  ) async {
    emit(const ArchiveState.loading());

    final result = await _loadUserGameHistoryUseCase(
      param: LoadUserGameHistoryParam(
        year: event.year,
        month: event.month,
      ),
    );

    if (result is DataSuccess) {
      final historyMap = {
        for (final gameData in result.data!) gameData.id: gameData,
      };

      emit(
        ArchiveState.loaded(
          year: event.year,
          month: event.month,
          gameHistoryByDate: historyMap,
        ),
      );
    } else {
      emit(ArchiveState.error(
        result.error?.message ?? 'Failed to load game history',
      ));
    }
  }

  void _onPreviousMonth(
    PreviousMonth event,
    Emitter<ArchiveState> emit,
  ) {
    state.maybeWhen(
      loaded: (year, month, gameHistoryByDate) {
        final previousMonth = DateTime(year, month - 1);
        add(
          ArchiveEvent.loadMonth(
            year: previousMonth.year,
            month: previousMonth.month,
          ),
        );
      },
      orElse: () {},
    );
  }

  void _onNextMonth(NextMonth event, Emitter<ArchiveState> emit) {
    state.maybeWhen(
      loaded: (year, month, gameHistoryByDate) {
        final nextMonth = DateTime(year, month + 1);
        add(
          ArchiveEvent.loadMonth(
            year: nextMonth.year,
            month: nextMonth.month,
          ),
        );
      },
      orElse: () {},
    );
  }
}
