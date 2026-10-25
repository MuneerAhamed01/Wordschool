import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/presentations/widgets/pressable_scale.dart';

/// The shared look of Home's grid cards: icon well, corner text, title,
/// footer.
class HomeTile extends StatelessWidget {
  const HomeTile({
    super.key,
    required this.semanticsLabel,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.corner,
    required this.title,
    required this.footer,
  });

  final String semanticsLabel;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final String corner;
  final String title;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MyColors.gameSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MyColors.gameBorderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const Spacer(),
                  Text(
                    corner,
                    style: const TextStyle(
                      color: MyColors.navInactive,
                      fontSize: 12,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: MyColors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}
