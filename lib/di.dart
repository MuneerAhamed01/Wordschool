import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordshool/core/utils/valid_words.dart';
import 'package:wordshool/features/auth/data/data_source/auth_service.dart';
import 'package:wordshool/features/auth/data/data_source/remote/auth_service.dart';
import 'package:wordshool/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wordshool/features/auth/domain/repositories/auth_repository.dart';
import 'package:wordshool/features/auth/domain/usecases/sign_anonymosly.dart';
import 'package:wordshool/features/auth/domain/usecases/sign_with_google.dart';
import 'package:wordshool/features/game/data/data_source/game_service.dart';
import 'package:wordshool/features/game/data/data_source/remote/game_service.dart';
import 'package:wordshool/features/game/data/repositories/game_repository_impl.dart';
import 'package:wordshool/features/game/domain/repositories/game_repository.dart';
import 'package:wordshool/features/game/domain/usecase/load_today_word.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';
import 'package:wordshool/shared/data/repositories/session_repository_impl.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';
import 'package:wordshool/features/auth/domain/usecases/save_user_session_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependency() async {
  final sharedPref = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPref);

  await _initSessions();
  _initializeAuthDependencies();
  await _initializeValidWords();
  _initializeGame();
}

Future<void> _initSessions() async {
  getIt
      .registerSingleton<SessionHandler>(
          SessionHandler(getIt<SharedPreferences>()))
      .loadUser();

  getIt.registerSingleton<SessionRepository>(
      SessionRepositoryImpl(getIt<SessionHandler>()));

  getIt.registerSingleton<SaveUserSessionUseCase>(
      SaveUserSessionUseCase(sessionRepository: getIt<SessionRepository>()));

  getIt.registerSingleton<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(sessionRepository: getIt<SessionRepository>()));
}

void _initializeAuthDependencies() {
  getIt.registerSingleton<AuthDataSource>(
    AuthDataSourceImpl(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn.instance,
    ),
  );

  getIt.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(authDataSource: getIt<AuthDataSource>()));

  getIt.registerSingleton<SignInAnonymouslyUseCase>(
    SignInAnonymouslyUseCase(
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerSingleton<SignInWithGoogleUseCase>(
      SignInWithGoogleUseCase(authRepo: getIt<AuthRepository>()));
}

Future<void> _initializeValidWords() async {
  getIt.registerSingleton<ValidWords>(ValidWords());
  await getIt<ValidWords>().loadWords();
}

void _initializeGame() {
  getIt.registerSingleton<GameDataSource>(GameDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    validWords: getIt<ValidWords>(),
  ));

  getIt.registerSingleton<GameRepository>(GameRepositoryImpl(
    gameDataSource: getIt<GameDataSource>(),
  ));

  getIt.registerSingleton<LoadTodayWordUseCase>(LoadTodayWordUseCase(
    gameRepository: getIt<GameRepository>(),
  ));
}
