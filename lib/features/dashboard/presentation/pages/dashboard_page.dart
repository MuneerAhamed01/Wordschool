import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/analytics/analytics_events.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/archive/presentation/pages/archive_page.dart';
import 'package:wordshool/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:wordshool/features/settings/presentation/pages/settings_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_home_page.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/core/remote_config/story_mode_config.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';
import 'package:wordshool/shared/presentations/widgets/action_tile.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_banner_ad.dart';
import 'package:wordshool/shared/presentations/widgets/detective_stats_panel.dart';
import 'package:wordshool/shared/presentations/widgets/stats_panel.dart';

class DashboardPage extends StatelessWidget {
  static const String routeName = '/home';

  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => _buildError(context, message),
            loaded: (userGameState, todayGameData) =>
                _buildContent(context, userGameState, todayGameData),
          );
        },
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
  ) {
    final playLabel = _playButtonLabel(todayGameData);
    final playSubtitle = _playButtonSubtitle(todayGameData);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Column(
              children: [
                Text('WordSchool',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 6),
                Text(
                  'Your daily word puzzle',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: StatsPanel(userGameState: userGameState),
          ),
          if (getIt<StoryModeConfig>()
              .isEnabledForUser(userGameState.id)) ...[
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: DetectiveStatsPanel(userGameState: userGameState),
            ),
            const SizedBox(height: 12),
            if (getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled)
              FadeSlideIn(
                delay: const Duration(milliseconds: 130),
                child: const Center(child: StoryBannerAd()),
              ),
          ],
          const SizedBox(height: 28),
          FadeSlideIn(
            delay: const Duration(milliseconds: 160),
            child: Column(
              children: [
                AppButton(
                  label: playLabel,
                  icon: _playButtonIcon(todayGameData),
                  variant: ButtonVariant.primary,
                  onTap: () {
                    getIt<AnalyticsService>().logFeatureOpened(
                      featureName: AnalyticsFeatures.dailyGame,
                    );
                    context.push(GamePage.routeName);
                  },
                ),
                if (playSubtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    playSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MyColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (getIt<StoryModeConfig>()
              .isEnabledForUser(userGameState.id)) ...[
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: ActionTile(
                title: 'Detective Case',
                subtitle: "Solve today's mystery",
                icon: Icons.search_rounded,
                accentColor: MyColors.gray6,
                onTap: () {
                  getIt<AnalyticsService>().logFeatureOpened(
                    featureName: AnalyticsFeatures.storyMode,
                  );
                  context.push(StoryHomePage.routeName);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: ActionTile(
              title: 'Previous Games',
              subtitle: 'Replay past daily puzzles',
              icon: Icons.calendar_today_rounded,
              accentColor: MyColors.lightBlue3,
              onTap: () {
                getIt<AnalyticsService>().logFeatureOpened(
                  featureName: AnalyticsFeatures.archive,
                );
                context.push(ArchivePage.routeName);
              },
            ),
          ),
          const SizedBox(height: 10),
          FadeSlideIn(
            delay: const Duration(milliseconds: 280),
            child: ActionTile(
              title: 'Leaderboard',
              subtitle: 'Weekly detective rankings',
              icon: Icons.leaderboard_rounded,
              accentColor: MyColors.streakAccent,
              onTap: () {
                getIt<AnalyticsService>().logFeatureOpened(
                  featureName: AnalyticsFeatures.leaderboard,
                );
                context.push(LeaderboardPage.routeName);
              },
            ),
          ),
          const SizedBox(height: 10),
          FadeSlideIn(
            delay: const Duration(milliseconds: 340),
            child: ActionTile(
              title: 'Settings',
              subtitle: 'Account, privacy & preferences',
              icon: Icons.settings_outlined,
              accentColor: MyColors.textMuted,
              onTap: () {
                getIt<AnalyticsService>().logFeatureOpened(
                  featureName: AnalyticsFeatures.settings,
                );
                context.push(SettingsPage.routeName);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _playButtonLabel(UserGameDataEntity? todayGameData) {
    if (todayGameData == null || !todayGameData.isCompleted) {
      return 'Play Today\'s Puzzle';
    }
    return todayGameData.isCorrect
        ? 'Review Today\'s Win'
        : 'Review Today\'s Result';
  }

  IconData _playButtonIcon(UserGameDataEntity? todayGameData) {
    if (todayGameData?.isCompleted == true && todayGameData!.isCorrect) {
      return Icons.emoji_events_rounded;
    }
    return Icons.play_arrow_rounded;
  }

  String? _playButtonSubtitle(UserGameDataEntity? todayGameData) {
    if (todayGameData == null || !todayGameData.isCompleted) {
      return 'A new word is ready for you';
    }
    if (todayGameData.isCorrect) {
      return 'Solved in ${todayGameData.guessedWords.length} — come back tomorrow';
    }
    return 'You played today — see how you did';
  }
}
