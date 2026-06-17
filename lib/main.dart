import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/app_theme.dart';
import 'package:wordshool/core/routes/app_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/firebase_options.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseFirestore.setLoggingEnabled(true);

  await dotenv.load();

  await initializeDependency();

  final hasUser = getIt<SessionHandler>().currentUser != null;
  final initialRoute = hasUser ? DashboardPage.routeName : AuthPage.routeName;
  final router = appRouter(initialRoute);

  runApp(MainApp(router: router));
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
    );
  }
}
