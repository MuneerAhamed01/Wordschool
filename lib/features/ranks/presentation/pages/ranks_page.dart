import 'package:flutter/material.dart';
import 'package:wordshool/shared/presentations/widgets/placeholder_tab.dart';

class RanksPage extends StatelessWidget {
  static const String routeName = '/ranks';
  const RanksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTab(
      icon: Icons.emoji_events_outlined,
      title: 'Ranks',
      message: 'Leaderboards are coming soon.',
    );
  }
}
