import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:wordshool/config/themes/app_theme.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/remote_config/story_mode_config.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/domains/repostiories/user_game_state_repository.dart';
import 'package:wordshool/shared/domains/usercases/load_user_game_state_usecase.dart';
import 'package:wordshool/shared/domains/usercases/load_user_specific_game_state.dart';

class FakeStoryModeConfig implements StoryModeConfig {
  FakeStoryModeConfig({required this.enabled});

  final bool enabled;

  @override
  bool get isEnabled => enabled;

  @override
  Future<void> initialize() async {}
}

class FakeUserGameStateRepository implements UserGameStateRepository {
  @override
  Future<DataState<UserGameStateEntity>> loadUserGameState() async {
    return DataSuccess<UserGameStateEntity>(
      data: UserGameStateEntity(
        id: 'user-1',
        createdDate: DateTime(2026, 6, 18),
        updatedDate: DateTime(2026, 6, 18),
      ),
    );
  }

  @override
  Future<DataState<UserGameDataEntity>> loadUserSpecificGameData(
    String gameId,
  ) async {
    return DataError<UserGameDataEntity>(
      error: AppError(error: 'not found', code: '404'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required bool storyModeEnabled,
}) async {
  if (getIt.isRegistered<StoryModeConfig>()) {
    await getIt.unregister<StoryModeConfig>();
  }
  if (getIt.isRegistered<AnalyticsService>()) {
    await getIt.unregister<AnalyticsService>();
  }

  getIt.registerSingleton<StoryModeConfig>(
    FakeStoryModeConfig(enabled: storyModeEnabled),
  );
  getIt.registerSingleton<AnalyticsService>(NoOpAnalyticsService());

  final repository = FakeUserGameStateRepository();
  final bloc = DashboardBloc(
    loadUserGameStateUseCase:
        LoadUserGameStateUseCase(userGameStateRepository: repository),
    loadUserSpecificGameStateUseCase: LoadUserSpecificGameStateUseCase(
      userGameStateRepository: repository,
    ),
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.gameDark(),
      home: BlocProvider.value(
        value: bloc,
        child: const DashboardPage(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  group('DashboardPage story mode tile', () {
    testWidgets('shows Detective Case tile when story mode is enabled', (tester) async {
      await _pumpDashboard(tester, storyModeEnabled: true);

      expect(find.text('Detective Case'), findsOneWidget);
      expect(find.text("Solve today's mystery"), findsOneWidget);
    });

    testWidgets('hides Detective Case tile when story mode is disabled', (tester) async {
      await _pumpDashboard(tester, storyModeEnabled: false);

      expect(find.text('Detective Case'), findsNothing);
    });
  });
}
