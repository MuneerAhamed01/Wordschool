import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/auth_service.dart';
import 'package:wordshool/features/admin/shared/presentation/sections.dart';
import 'package:wordshool/features/admin/shell/presentation/widgets/env_badge.dart';

/// Frame around every admin page: side menu on wide screens, a drawer on
/// narrow ones, and the environment badge + account at the top.
class AdminShellPage extends StatelessWidget {
  const AdminShellPage({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const _wideBreakpoint = 1000.0;

  @override
  Widget build(BuildContext context) {
    final current = AdminSection.forLocation(location);
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final projectId = Firebase.app().options.projectId;

    final topBar = _TopBar(projectId: projectId, showMenu: !wide);

    if (!wide) {
      return Scaffold(
        drawer: Drawer(
          backgroundColor: MyColors.navBarBackground,
          child: SafeArea(
            child: _Menu(
              current: current,
              onSelected: (section) {
                Navigator.of(context).pop();
                context.go(section.path);
              },
            ),
          ),
        ),
        body: SafeArea(
          child: Column(children: [topBar, Expanded(child: child)]),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 248,
            child: ColoredBox(
              color: MyColors.navBarBackground,
              child: _Menu(
                current: current,
                onSelected: (section) => context.go(section.path),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(children: [topBar, Expanded(child: child)]),
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.current, required this.onSelected});

  final AdminSection current;
  final ValueChanged<AdminSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MyColors.tileCorrect,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'P',
                  style: TextStyle(
                    color: MyColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PSC Admin',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Crossword content',
                    style: textTheme.bodySmall
                        ?.copyWith(color: MyColors.navInactive),
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final section in AdminSection.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _MenuItem(
              section: section,
              selected: section == current,
              onTap: () => onSelected(section),
            ),
          ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final AdminSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? MyColors.successText : MyColors.navInactive;
    return Tooltip(
      message: section.summary,
      waitDuration: const Duration(milliseconds: 800),
      child: Material(
        color: selected ? MyColors.successBg : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(selected ? section.selectedIcon : section.icon,
                    color: color, size: 22),
                const SizedBox(width: 14),
                Text(
                  section.label,
                  style: TextStyle(
                    color: selected ? MyColors.white : MyColors.textSecondary,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.projectId, required this.showMenu});

  final String projectId;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final auth = adminGetIt<AdminAuthService>();
    final email = auth.currentUser?.email ?? '';
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MyColors.gameBorderSubtle)),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const Spacer(),
          EnvBadge(projectId: projectId),
          const SizedBox(width: 8),
          PopupMenuButton<void>(
            tooltip: 'Account',
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                enabled: false,
                child: Text(email.isEmpty ? 'Signed in' : email),
              ),
              PopupMenuItem<void>(
                onTap: auth.signOut,
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 10),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: MyColors.gameSurfaceElevated,
                child: Text(
                  email.isEmpty ? '?' : email[0].toUpperCase(),
                  style: const TextStyle(
                    color: MyColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
