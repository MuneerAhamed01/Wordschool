// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/presentations/widgets/progress_indicator.dart';

enum ButtonType { grey, background }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    this.onTap,
    this.onTapIcon,
    this.label,
    this.icon,
    this.type = ButtonType.grey,
    this.iconSize,
    this.labelBuilder,
    this.backgroundColor,
    this.iconColor,
    this.iconPadding,
    this.isDisabled = false,
    this.isLoading = false,
  });

  final VoidCallback? onTap;

  final VoidCallback? onTapIcon;

  final String? label;

  final IconData? icon;

  final ButtonType type;

  final double? iconSize;

  final Widget? labelBuilder;

  final Color? backgroundColor;

  final Color? iconColor;

  final EdgeInsets? iconPadding;

  final bool isDisabled;

  final bool isLoading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  double _opacity = 1;
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.isDisabled
            ? null
            : () {
                setState(() {
                  _opacity = 0.7;
                });

                widget.onTap?.call();

                setState(() {
                  _opacity = 1;
                });
              },
        child: Center(child: _buttonLabel(context)),
      ),
    );
  }

  Widget _buttonLabel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(colors: [
            if (widget.type == ButtonType.grey) ...[
              MyColors.gray5,
              MyColors.gray5,
            ] else ...[
              MyColors.gray6,
              MyColors.gray6,
            ]
          ])),
      width: double.infinity,
      child: widget.isLoading
          ? _buildLoading()
          : Center(
              child: Text(
                widget.label!,
                textScaler: const TextScaler.linear(1.0),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: AppLoadingIndicator(),
    );
  }
}
