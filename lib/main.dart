import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/config/themes/fonts.dart';
import 'package:wordshool/core/routes/app_router.dart';
import 'package:wordshool/core/routes/router_refresh.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/auth/domain/usecases/save_player_profile.dart';
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

  // Firebase is the source of truth; the cached user must match it.
  final firebaseAuth = FirebaseAuth.instance;
  final sessionHandler = getIt<SessionHandler>();
  bool isSignedIn() {
    final firebaseUser = firebaseAuth.currentUser;
    return firebaseUser != null &&
        sessionHandler.currentUser?.id == firebaseUser.uid;
  }

  // Wait for Firebase to restore the persisted user before the first redirect.
  await firebaseAuth.authStateChanges().first;
  if (!isSignedIn()) {
    await sessionHandler.clear();
  } else {
    // Returning player: refresh users/{uid} (lastSeenAt, name) in the
    // background (CW-055); new players get it right after sign-in.
    unawaited(getIt<SavePlayerProfileUseCase>()());
  }

  // Single GoRouter; its redirect re-runs on every auth change.
  final router = appRouter(
    isSignedIn: isSignedIn,
    refreshListenable: GoRouterRefreshStream(firebaseAuth.authStateChanges()),
  );

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
