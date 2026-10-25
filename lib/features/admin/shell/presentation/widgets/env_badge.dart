import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// Shows which Firebase project the panel writes to (DEC-002: one project per
/// environment). Anything that isn't a `-dev` project is treated as live.
class EnvBadge extends StatelessWidget {
  const EnvBadge({super.key, required this.projectId});

  final String projectId;

  bool get isDev => projectId.endsWith('-dev');

  @override
  Widget build(BuildContext context) {
    final background = isDev ? MyColors.warnBg : MyColors.errorBg;
    final foreground = isDev ? MyColors.warnText : MyColors.errorText;
    return Tooltip(
      message: isDev
          ? 'Test project — safe to experiment'
          : 'LIVE project — changes reach real players',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: foreground.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isDev ? Icons.science_outlined : Icons.public,
                size: 14, color: foreground),
            const SizedBox(width: 6),
            Text(
              '${isDev ? 'TEST' : 'LIVE'} · $projectId',
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
