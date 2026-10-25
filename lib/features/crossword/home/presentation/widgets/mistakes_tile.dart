import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/home/presentation/widgets/home_tile.dart';

/// The 6th card: "My mistakes" → Revise.
class MistakesTile extends StatelessWidget {
  const MistakesTile({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeTile(
      semanticsLabel: 'My mistakes, $count to revise',
      onTap: onTap,
      icon: Icons.menu_book_outlined,
      iconColor: MyColors.streakAccent,
      corner: '$count',
      title: 'My mistakes',
      footer: const Text('Revise',
          style: TextStyle(color: MyColors.accentGlow, fontSize: 12)),
    );
  }
}
