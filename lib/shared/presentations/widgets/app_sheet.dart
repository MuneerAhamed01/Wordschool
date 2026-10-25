import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// Shows a bottom sheet in the app style: scrim, sheet colour, 24 top radius,
/// drag handle, keyboard-safe. [builder] returns the sheet body (usually an
/// [AppSheetHeader] followed by content).
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: MyColors.sheetBackground,
    barrierColor: MyColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: MyColors.gameBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            builder(context),
          ],
        ),
      ),
    ),
  );
}

/// Overline · title · subtitle, with a 44 px close button.
class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    this.overline,
    required this.title,
    this.subtitle,
  });

  final String? overline;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null)
                Text(
                  overline!,
                  style: textTheme.labelSmall?.copyWith(
                    color: MyColors.clueBarLabel,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: MyColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: MyColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          tooltip: 'Close',
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: const Icon(Icons.close_rounded, color: MyColors.navInactive),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
