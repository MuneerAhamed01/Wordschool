import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/config/app_config.dart';
import 'package:wordshool/core/firebase/firestore_provider.dart';
import 'package:wordshool/core/utils/valid_words.dart';
import 'package:wordshool/features/archive/domain/usecases/load_user_game_history_usecase.dart';
import 'package:wordshool/features/auth/data/data_source/auth_service.dart';
import 'package:wordshool/features/auth/data/data_source/remote/auth_service.dart';
import 'package:wordshool/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wordshool/features/auth/domain/repositories/auth_repository.dart';
import 'package:wordshool/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:wordshool/features/auth/domain/usecases/sign_anonymosly.dart';
import 'package:wordshool/features/auth/domain/usecases/sign_with_google.dart';
import 'package:wordshool/features/game/data/data_source/game_service.dart';
import 'package:wordshool/features/game/data/data_source/remote/game_service.dart';
import 'package:wordshool/features/game/data/repositories/game_repository_impl.dart';
import 'package:wordshool/features/game/domain/repositories/game_repository.dart';
import 'package:wordshool/features/game/domain/usecase/load_game_by_date.dart';
import 'package:wordshool/features/game/domain/usecase/load_today_word.dart';
import 'package:wordshool/shared/data/data_source/remote/user_game_state/user_game_state_service.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';
import 'package:wordshool/shared/data/data_source/user_game_state_service.dart';
import 'package:wordshool/shared/data/repositories/session_repository_impl.dart';
import 'package:wordshool/shared/data/repositories/user_game_state_repository_impl.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';
import 'package:wordshool/features/auth/domain/usecases/save_user_session_usecase.dart';
import 'package:wordshool/shared/domains/usercases/guessed_word_usecase/add_guessed_word_usecase.dart';
import 'package:wordshool/shared/domains/usercases/load_user_game_state_usecase.dart';
import 'package:wordshool/shared/domains/usercases/load_user_specific_game_state.dart';
import 'package:wordshool/shared/domains/usercases/mark_game_usecase/mark_game_completed_usecase.dart';
import 'package:wordshool/features/settings/data/data_source/remote/settings_data_source.dart';
import 'package:wordshool/features/settings/data/data_source/settings_data_source.dart';
import 'package:wordshool/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:wordshool/features/settings/domain/repositories/settings_repository.dart';
import 'package:wordshool/features/settings/domain/usecases/delete_account_usecase.dart';
import 'package:wordshool/features/settings/domain/usecases/logout_usecase.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/core/remote_config/story_mode_config.dart';
import 'package:wordshool/features/story_mode/data/data_source/remote/story_case_service.dart';
import 'package:wordshool/features/story_mode/data/data_source/remote/story_progress_service.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_case_service.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_progress_service.dart';
import 'package:wordshool/features/story_mode/data/repositories/story_case_repository_impl.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';
import 'package:wordshool/features/story_mode/domain/usecases/complete_story_case.dart';
import 'package:wordshool/features/story_mode/domain/usecases/complete_story_clue.dart';
import 'package:wordshool/features/story_mode/domain/usecases/load_today_detective_case.dart';
import 'package:wordshool/features/story_mode/domain/usecases/save_clue_guess.dart';
import 'package:wordshool/features/leaderboard/data/data_source/remote/detective_leaderboard_service.dart';
import 'package:wordshool/features/leaderboard/data/data_source/detective_leaderboard_service.dart';
import 'package:wordshool/features/leaderboard/data/repositories/detective_leaderboard_repository_impl.dart';
import 'package:wordshool/features/leaderboard/domain/repositories/detective_leaderboard_repository.dart';
import 'package:wordshool/features/leaderboard/domain/usecases/load_detective_leaderboard.dart';
import 'package:wordshool/core/monetization/ad_service.dart';
import 'package:wordshool/core/monetization/iap_service.dart';
import 'package:wordshool/core/monetization/story_entitlements.dart';
import 'package:wordshool/features/story_mode/domain/usecases/consume_hint.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_audio_manager.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_mode_session_controller.dart';
import 'package:wordshool/features/notifications/data/notification_preferences_store.dart';
import 'package:wordshool/features/notifications/data/notification_token_service.dart';
import 'package:wordshool/features/notifications/notification_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependency({required AppConfig appConfig}) async {
  final sharedPref = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPref);

  getIt.registerSingleton<AppConfig>(appConfig);

  final firestore = FirestoreProvider.instanceFor(appConfig);
  getIt.registerSingleton<FirebaseFirestore>(firestore);

  await _initSessions();
  _initializeAnalytics();
  await _initializeAuthDependencies(appConfig);
  await _initializeValidWords();
  await _initializeRemoteConfig();
  getIt.registerSingleton<MonetizationConfig>(MonetizationConfig.fromEnv());
  _initializeGame();
  _initializeStoryMode();
  getIt.registerSingleton<StoryModeSessionController>(
    StoryModeSessionController(),
  );
  _initializeLeaderboard();
  await _initializeStoryModeExtras();
  _initializeSettings();
  await _initializeNotifications();
}

Future<void> _initializeNotifications() async {
  getIt.registerSingleton<NotificationPreferencesStore>(
    NotificationPreferencesStore(getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<NotificationTokenService>(
    NotificationTokenService(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerSingleton<NotificationService>(
    NotificationService(
      preferencesStore: getIt<NotificationPreferencesStore>(),
      tokenService: getIt<NotificationTokenService>(),
      analytics: getIt<AnalyticsService>(),
    ),
  );

  await getIt<NotificationService>().initialize();
}

Future<void> _initializeStoryModeExtras() async {
  getIt.registerSingleton<StoryAudioManager>(
    StoryAudioManager(preferences: getIt<SharedPreferences>()),
  );

  if (!getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled) {
    return;
  }

  getIt.registerSingleton<StoryEntitlementsService>(
    StoryEntitlementsService(
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      userGameStateDataSource: getIt<UserGameStateDataSource>(),
    ),
  );
  await getIt<StoryEntitlementsService>().refresh();

  getIt.registerSingleton<ConsumeHintUseCase>(
    ConsumeHintUseCase(
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      userGameStateDataSource: getIt<UserGameStateDataSource>(),
      entitlementsService: getIt<StoryEntitlementsService>(),
    ),
  );

  getIt.registerSingleton<AdService>(
    AdService(entitlements: getIt<StoryEntitlementsService>()),
  );
  await getIt<AdService>().initialize();

  getIt.registerSingleton<IapService>(
    IapService(
      userGameStateDataSource: getIt<UserGameStateDataSource>(),
      analytics: getIt<AnalyticsService>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      entitlementsService: getIt<StoryEntitlementsService>(),
    ),
  );
  await getIt<IapService>().initialize();
}

void _initializeLeaderboard() {
  getIt.registerSingleton<DetectiveLeaderboardDataSource>(
    DetectiveLeaderboardDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerSingleton<DetectiveLeaderboardRepository>(
    DetectiveLeaderboardRepositoryImpl(
      dataSource: getIt<DetectiveLeaderboardDataSource>(),
    ),
  );

  getIt.registerSingleton<LoadDetectiveLeaderboardUseCase>(
    LoadDetectiveLeaderboardUseCase(
      repository: getIt<DetectiveLeaderboardRepository>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );
}

Future<void> _initializeRemoteConfig() async {
  getIt.registerSingleton<StoryModeConfig>(FirebaseStoryModeConfig());
  await getIt<StoryModeConfig>().initialize();
}

void _initializeStoryMode() {
  getIt.registerSingleton<StoryCaseDataSource>(
    StoryCaseDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerSingleton<StoryProgressDataSource>(
    StoryProgressDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerSingleton<StoryCaseRepository>(
    StoryCaseRepositoryImpl(
      storyCaseDataSource: getIt<StoryCaseDataSource>(),
      storyProgressDataSource: getIt<StoryProgressDataSource>(),
      userGameStateDataSource: getIt<UserGameStateDataSource>(),
    ),
  );

  getIt.registerSingleton<LoadTodayDetectiveCaseUseCase>(
    LoadTodayDetectiveCaseUseCase(
      storyCaseRepository: getIt<StoryCaseRepository>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  getIt.registerSingleton<SaveClueGuessUseCase>(
    SaveClueGuessUseCase(storyCaseRepository: getIt<StoryCaseRepository>()),
  );

  getIt.registerSingleton<CompleteStoryClueUseCase>(
    CompleteStoryClueUseCase(storyCaseRepository: getIt<StoryCaseRepository>()),
  );

  getIt.registerSingleton<CompleteStoryCaseUseCase>(
    CompleteStoryCaseUseCase(storyCaseRepository: getIt<StoryCaseRepository>()),
  );
}

Future<void> _initSessions() async {
  getIt
      .registerSingleton<SessionHandler>(
          SessionHandler(getIt<SharedPreferences>()))
      .loadUser();

  getIt.registerSingleton<SessionRepository>(
      SessionRepositoryImpl(getIt<SessionHandler>()));

  getIt.registerSingleton<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(sessionRepository: getIt<SessionRepository>()));
}

void _initializeAnalytics() {
  getIt.registerSingleton<AnalyticsService>(
    FirebaseAnalyticsService(FirebaseAnalytics.instance),
  );
}

Future<void> _initializeAuthDependencies(AppConfig appConfig) async {
  await AuthDataSourceImpl.initializeGoogleSignIn(appConfig);

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

  getIt.registerSingleton<SignInWithAppleUseCase>(
      SignInWithAppleUseCase(authRepo: getIt<AuthRepository>()));
}

Future<void> _initializeValidWords() async {
  getIt.registerSingleton<ValidWords>(ValidWords());
  await getIt<ValidWords>().loadWords();
}

void _initializeGame() {
  getIt.registerSingleton<GameDataSource>(GameDataSourceImpl(
    firestore: getIt<FirebaseFirestore>(),
    validWords: getIt<ValidWords>(),
  ));

  getIt.registerSingleton<GameRepository>(GameRepositoryImpl(
    gameDataSource: getIt<GameDataSource>(),
  ));

  getIt.registerSingleton<UserGameStateDataSource>(
      UserGameStateDataSourceImpl(firestore: getIt<FirebaseFirestore>()));

  getIt.registerSingleton<UserGameStateRepository>(UserGameStateRepositoryImpl(
    dataSource: getIt<UserGameStateDataSource>(),
    sessionRepository: getIt<SessionRepository>(),
  ));

  getIt.registerSingleton<LoadTodayWordUseCase>(LoadTodayWordUseCase(
    gameRepository: getIt<GameRepository>(),
  ));

  getIt.registerSingleton<LoadGameByDateUseCase>(LoadGameByDateUseCase(
    gameRepository: getIt<GameRepository>(),
  ));

  getIt.registerSingleton<LoadUserGameHistoryUseCase>(
    LoadUserGameHistoryUseCase(
      userGameStateRepository: getIt<UserGameStateRepository>(),
    ),
  );

  getIt.registerSingleton<LoadUserGameStateUseCase>(LoadUserGameStateUseCase(
    userGameStateRepository: getIt<UserGameStateRepository>(),
  ));

  getIt.registerSingleton<LoadUserSpecificGameStateUseCase>(
      LoadUserSpecificGameStateUseCase(
    userGameStateRepository: getIt<UserGameStateRepository>(),
  ));

  getIt.registerSingleton<AddGuessedWordUseCase>(AddGuessedWordUseCase(
    userGameStateRepository: getIt<UserGameStateRepository>(),
  ));

  getIt.registerSingleton<MarkGameCompletedUseCase>(MarkGameCompletedUseCase(
    userGameStateRepository: getIt<UserGameStateRepository>(),
  ));

  getIt.registerSingleton<SaveUserSessionUseCase>(
    SaveUserSessionUseCase(
      sessionRepository: getIt<SessionRepository>(),
      userGameStateRepository: getIt<UserGameStateRepository>(),
    ),
  );
}

void _initializeSettings() {
  getIt.registerSingleton<FirebaseFunctions>(FirebaseFunctions.instance);

  getIt.registerSingleton<SettingsDataSource>(
    SettingsDataSourceImpl(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn.instance,
      functions: getIt<FirebaseFunctions>(),
    ),
  );

  getIt.registerSingleton<SettingsRepository>(
    SettingsRepositoryImpl(
      dataSource: getIt<SettingsDataSource>(),
      sessionRepository: getIt<SessionRepository>(),
      storyModeSessionController: getIt<StoryModeSessionController>(),
    ),
  );

  getIt.registerSingleton<LogoutUseCase>(
    LogoutUseCase(repository: getIt<SettingsRepository>()),
  );

  getIt.registerSingleton<DeleteAccountUseCase>(
    DeleteAccountUseCase(repository: getIt<SettingsRepository>()),
  );
}
