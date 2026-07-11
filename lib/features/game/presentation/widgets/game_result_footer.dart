import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/utils/game_layout_metrics.dart';
import 'package:wordshool/features/dashboard/presentation/utils/dashboard_navigation.dart';
import 'package:wordshool/features/archive/presentation/pages/archive_page.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';

class GameResultFooter extends StatelessWidget {
  const GameResultFooter({
    super.key,
    required this.isWin,
    this.isArchiveMode = false,
  });

  final bool isWin;
  final bool isArchiveMode;

  @override
  Widget build(BuildContext context) {
    final metrics = GameLayoutMetrics.of(context);
    final compact = metrics.isCompact;
    final buttonHeight = compact ? 46.0 : 52.0;

    return FadeSlideIn(
      delay: const Duration(milliseconds: 120),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, compact ? 4 : 8, 20, compact ? 12 : 20),
        child: Column(
          children: [
            Text(
              _motivationLine(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MyColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 12 : null,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: compact ? 10 : 14),
            AppButton(
              label: 'Back to Home',
              icon: Icons.home_outlined,
              variant: ButtonVariant.primary,
              height: buttonHeight,
              onTap: () => navigateToDashboardHome(context),
            ),
            if (!isArchiveMode) ...[
              SizedBox(height: compact ? 8 : 10),
              AppButton(
                label: 'Practice in Archive',
                icon: Icons.history_rounded,
                variant: ButtonVariant.secondary,
                height: buttonHeight,
                onTap: () => context.push(ArchivePage.routeName),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _motivationLine() {
    if (isWin) {
      return isArchiveMode
          ? 'Great warm-up — today\'s puzzle is still open.'
          : 'See you tomorrow for a fresh challenge.';
    }
    return isArchiveMode
        ? 'Try another date — consistency builds skill.'
        : 'One puzzle a day keeps your mind sharp.';
  }
}
