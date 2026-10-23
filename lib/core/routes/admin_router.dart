import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/admin/data/admin_auth_service.dart';
import 'package:wordshool/features/admin/presentation/admin_sections.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_home_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_login_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_shell_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_section_placeholder.dart';

/// Only admins get past `/login`; admins never see it.
@visibleForTesting
String? adminRedirect({
  required String location,
  required AdminAuthStatus status,
}) {
  final atLogin = location == AdminLoginPage.routeName;
  if (status == AdminAuthStatus.unknown) return null;
  if (status != AdminAuthStatus.admin) {
    return atLogin ? null : AdminLoginPage.routeName;
  }
  return atLogin ? AdminHomePage.routeName : null;
}

GoRouter adminRouter(AdminAuthService auth) {
  return GoRouter(
    initialLocation: AdminHomePage.routeName,
    refreshListenable: auth,
    redirect: (context, state) => adminRedirect(
      location: state.matchedLocation,
      status: auth.status,
    ),
    routes: [
      GoRoute(
        path: AdminLoginPage.routeName,
        builder: (context, state) => const AdminLoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShellPage(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AdminHomePage.routeName,
            builder: (context, state) => const AdminHomePage(),
          ),
          for (final section in AdminSection.values.skip(1))
            GoRoute(
              path: section.path,
              builder: (context, state) =>
                  AdminSectionPlaceholder(section: section),
            ),
        ],
      ),
    ],
  );
}
