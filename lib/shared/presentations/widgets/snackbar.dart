import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: _getTextColor(type),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getTextColor(type),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(type),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      elevation: 8,
      action: onAction != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: _getTextColor(type),
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return MyColors.green3;
      case SnackBarType.error:
        return MyColors.errorColor;
      case SnackBarType.warning:
        return MyColors.yellow3;
      case SnackBarType.info:
        return MyColors.gray5;
    }
  }

  static Color _getTextColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
      case SnackBarType.error:
      case SnackBarType.warning:
      case SnackBarType.info:
        return MyColors.white;
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
    }
  }
}

enum SnackBarType {
  success,
  error,
  warning,
  info,
}
