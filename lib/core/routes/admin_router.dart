import 'package:go_router/go_router.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_auth_service.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_login_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_shell_page.dart';

GoRouter adminRouter(String initialRoute) {
  return GoRouter(
    initialLocation: initialRoute,
    redirect: (context, state) async {
      final isLogin = state.matchedLocation == AdminLoginPage.routeName;
      final isAdmin = await adminGetIt<AdminAuthService>().isCurrentUserAdmin();
      if (!isAdmin && !isLogin) {
        return AdminLoginPage.routeName;
      }
      if (isAdmin && isLogin) {
        return AdminShellPage.routeName;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AdminLoginPage.routeName,
        builder: (context, state) => const AdminLoginPage(),
      ),
      GoRoute(
        path: AdminShellPage.routeName,
        builder: (context, state) => const AdminShellPage(),
      ),
    ],
  );
}
