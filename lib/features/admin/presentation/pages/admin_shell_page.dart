import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_auth_service.dart';
import 'package:wordshool/features/admin/data/admin_environment_store.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_cases_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_games_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_login_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_users_page.dart';
import 'package:wordshool/features/admin/presentation/widgets/env_badge.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  static const routeName = '/admin';

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _selectedIndex = 0;
  late AdminTargetEnvironment _environment;

  @override
  void initState() {
    super.initState();
    _environment = adminGetIt<AdminEnvironmentStore>().current;
  }

  Future<void> _switchEnvironment(AdminTargetEnvironment env) async {
    await adminGetIt<AdminEnvironmentStore>().setEnvironment(env);
    setState(() => _environment = env);
  }

  Future<void> _signOut() async {
    await adminGetIt<AdminAuthService>().signOut();
    if (!mounted) return;
    context.go(AdminLoginPage.routeName);
  }

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return const AdminDashboardPage();
      case 1:
        return const AdminGamesPage();
      case 2:
        return const AdminCasesPage();
      case 3:
        return const AdminUsersPage();
      default:
        return const AdminDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final isProd = _environment.isProd;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WordSchool Admin'),
        actions: [
          EnvBadge(environment: _environment),
          const SizedBox(width: 8),
          PopupMenuButton<AdminTargetEnvironment>(
            tooltip: 'Environment',
            onSelected: _switchEnvironment,
            itemBuilder: (context) => AdminTargetEnvironment.values
                .map(
                  (env) => PopupMenuItem(
                    value: env,
                    child: Row(
                      children: [
                        Icon(
                          env.isProd ? Icons.shield : Icons.build,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(env.label),
                      ],
                    ),
                  ),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(_environment.label),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_environment.isProd)
            MaterialBanner(
              backgroundColor: Colors.orange.shade900,
              content: const Text('DEV — safe to experiment'),
              actions: const [SizedBox.shrink()],
            ),
          if (isProd)
            MaterialBanner(
              backgroundColor: Colors.green.shade900,
              content: const Text('PRODUCTION — changes affect live users'),
              actions: const [SizedBox.shrink()],
            ),
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (i) =>
                            setState(() => _selectedIndex = i),
                        labelType: NavigationRailLabelType.all,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.dashboard),
                            label: Text('Dashboard'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.grid_on),
                            label: Text('Puzzles'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.search),
                            label: Text('Cases'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.people),
                            label: Text('Users'),
                          ),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: _pageForIndex(_selectedIndex)),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(child: _pageForIndex(_selectedIndex)),
                      NavigationBar(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (i) =>
                            setState(() => _selectedIndex = i),
                        destinations: const [
                          NavigationDestination(
                            icon: Icon(Icons.dashboard),
                            label: 'Dashboard',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.grid_on),
                            label: 'Puzzles',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.search),
                            label: 'Cases',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.people),
                            label: 'Users',
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
