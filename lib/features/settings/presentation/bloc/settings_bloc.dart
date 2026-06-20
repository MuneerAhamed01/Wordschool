import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/settings/domain/usecases/logout_usecase.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'settings_bloc.freezed.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final LogoutUseCase _logoutUseCase;
  final AnalyticsService _analytics;

  SettingsBloc({
    required LogoutUseCase logoutUseCase,
    required AnalyticsService analytics,
  })  : _logoutUseCase = logoutUseCase,
        _analytics = analytics,
        super(const SettingsState.initial()) {
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await _logoutUseCase();
    if (result is DataSuccess<bool> && (result.data ?? false)) {
      await _analytics.logSignOut();
      await _analytics.setUserId(null);
      emit(const SettingsState.success());
    } else {
      emit(SettingsState.error(result.error?.error ?? 'Logout failed'));
    }
  }
}


