import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/features/crossword/category/presentation/bloc/category_puzzles_bloc.dart';
import 'package:wordshool/features/crossword/category/presentation/pages/category_puzzles_page.dart';
import 'package:wordshool/features/crossword/home/presentation/bloc/home_bloc.dart';
import 'package:wordshool/features/crossword/home/presentation/pages/home_page.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/bloc/puzzle_bloc.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/pages/puzzle_page.dart';
import 'package:wordshool/features/crossword/result/presentation/pages/result_page.dart';
import 'package:wordshool/features/crossword/revise/presentation/bloc/revise_bloc.dart';
import 'package:wordshool/features/crossword/revise/presentation/pages/revise_page.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result_args.dart';
import 'package:wordshool/features/crossword/shared/domain/usecases/watch_changes.dart';
import 'package:wordshool/features/game/presentation/bloc/game_bloc/game_bloc.dart';
import 'package:wordshool/features/game/presentation/bloc/word_cubit/word_cubit.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/features/profile/presentation/pages/profile_page.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';
import 'package:wordshool/shared/presentations/widgets/app_shell.dart';

/// Signed-out users only see `/auth`; signed-in users never do.
@visibleForTesting
String? authRedirect({required String location, required bool signedIn}) {
  final atAuth = location == AppRoutes.auth;
  if (!signedIn) return atAuth ? null : AppRoutes.auth;
  if (atAuth) return AppRoutes.home;
  return null;
}

GoRouter appRouter({
  required bool Function() isSignedIn,
  Listenable? refreshListenable,
}) {
  return GoRouter(
    initialLocation: AppRoutes.home,
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
            savePlayerProfileUseCase: getIt(),
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
      // Crossword screens open full screen over the bottom bar.
      GoRoute(
        path: CategoryPuzzlesPage.routeName,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final category = state.extra is CrosswordCategoryEntity
              ? state.extra as CrosswordCategoryEntity
              : null;
          return BlocProvider(
            create: (context) => CategoryPuzzlesBloc(
              loadCategory: getIt(),
              loadPuzzles: getIt(),
              loadMarks: getIt(),
              countCompleted: getIt(),
            )..add(CategoryPuzzlesOpened(id, category: category)),
            child: CategoryPuzzlesPage(categoryId: id),
          );
        },
      ),
      GoRoute(
        path: PuzzlePage.routeName,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) => PuzzleBloc(
              loadPuzzle: getIt(),
              saveProgress: getIt(),
              submit: getIt(),
              report: getIt(),
              config: getIt(),
            )..add(PuzzleOpened(id)),
            child: PuzzlePage(puzzleId: id, config: getIt()),
          );
        },
        routes: [
          GoRoute(
            path: 'result',
            builder: (context, state) => ResultPage(
              args:
                  state.extra is ResultArgs ? state.extra as ResultArgs : null,
              config: getIt(),
            ),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: HomePage.routeName,
              builder: (context, state) => BlocProvider(
                create: (context) => CrosswordHomeBloc(
                  loadHome: getIt(),
                  loadProgress: getIt(),
                  countRevision: getIt(),
                  changes: getIt<WatchCrosswordChangesUseCase>()(),
                )..add(const CrosswordHomeRequested()),
                child: const HomePage(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RevisePage.routeName,
              builder: (context, state) => BlocProvider(
                create: (context) => ReviseBloc(
                  loadItems: getIt(),
                  setMastered: getIt(),
                  changes: getIt<WatchCrosswordChangesUseCase>()(),
                )..add(const ReviseRequested()),
                child: const RevisePage(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: LeaderboardPage.routeName,
              builder: (context, state) => BlocProvider(
                create: (context) => LeaderboardBloc(
                  loadLeaderboard: getIt(),
                  myUid: getIt<SessionHandler>().currentUser?.id,
                  changes: getIt<WatchCrosswordChangesUseCase>()(),
                )..add(const LeaderboardRequested()),
                child: const LeaderboardPage(),
              ),
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
