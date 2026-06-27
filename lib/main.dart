import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/app_theme.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/logging/logging.dart';
import 'package:wordshool/core/routes/app_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/firebase_options.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.instance.init();
  _configureGlobalErrorHandlers();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();

  await initializeDependency();

  final sessionUser = getIt<SessionHandler>().currentUser;
  final analytics = getIt<AnalyticsService>();

  if (sessionUser != null) {
    await analytics.setUserId(sessionUser.id);
    await analytics.setUserProperty(
      name: 'auth_method',
      value: sessionUser.isAnonymous ? 'anonymous' : 'google',
    );
  }

  final hasUser = sessionUser != null;
  final initialRoute = hasUser ? DashboardPage.routeName : AuthPage.routeName;
  final router = appRouter(initialRoute);

  runApp(MainApp(router: router));
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

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WordSchool',
      theme: AppTheme.gameDark(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
