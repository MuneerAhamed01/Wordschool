import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/auth/domain/usecases/sign_anonymosly.dart';
import 'package:wordshool/features/auth/domain/usecases/sign_with_google.dart';
import 'package:wordshool/features/auth/utils/auth_type.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';
import 'package:wordshool/shared/domains/usercases/save_user_session.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInAnonymouslyUseCase _signInAnonymouslyUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SaveUserSessionUseCase _saveUserSessionUseCase;

  AuthBloc({
    required SignInAnonymouslyUseCase signInAnonymouslyUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SaveUserSessionUseCase saveUserSessionUseCase,
  })  : _signInAnonymouslyUseCase = signInAnonymouslyUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _saveUserSessionUseCase = saveUserSessionUseCase,
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

      emit(AuthState.authenticated(result.data!));
    } else {
      emit(AuthState.error(result.error?.error ?? 'Google sign-in failed'));
    }
  }

  Future<DataState<bool>> _saveUserSession(WordSchoolUserEntity user) async {
    final result = await _saveUserSessionUseCase(param: user);
    return result;
  }
}
