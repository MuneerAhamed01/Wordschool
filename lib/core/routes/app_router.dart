import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/game/presentation/bloc/game_bloc/game_bloc.dart';
import 'package:wordshool/features/game/presentation/bloc/word_cubit/word_cubit.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
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
      GoRoute(
        path: WinningPage.routeName,
        name: WinningPage.routeName.replaceFirst(RegExp(r'0'), ''),
        pageBuilder: (context, state) {
          final params = state.extra as WinningPageParam;
          return CustomTransitionPage(
            child: WinningPage(
              word: params.word,
              isLost: params.isLost,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final begin = const Offset(0, 1);
              final end = Offset.zero;
              final curve = Curves.ease;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
