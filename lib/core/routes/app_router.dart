import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/analytics/analytics_route_observer.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/routes/app_shell_page.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/archive/presentation/bloc/archive_bloc.dart';
import 'package:wordshool/features/archive/presentation/pages/archive_page.dart';
import 'package:wordshool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/auth/presentation/pages/blocked_user_page.dart';
import 'package:wordshool/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/features/game/presentation/bloc/game_bloc/game_bloc.dart';
import 'package:wordshool/features/game/presentation/bloc/word_cubit/word_cubit.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/features/game/presentation/utils/game_route_parser.dart';
import 'package:wordshool/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:wordshool/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:wordshool/core/config/app_config.dart';
import 'package:wordshool/features/settings/domain/usecases/delete_account_usecase.dart';
import 'package:wordshool/features/settings/domain/usecases/logout_usecase.dart';
import 'package:wordshool/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:wordshool/features/settings/presentation/pages/legal_markdown_page.dart';
import 'package:wordshool/features/settings/presentation/pages/settings_page.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_case_bloc/story_case_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/pages/case_intro_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/case_resolution_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/investigate_prompt_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_hint_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_home_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_reaction_page.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_clue_bloc/story_clue_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_wordle_page.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_redirect.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_mode_feature_gate.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_mode_session_controller.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';
import 'package:wordshool/features/winning/presentation/pages/params/winning_page_param.dart';
import 'package:wordshool/features/winning/presentation/pages/winning_page.dart';

GoRouter appRouter(String initialRoute) {
  final analyticsObserver =
      AnalyticsRouteObserver(getIt<AnalyticsService>());
  final storyCaseBloc = StoryCaseBloc(
    loadTodayDetectiveCaseUseCase: getIt(),
  );
  final storyFlowBloc = StoryFlowBloc();
  getIt<StoryModeSessionController>().bind(
    caseBloc: storyCaseBloc,
    flowBloc: storyFlowBloc,
  );

  return GoRouter(
    initialLocation: initialRoute,
    observers: [analyticsObserver],
    routes: [
      GoRoute(
        path: AuthPage.routeName,
        name: AuthPage.routeName.replaceFirst(RegExp(r'0'), ''),
        builder: (context, state) => BlocProvider(
          create: (context) => AuthBloc(
            signInAnonymouslyUseCase: getIt(),
            signInWithGoogleUseCase: getIt(),
            signInWithAppleUseCase: getIt(),
            saveUserSessionUseCase: getIt(),
            analytics: getIt(),
            notificationService: getIt(),
          ),
          child: const AuthPage(),
        ),
      ),
      GoRoute(
        path: BlockedUserPage.routeName,
        builder: (context, state) => const BlockedUserPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: DashboardPage.routeName,
                name: DashboardPage.routeName.replaceFirst(RegExp(r'0'), ''),
                pageBuilder: (context, state) => NoTransitionPage(
                  child: _DashboardTab(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ArchivePage.routeName,
                name: ArchivePage.routeName.replaceFirst(RegExp(r'0'), ''),
                pageBuilder: (context, state) => NoTransitionPage(
                  child: _ArchiveTab(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: LeaderboardPage.routeName,
                name: LeaderboardPage.routeName.replaceFirst(RegExp(r'0'), ''),
                pageBuilder: (context, state) => NoTransitionPage(
                  child: _LeaderboardTab(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SettingsPage.routeName,
                name: SettingsPage.routeName.replaceFirst(RegExp(r'0'), ''),
                pageBuilder: (context, state) => NoTransitionPage(
                  child: _SettingsTab(),
                ),
              ),
            ],
          ),
        ],
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
      ShellRoute(
        redirect: (context, state) => redirectStoryModeFeatureGate(state),
        builder: (context, state, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: storyCaseBloc),
              BlocProvider.value(value: storyFlowBloc),
            ],
            child: StoryModeShell(
              location: state.uri.path,
              child: child,
            ),
          );
        },
        routes: [
          GoRoute(
            path: StoryHomePage.routeName,
            name: StoryHomePage.routeName.replaceFirst(RegExp(r'0'), ''),
            builder: (context, state) => const StoryHomePage(),
            routes: [
              GoRoute(
                path: 'intro',
                name: 'storyIntro',
                builder: (context, state) => const CaseIntroPage(),
              ),
              GoRoute(
                path: 'clue/:index/hint',
                name: 'storyHint',
                redirect: (context, state) =>
                    redirectStoryClueRoute(storyFlowBloc, state),
                builder: (context, state) => StoryHintPage(
                  clueIndex: int.parse(state.pathParameters['index']!),
                ),
              ),
              GoRoute(
                path: 'clue/:index/investigate',
                name: 'storyInvestigate',
                redirect: (context, state) =>
                    redirectStoryClueRoute(storyFlowBloc, state),
                builder: (context, state) => InvestigatePromptPage(
                  clueIndex: int.parse(state.pathParameters['index']!),
                ),
              ),
              GoRoute(
                path: 'clue/:index/wordle',
                name: 'storyWordle',
                redirect: (context, state) =>
                    redirectStoryWordleRoute(storyFlowBloc, state),
                builder: (context, state) {
                  final clueIndex = int.parse(state.pathParameters['index']!);

                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => WordCubit(validWords: getIt()),
                      ),
                      BlocProvider(
                        create: (_) => StoryClueBloc(
                          saveClueGuessUseCase: getIt(),
                          completeStoryClueUseCase: getIt(),
                          completeStoryCaseUseCase: getIt(),
                        ),
                      ),
                    ],
                    child: StoryWordlePage(clueIndex: clueIndex),
                  );
                },
              ),
              GoRoute(
                path: 'clue/:index/reaction',
                name: 'storyReaction',
                redirect: (context, state) =>
                    redirectStoryReactionRoute(storyFlowBloc, state),
                builder: (context, state) => StoryReactionPage(
                  clueIndex: int.parse(state.pathParameters['index']!),
                ),
              ),
              GoRoute(
                path: 'resolution',
                name: 'storyResolution',
                redirect: (context, state) =>
                    redirectStoryResolution(storyFlowBloc),
                builder: (context, state) => const CaseResolutionGate(),
              ),
            ],
          ),
        ],
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

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(
        loadUserGameStateUseCase: getIt(),
        loadUserSpecificGameStateUseCase: getIt(),
        loadTodayDetectiveCaseUseCase: getIt(),
      ),
      child: const DashboardPage(),
    );
  }
}

class _ArchiveTab extends StatelessWidget {
  const _ArchiveTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ArchiveBloc(
        loadUserGameHistoryUseCase: getIt(),
      ),
      child: const ArchivePage(),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaderboardBloc(
        loadDetectiveLeaderboardUseCase: getIt(),
      ),
      child: const LeaderboardPage(),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(
        logoutUseCase: getIt<LogoutUseCase>(),
        deleteAccountUseCase: getIt<DeleteAccountUseCase>(),
        analytics: getIt(),
      ),
      child: SettingsPage(appConfig: getIt<AppConfig>()),
    );
  }
}
