import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/presentations/widgets/app_bottom_nav.dart';

/// Bottom-bar shell around the Play · Revise · Ranks · Profile tabs.
/// Each tab keeps its own navigator and state (`StatefulShellRoute.indexedStack`).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int _playIndex = 0;

  void _onTap(int index) {
    // Tapping the active tab again returns it to its first page
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onPlay = navigationShell.currentIndex == _playIndex;

    return PopScope(
      // Android back on another tab goes to Play first, then leaves the app
      canPop: onPlay,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(_playIndex);
      },
      child: Scaffold(
        backgroundColor: MyColors.gameBackground,
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
