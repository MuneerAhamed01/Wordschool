import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/language_toggle.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/streak_chip.dart';

/// Logo, app name, language toggle and streak.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          _buildLogoMark(),
          const SizedBox(width: 10),
          const Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: 'WordSchool '),
                TextSpan(
                    text: 'PSC', style: TextStyle(color: MyColors.accentGlow)),
              ]),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: MyColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
          ),
          const LanguageToggle(),
          const SizedBox(width: 8),
          StreakChip(days: streak),
        ],
      ),
    );
  }

  Widget _buildLogoMark() {
    return ExcludeSemantics(
      child: SizedBox(
        width: 36,
        height: 36,
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildLogoTile(MyColors.tileCorrect),
            _buildLogoTile(MyColors.tilePresent),
            _buildLogoTile(MyColors.tilePresent),
            _buildLogoTile(MyColors.tileCorrect),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoTile(Color color) => DecoratedBox(
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      );
}
