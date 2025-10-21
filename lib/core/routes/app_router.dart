import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/game/presentation/bloc/game_bloc/game_bloc.dart';
import 'package:wordshool/features/game/presentation/bloc/word_cubit/word_cubit.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';

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
    ],
  );
}
