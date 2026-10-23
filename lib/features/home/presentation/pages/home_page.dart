import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';

/// Play tab (DEC-007). Placeholder until Crossword Home (CW-044);
/// the daily word game lives here as a card.
class HomePage extends StatelessWidget {
  static const String routeName = '/home';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GameScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          FadeSlideIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PSC Crossword',
                  style: textTheme.headlineMedium?.copyWith(
                    color: MyColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Revise Kerala PSC facts, one grid at a time.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: MyColors.navInactive,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const FadeSlideIn(
            delay: Duration(milliseconds: 80),
            child: _DailyWordCard(),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 160),
            child: Text(
              'Crossword puzzles are coming soon.',
              style: textTheme.bodySmall?.copyWith(
                color: MyColors.navInactive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyWordCard extends StatelessWidget {
  const _DailyWordCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MyColors.gameSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MyColors.gameBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAILY WORD',
            style: textTheme.labelSmall?.copyWith(
              color: MyColors.accentGlow,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Today's word",
            style: textTheme.titleLarge?.copyWith(
              color: MyColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A new word every day. Keep your streak going.',
            style: textTheme.bodySmall?.copyWith(
              color: MyColors.navInactive,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Play',
            height: 48,
            onTap: () => context.push(GamePage.routeName),
          ),
        ],
      ),
    );
  }
}
