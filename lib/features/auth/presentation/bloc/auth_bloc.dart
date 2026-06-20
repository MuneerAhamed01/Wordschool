import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/auth/domain/usecases/sign_anonymosly.dart';
import 'package:wordshool/features/auth/domain/usecases/sign_with_google.dart';
import 'package:wordshool/features/auth/domain/usecases/save_user_session_usecase.dart';
import 'package:wordshool/features/auth/utils/auth_type.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInAnonymouslyUseCase _signInAnonymouslyUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SaveUserSessionUseCase _saveUserSessionUseCase;
  final AnalyticsService _analytics;

  AuthBloc({
    required SignInAnonymouslyUseCase signInAnonymouslyUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SaveUserSessionUseCase saveUserSessionUseCase,
    required AnalyticsService analytics,
  })  : _signInAnonymouslyUseCase = signInAnonymouslyUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _saveUserSessionUseCase = saveUserSessionUseCase,
        _analytics = analytics,
        super(const AuthState.initial()) {
    on<SignInAnonymously>(_onSignInAnonymously);
    on<SignInWithGoogle>(_onSignInWithGoogle);
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymously event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading(AuthType.anonymous));

    final result = await _signInAnonymouslyUseCase();

    if (result is DataSuccess && result.data != null) {
      final saveUserSessionResult = await _saveUserSession(result.data!);

      if (saveUserSessionResult is DataError) {
        emit(
          AuthState.error(
            saveUserSessionResult.error?.error ?? 'Save user session failed',
          ),
        );
      }
      await _trackSignIn(result.data!, AuthType.anonymous);
      emit(AuthState.authenticated(result.data!));
    } else {
      emit(AuthState.error(result.error?.error ?? 'Anonymous sign-in failed'));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading(AuthType.google));

    final result = await _signInWithGoogleUseCase();

    if (result is DataSuccess && result.data != null) {
      // Save user to the session
      final saveUserSessionResult = await _saveUserSession(result.data!);

      if (saveUserSessionResult is DataError) {
        emit(
          AuthState.error(
            saveUserSessionResult.error?.error ?? 'Save user session failed',
          ),
        );

        return;
      }

      await _trackSignIn(result.data!, AuthType.google);
      emit(AuthState.authenticated(result.data!));
    } else {
      final errorCode = result.error?.code;
      if (errorCode == '499') {
        emit(const AuthState.initial());
        return;
      }
      emit(AuthState.error(result.error?.error ?? 'Google sign-in failed'));
    }
  }

  Future<DataState<bool>> _saveUserSession(WordSchoolUserEntity user) async {
    final result = await _saveUserSessionUseCase(param: user);
    return result;
  }

  Future<void> _trackSignIn(
    WordSchoolUserEntity user,
    AuthType authType,
  ) async {
    await _analytics.setUserId(user.id);
    await _analytics.setUserProperty(
      name: 'auth_method',
      value: authType.name,
    );
    await _analytics.logSignIn(method: authType.name);
  }
}
