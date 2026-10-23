import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/game/presentation/bloc/game_bloc/game_bloc.dart';
import 'package:wordshool/features/game/presentation/bloc/word_cubit/word_cubit.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/features/home/presentation/pages/home_page.dart';
import 'package:wordshool/features/profile/presentation/pages/profile_page.dart';
import 'package:wordshool/features/ranks/presentation/pages/ranks_page.dart';
import 'package:wordshool/features/revise/presentation/pages/revise_page.dart';
import 'package:wordshool/shared/presentations/widgets/app_shell.dart';

/// Signed-out users only see `/auth`; signed-in users never do.
@visibleForTesting
String? authRedirect({required String location, required bool signedIn}) {
  final atAuth = location == AuthPage.routeName;
  if (!signedIn) return atAuth ? null : AuthPage.routeName;
  if (atAuth) return HomePage.routeName;
  return null;
}

GoRouter appRouter({
  required bool Function() isSignedIn,
  Listenable? refreshListenable,
}) {
  return GoRouter(
    initialLocation: HomePage.routeName,
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,
    redirect: (context, state) => authRedirect(
      location: state.matchedLocation,
      signedIn: isSignedIn(),
    ),
    routes: [
      GoRoute(
        path: AuthPage.routeName,
        name: AuthPage.routeName.replaceFirst(RegExp(r'0'), ''),
        builder: (context, state) => BlocProvider(
          create: (context) => AuthBloc(
            signInAnonymouslyUseCase: getIt(),
            signInWithGoogleUseCase: getIt(),
            saveUserSessionUseCase: getIt(),
          ),
          child: const AuthPage(),
        ),
      ),
      // Top-level so the game opens full screen over the bottom bar
      GoRoute(
        path: GamePage.routeName,
        name: GamePage.routeName.replaceFirst(RegExp(r'0'), ''),
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => WordCubit(validWords: getIt()),
            ),
            BlocProvider(
                create: (context) => GameBloc(loadTodayWordUseCase: getIt()))
          ],
          child: const GamePage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: HomePage.routeName,
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RevisePage.routeName,
              builder: (context, state) => const RevisePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RanksPage.routeName,
              builder: (context, state) => const RanksPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: ProfilePage.routeName,
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
    ],
  );
}
