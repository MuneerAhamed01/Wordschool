import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/archive/presentation/bloc/archive_bloc.dart';
import 'package:wordshool/features/archive/presentation/pages/archive_page.dart';
import 'package:wordshool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/features/game/presentation/bloc/game_bloc/game_bloc.dart';
import 'package:wordshool/features/game/presentation/bloc/word_cubit/word_cubit.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/features/game/presentation/utils/game_route_parser.dart';
import 'package:wordshool/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:wordshool/features/settings/domain/usecases/logout_usecase.dart';
import 'package:wordshool/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:wordshool/features/settings/presentation/pages/legal_markdown_page.dart';
import 'package:wordshool/features/settings/presentation/pages/settings_page.dart';
import 'package:wordshool/features/winning/presentation/pages/params/winning_page_param.dart';
import 'package:wordshool/features/winning/presentation/pages/winning_page.dart';

GoRouter appRouter(String initialRoute) {
  return GoRouter(
    initialLocation: initialRoute,
    debugLogDiagnostics: true,
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
      GoRoute(
        path: DashboardPage.routeName,
        name: DashboardPage.routeName.replaceFirst(RegExp(r'0'), ''),
        builder: (context, state) => BlocProvider(
          create: (context) => DashboardBloc(
            loadUserGameStateUseCase: getIt(),
            loadUserSpecificGameStateUseCase: getIt(),
          ),
          child: const DashboardPage(),
        ),
      ),
      GoRoute(
        path: GamePage.routeName,
        name: GamePage.routeName.replaceFirst(RegExp(r'0'), ''),
        builder: (context, state) {
          final loadConfig = GameRouteParser.parseUri(state.uri);

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => WordCubit(validWords: getIt()),
              ),
              BlocProvider(
                create: (context) => GameBloc(
                  loadGameByDateUseCase: getIt(),
                  loadUserGameStateUseCase: getIt(),
                  loadUserSpecificGameStateUseCase: getIt(),
                  addGuessedWordUseCase: getIt(),
                  markGameCompletedUseCase: getIt(),
                  loadConfig: loadConfig,
                ),
              ),
            ],
            child: const GamePage(),
          );
        },
      ),
      GoRoute(
        path: ArchivePage.routeName,
        name: ArchivePage.routeName.replaceFirst(RegExp(r'0'), ''),
        builder: (context, state) => BlocProvider(
          create: (context) => ArchiveBloc(
            loadUserGameHistoryUseCase: getIt(),
          ),
          child: const ArchivePage(),
        ),
      ),
      GoRoute(
        path: LeaderboardPage.routeName,
        name: LeaderboardPage.routeName.replaceFirst(RegExp(r'0'), ''),
        builder: (context, state) => const LeaderboardPage(),
      ),
      GoRoute(
        path: SettingsPage.routeName,
        name: SettingsPage.routeName.replaceFirst(RegExp(r'0'), ''),
        builder: (context, state) => BlocProvider(
          create: (_) => SettingsBloc(
            logoutUseCase: getIt<LogoutUseCase>(),
          ),
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const LegalMarkdownPage(
          title: 'Terms & Conditions',
          assetPath: 'assets/legal/terms.md',
        ),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const LegalMarkdownPage(
          title: 'Privacy Policy',
          assetPath: 'assets/legal/privacy.md',
        ),
      ),
      GoRoute(
        path: WinningPage.routeName,
        name: WinningPage.routeName.replaceFirst(RegExp(r'0'), ''),
        pageBuilder: (context, state) {
          final params = state.extra as WinningPageParam;
          return CustomTransitionPage(
            child: WinningPage(
              word: params.word,
              isLost: params.isLost,
              isArchiveMode: params.isArchiveMode,
              gameDateId: params.gameDateId,
              updatedStreak: params.updatedStreak,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final begin = const Offset(0, 1);
              final end = Offset.zero;
              final curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
    ],
  );
}
