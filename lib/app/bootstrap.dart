import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wordshool/app/word_school_app.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/config/app_config.dart';
import 'package:wordshool/core/firebase/firebase_bootstrap.dart';
import 'package:wordshool/core/logging/logging.dart';
import 'package:wordshool/core/routes/app_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/auth/presentation/pages/blocked_user_page.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/features/notifications/notification_service.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';
import 'package:wordshool/shared/domains/usercases/load_user_game_state_usecase.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/features/settings/domain/usecases/logout_usecase.dart';

/// Shared startup for every entry point (`main_dev.dart`, `main_prod.dart`).
Future<void> bootstrapWordSchool({
  required AppConfig appConfig,
  required BackgroundMessageHandler backgroundMessageHandler,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.instance.init();
  _configureGlobalErrorHandlers();

  await FirebaseBootstrap.initialize(appConfig);

  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  FirebaseMessaging.onMessage.listen((message) {
    if (kDebugMode) {
      debugPrint(
        'FCM onMessage at bootstrap: ${message.messageId ?? 'no-id'}',
      );
    }
    if (getIt.isRegistered<NotificationService>()) {
      getIt<NotificationService>().handleForegroundMessage(message);
    }
  });

  await _loadEnvironmentFile(appConfig);

  await initializeDependency(appConfig: appConfig);

  final sessionUser = getIt<SessionHandler>().currentUser;
  final analytics = getIt<AnalyticsService>();
  final notificationService = getIt<NotificationService>();

  if (appConfig.isDev) {
    await analytics.setUserProperty(name: 'environment', value: 'dev');
  }

  if (sessionUser != null) {
    await analytics.setUserId(sessionUser.id);
    final authMethod = sessionUser.authMethod ??
        (sessionUser.isAnonymous ? 'anonymous' : 'google');
    await analytics.setUserProperty(
      name: 'auth_method',
      value: authMethod,
    );
    await notificationService.bindUser(sessionUser.id);
  }

  final hasUser = sessionUser != null;
  final initialRoute = await _resolveInitialRoute(hasUser: hasUser);
  final router = appRouter(initialRoute);

  notificationService.onRouteTap = (route) {
    router.go(route);
  };

  // await notificationService.handleColdStartMessage();

  runApp(WordSchoolApp(router: router, appConfig: appConfig));
}

Future<String> _resolveInitialRoute({required bool hasUser}) async {
  if (!hasUser) {
    return AuthPage.routeName;
  }

  final stateResult = await getIt<LoadUserGameStateUseCase>()();
  if (stateResult is DataSuccess<UserGameStateEntity>) {
    final blockedAt = stateResult.data?.blockedAt;
    if (blockedAt != null) {
      await getIt<LogoutUseCase>()();
      return BlockedUserPage.routeName;
    }
  }

  return DashboardPage.routeName;
}

Future<void> _loadEnvironmentFile(AppConfig appConfig) async {
  try {
    await dotenv.load(fileName: appConfig.envFileName);
  } catch (_) {
    await dotenv.load();
  }
}

void _configureGlobalErrorHandlers() {
  Bloc.observer = AppBlocObserver();

  FlutterError.onError = (details) {
    AppLogger.instance.error(
      details.exception,
      message: details.summary.toString(),
      tag: 'FLUTTER',
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.error(
      error,
      message: 'Uncaught platform error',
      tag: 'PLATFORM',
      stackTrace: stack,
    );
    return true;
  };
}
