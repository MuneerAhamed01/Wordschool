import 'package:flutter/material.dart';
import 'package:wordshool/shared/presentations/widgets/placeholder_tab.dart';

class RevisePage extends StatelessWidget {
  static const String routeName = '/revise';
  const RevisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTab(
      icon: Icons.menu_book_outlined,
      title: 'Revise',
      message: 'Facts you missed in puzzles will show up here.',
    );
  }
}
