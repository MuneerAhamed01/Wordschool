import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// `EN / മല` — Malayalam is disabled in phase 1 (NEXT-002).
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Malayalam is coming soon',
      child: Container(
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: MyColors.gameSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MyColors.gameBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MyColors.gameSurfaceElevated,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Text('EN',
                  style: TextStyle(
                      color: MyColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('മല',
                  style: TextStyle(color: MyColors.navInactive, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
