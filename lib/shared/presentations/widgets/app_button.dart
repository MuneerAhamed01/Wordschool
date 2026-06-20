import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/presentations/widgets/pressable_scale.dart';
import 'package:wordshool/shared/presentations/widgets/progress_indicator.dart';

enum ButtonVariant { primary, secondary, ghost, google }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.onTap,
    this.label,
    this.icon,
    this.leading,
    this.variant = ButtonVariant.primary,
    this.isDisabled = false,
    this.isLoading = false,
    this.expand = true,
    this.height = 52,
  });

  final VoidCallback? onTap;
  final String? label;
  final IconData? icon;
  final Widget? leading;
  final ButtonVariant variant;
  final bool isDisabled;
  final bool isLoading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    final enabled = !isDisabled && !isLoading && onTap != null;

    final button = PressableScale(
      enabled: enabled,
      onTap: onTap ?? () {},
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.45,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: height,
          width: expand ? double.infinity : null,
          padding: expand ? null : const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: colors.border != null
                ? Border.all(color: colors.border!)
                : null,
          ),
          child: isLoading
              ? const Center(child: AppLoadingIndicator())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 12),
                    ] else if (icon != null) ...[
                      Icon(icon, size: 20, color: colors.foreground),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label ?? '',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colors.foreground,
                            fontWeight: variant == ButtonVariant.google
                                ? FontWeight.w600
                                : FontWeight.w700,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );

    return button;
  }

  _ButtonColors _resolveColors() {
    switch (variant) {
      case ButtonVariant.primary:
        return const _ButtonColors(
          background: MyColors.tileCorrect,
          foreground: MyColors.white,
        );
      case ButtonVariant.secondary:
        return const _ButtonColors(
          background: MyColors.keyAction,
          foreground: MyColors.white,
        );
      case ButtonVariant.ghost:
        return const _ButtonColors(
          background: Colors.transparent,
          foreground: MyColors.white,
          border: MyColors.gameBorder,
        );
      case ButtonVariant.google:
        return const _ButtonColors(
          background: MyColors.white,
          foreground: Color(0xFF1F1F1F),
          border: Color(0xFFDADCE0),
        );
    }
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
}
