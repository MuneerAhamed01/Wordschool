import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/analytics/analytics_events.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/core/remote_config/story_mode_config.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/notifications/notification_service.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';
import 'package:wordshool/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:wordshool/features/dashboard/presentation/utils/dashboard_refresh_controller.dart';
import 'package:wordshool/features/dashboard/presentation/widgets/daily_puzzle_hero.dart';
import 'package:wordshool/features/dashboard/presentation/widgets/story_mode_hero.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/features/notifications/presentation/notification_permission_prompt.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_home_page.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_banner_ad.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';

class DashboardPage extends StatefulWidget {
  static const String routeName = '/home';

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  GoRouter? _router;
  String? _lastLocation;

  @override
  void initState() {
    super.initState();
    final user = getIt<SessionHandler>().currentUser;
    if (user != null) {
      getIt<NotificationService>().bindUser(user.id);
    }
    getIt<DashboardRefreshController>().bind(_refreshDashboard);
  }

  void _refreshDashboard() {
    if (!mounted) return;
    context.read<DashboardBloc>().add(const DashboardEvent.loadDashboard());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (!identical(_router, router)) {
      _router?.routerDelegate.removeListener(_onRouteChanged);
      _router = router;
      _lastLocation ??= _router!.state.uri.path;
      _router!.routerDelegate.addListener(_onRouteChanged);
    }
  }

  void _onRouteChanged() {
    if (!mounted || _router == null) return;

    final location = _router!.state.uri.path;
    final returningHome = _lastLocation != null &&
        _lastLocation != DashboardPage.routeName &&
        location == DashboardPage.routeName;
    _lastLocation = location;

    if (returningHome) {
      _refreshDashboard();
    }
  }

  @override
  void dispose() {
    getIt<DashboardRefreshController>().unbind();
    _router?.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      safeAreaBottom: false,
      body: Stack(
        children: [
          BlocListener<DashboardBloc, DashboardState>(
            listener: (context, state) {
              state.whenOrNull(
                loaded: (userGameState, todayGameData, todayStoryProgress) {
                  final storyEnabled = getIt<StoryModeConfig>()
                      .isEnabledForUser(userGameState.id);
                  getIt<NotificationService>().rescheduleLocalNotifications(
                    dailyStreak: userGameState.streak,
                    dailyPlayedToday: todayGameData?.isCompleted ?? false,
                    detectivePlayedToday:
                        todayStoryProgress?.completedAt != null,
                    storyModeEnabled: storyEnabled,
                  );
                },
              );
            },
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                return state.when(
                  initial: () =>
                      const Center(child: CircularProgressIndicator()),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (message) => _buildError(context, message),
                  loaded: (userGameState, todayGameData, todayStoryProgress) =>
                      _buildContent(
                    context,
                    userGameState,
                    todayGameData,
                    todayStoryProgress,
                  ),
                );
              },
            ),
          ),
          const NotificationPermissionPrompt(),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          AppButton(
            label: 'Retry',
            variant: ButtonVariant.secondary,
            expand: false,
            onTap: () {
              context
                  .read<DashboardBloc>()
                  .add(const DashboardEvent.loadDashboard());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    UserGameStateEntity userGameState,
    UserGameDataEntity? todayGameData,
    StoryModeProgressEntity? todayStoryProgress,
  ) {
    final storyEnabled =
        getIt<StoryModeConfig>().isEnabledForUser(userGameState.id);
    final showAd = storyEnabled &&
        getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          FadeSlideIn(
            child: _DashboardHeader(streak: userGameState.streak),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: storyEnabled ? 11 : 1,
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: DailyPuzzleHero(
                      userGameState: userGameState,
                      todayGameData: todayGameData,
                      expanded: true,
                      onPlay: () => _openDailyGame(context),
                    ),
                  ),
                ),
                if (storyEnabled) ...[
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 9,
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: StoryModeHero(
                        userGameState: userGameState,
                        todayStoryProgress: todayStoryProgress,
                        expanded: true,
                        onOpen: () => _openStoryMode(context),
                      ),
                    ),
                  ),
                ],
                if (showAd) ...[
                  const SizedBox(height: 8),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 140),
                    child: const Center(child: StoryBannerAd()),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDailyGame(BuildContext context) async {
    getIt<AnalyticsService>().logFeatureOpened(
      featureName: AnalyticsFeatures.dailyGame,
    );
    await context.push(GamePage.routeName);
    if (!context.mounted) return;
    _refreshDashboard();
  }

  Future<void> _openStoryMode(BuildContext context) async {
    getIt<AnalyticsService>().logFeatureOpened(
      featureName: AnalyticsFeatures.storyMode,
    );
    await context.push(StoryHomePage.routeName);
    if (!context.mounted) return;
    _refreshDashboard();
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.streak});

  final int streak;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting,
          style: theme.textTheme.bodySmall?.copyWith(
            color: MyColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [MyColors.white, MyColors.accentGlow],
                ).createShader(bounds),
                child: Text(
                  'WordSchool',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: MyColors.white,
                  ),
                ),
              ),
            ),
            if (streak > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: MyColors.streakAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MyColors.streakAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: MyColors.streakAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day streak',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: MyColors.streakAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pick a mode and start playing',
          style: theme.textTheme.bodySmall?.copyWith(
            color: MyColors.textMuted,
          ),
        ),
      ],
    );
  }
}
