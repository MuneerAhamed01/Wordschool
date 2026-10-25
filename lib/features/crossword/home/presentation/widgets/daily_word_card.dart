import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';

/// "More games": the daily word game under the categories (DEC-007).
class DailyWordCard extends StatelessWidget {
  const DailyWordCard({super.key});

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
            'MORE GAMES · DAILY WORD',
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
            onTap: () => context.push(AppRoutes.game),
          ),
        ],
      ),
    );
  }
}
