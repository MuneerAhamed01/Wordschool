import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordshool/config/themes/app_theme.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/core/remote_config/story_mode_config.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:wordshool/features/dashboard/presentation/utils/dashboard_refresh_controller.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/features/leaderboard/domain/entities/detective_leaderboard_entry.dart';
import 'package:wordshool/features/leaderboard/domain/repositories/detective_leaderboard_repository.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';
import 'package:wordshool/features/story_mode/domain/usecases/load_today_detective_case.dart';
import 'package:wordshool/features/story_mode/domain/usecases/today_detective_case_result.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';
import 'package:wordshool/features/notifications/data/notification_preferences_store.dart';
import 'package:wordshool/features/notifications/data/notification_token_service.dart';
import 'package:wordshool/features/notifications/notification_service.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';
import 'package:wordshool/shared/domains/usercases/load_user_game_state_usecase.dart';
import 'package:wordshool/shared/domains/usercases/load_user_specific_game_state.dart';

class FakeStoryModeConfig implements StoryModeConfig {
  FakeStoryModeConfig({required this.enabled});

  final bool enabled;

  @override
  bool get isEnabled => enabled;

  @override
  int get rolloutPercent => enabled ? 100 : 0;

  @override
  bool isEnabledForUser(String? userId) => enabled;

  @override
  Future<void> initialize() async {}
}

class FakeDetectiveLeaderboardRepository
    implements DetectiveLeaderboardRepository {
  @override
  Future<DataState<DetectiveLeaderboardSnapshot>> loadWeeklyLeaderboard({
    required String? currentUserId,
    int topLimit = 50,
  }) async {
    return DataSuccess(
      data: const DetectiveLeaderboardSnapshot(
        weekId: '2026-W25',
        topEntries: [],
        currentUserEntry: null,
        currentUserRank: null,
      ),
    );
  }
}

class FakeGetCurrentUserUseCase extends GetCurrentUserUseCase {
  FakeGetCurrentUserUseCase()
      : super(sessionRepository: _FakeSessionRepository());
}

class _FakeSessionRepository implements SessionRepository {
  @override
  WordSchoolUserEntity? getCurrentUser() => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStoryCaseRepository implements StoryCaseRepository {
  @override
  Future<DataState<DetectiveCaseEntity>> getTodayCase() async {
    return DataError(error: AppError(error: 'skipped', code: 'test'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLoadTodayDetectiveCaseUseCase extends LoadTodayDetectiveCaseUseCase {
  FakeLoadTodayDetectiveCaseUseCase()
      : super(
          storyCaseRepository: FakeStoryCaseRepository(),
          getCurrentUserUseCase: FakeGetCurrentUserUseCase(),
        );

  @override
  Future<DataState<TodayDetectiveCaseResult>> call({void param}) async {
    return DataError(error: AppError(error: 'skipped', code: 'test'));
  }
}

class FakeUserGameStateRepository implements UserGameStateRepository {
  @override
  Future<DataState<UserGameStateEntity>> loadUserGameState() async {
    return DataSuccess<UserGameStateEntity>(
      data: UserGameStateEntity(
        id: 'user-1',
        createdDate: DateTime(2026, 6, 18),
        updatedDate: DateTime(2026, 6, 18),
      ),
    );
  }

  @override
  Future<DataState<UserGameDataEntity>> loadUserSpecificGameData(
    String gameId,
  ) async {
    return DataError<UserGameDataEntity>(
      error: AppError(error: 'not found', code: '404'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required bool storyModeEnabled,
}) async {
  if (getIt.isRegistered<StoryModeConfig>()) {
    await getIt.unregister<StoryModeConfig>();
  }
  if (getIt.isRegistered<AnalyticsService>()) {
    await getIt.unregister<AnalyticsService>();
  }
  if (getIt.isRegistered<MonetizationConfig>()) {
    await getIt.unregister<MonetizationConfig>();
  }
  if (getIt.isRegistered<GetCurrentUserUseCase>()) {
    await getIt.unregister<GetCurrentUserUseCase>();
  }
  if (getIt.isRegistered<DetectiveLeaderboardRepository>()) {
    await getIt.unregister<DetectiveLeaderboardRepository>();
  }

  getIt.registerSingleton<StoryModeConfig>(
    FakeStoryModeConfig(enabled: storyModeEnabled),
  );
  getIt.registerSingleton<AnalyticsService>(NoOpAnalyticsService());
  getIt.registerSingleton<MonetizationConfig>(
    const MonetizationConfig(isMonetizationAndPurchasesEnabled: false),
  );
  getIt.registerSingleton<GetCurrentUserUseCase>(FakeGetCurrentUserUseCase());
  getIt.registerSingleton<DetectiveLeaderboardRepository>(
    FakeDetectiveLeaderboardRepository(),
  );
  getIt.registerSingleton<DashboardRefreshController>(
    DashboardRefreshController(),
  );

  final repository = FakeUserGameStateRepository();
  final bloc = DashboardBloc(
    loadUserGameStateUseCase:
        LoadUserGameStateUseCase(userGameStateRepository: repository),
    loadUserSpecificGameStateUseCase: LoadUserSpecificGameStateUseCase(
      userGameStateRepository: repository,
    ),
    loadTodayDetectiveCaseUseCase: FakeLoadTodayDetectiveCaseUseCase(),
  );

  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.gameDark(),
      routerConfig: GoRouter(
        initialLocation: DashboardPage.routeName,
        routes: [
          GoRoute(
            path: DashboardPage.routeName,
            builder: (context, state) => BlocProvider.value(
              value: bloc,
              child: const DashboardPage(),
            ),
          ),
        ],
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'notification_preferences': jsonEncode(
        const {'permissionPromptShown': true},
      ),
    });
    if (getIt.isRegistered<SessionHandler>()) {
      await getIt.unregister<SessionHandler>();
    }
    if (getIt.isRegistered<NotificationService>()) {
      await getIt.unregister<NotificationService>();
    }

    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SessionHandler>(SessionHandler(prefs));
    getIt.registerSingleton<NotificationService>(
      NotificationService(
        preferencesStore: NotificationPreferencesStore(prefs),
        tokenService: NotificationTokenService(
          firestore: FirebaseFirestore.instance,
        ),
        analytics: NoOpAnalyticsService(),
      ),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('DashboardPage story mode hero', () {
    testWidgets('shows Detective Case hero when story mode is enabled',
        (tester) async {
      await _pumpDashboard(tester, storyModeEnabled: true);

      expect(find.text('Detective Case'), findsOneWidget);
      expect(find.text('Play Today\'s Case'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
    });

    testWidgets('hides Detective Case hero when story mode is disabled',
        (tester) async {
      await _pumpDashboard(tester, storyModeEnabled: false);

      expect(find.text('Detective Case'), findsNothing);
      expect(find.text('Play Today\'s Case'), findsNothing);
    });
  });
}
