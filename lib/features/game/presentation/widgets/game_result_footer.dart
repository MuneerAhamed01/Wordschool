import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/archive/presentation/pages/archive_page.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
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
    return FadeSlideIn(
      delay: const Duration(milliseconds: 120),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          children: [
            Text(
              _motivationLine(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MyColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'Back to Home',
              icon: Icons.home_outlined,
              variant: ButtonVariant.primary,
              onTap: () => context.go(DashboardPage.routeName),
            ),
            if (!isArchiveMode) ...[
              const SizedBox(height: 10),
              AppButton(
                label: 'Practice in Archive',
                icon: Icons.history_rounded,
                variant: ButtonVariant.secondary,
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
