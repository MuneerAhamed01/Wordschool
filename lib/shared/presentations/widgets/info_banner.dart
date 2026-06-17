import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    required this.icon,
    this.tone = InfoBannerTone.neutral,
  });

  final String message;
  final IconData icon;
  final InfoBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final color = _toneColor();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MyColors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _toneColor() {
    switch (tone) {
      case InfoBannerTone.info:
        return MyColors.lightBlue3;
      case InfoBannerTone.success:
        return MyColors.tileCorrect;
      case InfoBannerTone.neutral:
        return MyColors.textMuted;
    }
  }
}

enum InfoBannerTone { info, success, neutral }
