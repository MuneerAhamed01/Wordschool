import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';

/// Centered icon + title + message, with an optional button. Use for empty
/// lists ("Nothing to revise") and load errors ("Try again").
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Error state with a retry button.
  const StateMessage.error({
    super.key,
    required String this.message,
    required VoidCallback this.onAction,
  })  : icon = Icons.cloud_off_rounded,
        title = "Couldn't load this",
        actionLabel = 'Try again';

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: MyColors.navInactive),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: MyColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style:
                    textTheme.bodyMedium?.copyWith(color: MyColors.navInactive),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: actionLabel,
                height: 48,
                expand: false,
                variant: ButtonVariant.secondary,
                onTap: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
