import 'package:flutter/material.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/shared/presentations/widgets/placeholder_tab.dart';

class ProfilePage extends StatelessWidget {
  static const String routeName = AppRoutes.profile;
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTab(
      icon: Icons.person_outline_rounded,
      title: 'Profile',
      message: 'Your XP, streak and settings are coming soon.',
    );
  }
}
