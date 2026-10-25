import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';
import 'package:wordshool/features/crossword/home/presentation/bloc/home_bloc.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/category_grid.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/daily_puzzle_card.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/daily_word_card.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/home_title.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/home_top_bar.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/skeleton_box.dart';
import 'package:wordshool/shared/presentations/widgets/state_message.dart';

/// Play tab: Crossword Home (`design/screens/psc-crossword.md#1-home`,
/// CW-044) with the daily word game under the grid (DEC-007). The
/// [CrosswordHomeBloc] comes from the router.
class HomePage extends StatelessWidget {
  static const String routeName = AppRoutes.home;
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CrosswordHomeBloc>();
    return GameScaffold(
      body: BlocBuilder<CrosswordHomeBloc, CrosswordHomeState>(
        builder: (context, state) => RefreshIndicator(
          onRefresh: () => _refresh(bloc, state),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              HomeTopBar(streak: _homeOf(state)?.currentStreak ?? 0),
              const SizedBox(height: 16),
              const HomeTitle(),
              const SizedBox(height: 20),
              ...switch (state) {
                CrosswordHomeLoading() => _buildSkeleton(),
                CrosswordHomeFailed(:final message) => [
                    StateMessage.error(
                      message: message,
                      onAction: () => bloc.add(const CrosswordHomeRequested()),
                    ),
                  ],
                CrosswordHomeLoaded(:final home) =>
                  _buildContent(context, bloc, home),
              },
              const SizedBox(height: 24),
              const DailyWordCard(),
            ],
          ),
        ),
      ),
    );
  }

  CrosswordHomeEntity? _homeOf(CrosswordHomeState state) =>
      state is CrosswordHomeLoaded ? state.home : null;

  Future<void> _refresh(
      CrosswordHomeBloc bloc, CrosswordHomeState state) async {
    bloc.add(const CrosswordHomeRequested(silent: true));
    await bloc.stream
        .firstWhere((s) => s is! CrosswordHomeLoading)
        .timeout(const Duration(seconds: 10), onTimeout: () => state);
  }

  /// Opens a full-screen crossword route, then refreshes marks from the
  /// session cache.
  Future<void> _open(
    BuildContext context,
    CrosswordHomeBloc bloc,
    String location, {
    Object? extra,
  }) async {
    await context.push(location, extra: extra);
    bloc.add(const CrosswordHomeProgressRefreshed());
  }

  List<Widget> _buildSkeleton() => [
        const SkeletonBox(height: 180, radius: 20),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < 6; i++) const SkeletonBox(height: 104)
          ],
        ),
      ];

  List<Widget> _buildContent(
    BuildContext context,
    CrosswordHomeBloc bloc,
    CrosswordHomeEntity home,
  ) {
    final daily = home.daily;
    return [
      FadeSlideIn(
        child: DailyPuzzleCard(
          daily: daily,
          progress: home.dailyProgress,
          onOpen: () =>
              _open(context, bloc, AppRoutes.puzzleOf(daily!.puzzleId)),
          onPlayCategory: () {
            if (home.categories.isNotEmpty) {
              final first = home.categories.first;
              _open(context, bloc, AppRoutes.categoryOf(first.id),
                  extra: first);
            }
          },
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Categories',
        style: TextStyle(
            color: MyColors.white, fontWeight: FontWeight.w800, fontSize: 17),
      ),
      const SizedBox(height: 10),
      if (home.categories.isEmpty)
        const StateMessage(
          icon: Icons.category_outlined,
          title: 'No categories yet',
          message: 'Puzzles are being prepared. Check back soon.',
        )
      else
        CategoryGrid(
          home: home,
          onCategory: (c) =>
              _open(context, bloc, AppRoutes.categoryOf(c.id), extra: c),
          onMistakes: () => context.go(AppRoutes.revise),
        ),
    ];
  }
}
