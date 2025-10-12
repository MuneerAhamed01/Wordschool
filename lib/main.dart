import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  await dotenv.load();

  await initializeDependency();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasUser = getIt<SessionHandler>().currentUser != null;

    final initialRoute = hasUser ? GamePage.routeName : AuthPage.routeName;

    return MaterialApp.router(
      title: 'WordSchool',
      theme: ThemeData(
        colorScheme: MyColorScheme.dark(),
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.nunito,
      ),
      routerConfig: appRouter(initialRoute),
    );
  }
}
