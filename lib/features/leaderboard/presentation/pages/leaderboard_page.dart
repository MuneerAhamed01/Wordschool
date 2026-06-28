import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/remote_config/story_mode_config.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/leaderboard/domain/entities/detective_leaderboard_entry.dart';
import 'package:wordshool/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/glass_card.dart';

class LeaderboardPage extends StatefulWidget {
  static const String routeName = '/leaderboard';

  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyEnabled =
        getIt<StoryModeConfig>().isEnabledForUser(null);

    return GameScaffold(
      safeAreaBottom: false,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: storyEnabled
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Daily'),
                  Tab(text: 'Detective'),
                ],
              )
            : null,
      ),
      body: storyEnabled
          ? TabBarView(
              controller: _tabController,
              children: const [
                _DailyLeaderboardTab(),
                _DetectiveLeaderboardTab(),
              ],
            )
          : const _DailyLeaderboardTab(),
    );
  }
}

class _DailyLeaderboardTab extends StatelessWidget {
  const _DailyLeaderboardTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            child: GlassCard(
              child: Column(
                children: [
                  Icon(Icons.emoji_events_outlined,
                      size: 56, color: MyColors.streakAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Coming Soon',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Daily Wordle rankings will be available once more players join.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectiveLeaderboardTab extends StatelessWidget {
  const _DetectiveLeaderboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        return switch (state) {
          LeaderboardInitial() || LeaderboardLoading() =>
            const Center(child: CircularProgressIndicator()),
          LeaderboardError(:final message) => _ErrorView(message: message),
          LeaderboardLoaded(:final snapshot) =>
            _DetectiveLeaderboardContent(snapshot: snapshot),
        };
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(
              label: 'Retry',
              variant: ButtonVariant.secondary,
              expand: false,
              onTap: () {
                context.read<LeaderboardBloc>().add(const LoadLeaderboard());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectiveLeaderboardContent extends StatelessWidget {
  const _DetectiveLeaderboardContent({required this.snapshot});

  final DetectiveLeaderboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userEntry = snapshot.currentUserEntry;
    final userRank = snapshot.currentUserRank;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          'Week ${snapshot.weekId} (UTC)',
          style: theme.textTheme.bodySmall?.copyWith(color: MyColors.textMuted),
          textAlign: TextAlign.center,
        ),
        if (userEntry != null) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Row(
              children: [
                Text(
                  userRank != null ? '#$userRank' : '—',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: MyColors.streakAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your rank', style: theme.textTheme.bodySmall),
                      Text(
                        userEntry.displayName,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${userEntry.totalPoints}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: MyColors.accentGlow,
                      ),
                    ),
                    Text('pts', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text('Top detectives', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (snapshot.topEntries.isEmpty)
          GlassCard(
            child: Text(
              'No entries yet. Complete a case to join the leaderboard.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          )
        else
          ...snapshot.topEntries.asMap().entries.map(
                (entry) => _LeaderboardRow(
                  rank: entry.key + 1,
                  item: entry.value,
                  highlight: entry.value.userId == userEntry?.userId,
                ),
              ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.item,
    this.highlight = false,
  });

  final int rank;
  final DetectiveLeaderboardEntry item;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                '#$rank',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: rank <= 3 ? MyColors.streakAccent : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                item.displayName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: highlight ? FontWeight.w700 : null,
                ),
              ),
            ),
            Text(
              '${item.totalPoints}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: MyColors.accentGlow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
