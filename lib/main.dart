import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/config/themes/fonts.dart';
import 'package:wordshool/core/routes/app_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/firebase_options.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';

Future<void> main() async {
  // WidgetBinding
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseFirestore.setLoggingEnabled(true);

  await dotenv.load();

  await initializeDependency();

  // Compute initial route and create a single GoRouter instance
  final hasUser = getIt<SessionHandler>().currentUser != null;
  final initialRoute = hasUser ? GamePage.routeName : AuthPage.routeName;
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
      theme: ThemeData(
        colorScheme: MyColorScheme.dark(),
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.nunito,
      ),
      routerConfig: router,
    );
  }
}
