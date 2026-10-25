import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PSC Crossword',
          style: textTheme.headlineMedium
              ?.copyWith(color: MyColors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Revise Kerala PSC facts, one grid at a time.',
          style: textTheme.bodyMedium?.copyWith(color: MyColors.navInactive),
        ),
      ],
    );
  }
}
