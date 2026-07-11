import 'package:flutter/material.dart';
import 'package:wordshool/app/admin_app.dart';
import 'package:wordshool/core/firebase/firebase_bootstrap.dart';
import 'package:wordshool/core/config/app_config.dart';
import 'package:wordshool/core/config/app_environment.dart';
import 'package:wordshool/core/routes/admin_router.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_auth_service.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_login_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_shell_page.dart';

/// Web-only bootstrap for the WordSchool admin panel.
Future<void> bootstrapAdmin() async {
  WidgetsFlutterBinding.ensureInitialized();

  const appConfig = AppConfig(
    environment: AppEnvironment.dev,
    firestoreDatabaseId: 'development',
    displayName: 'WordSchool Admin',
    envFileName: '.env.dev',
    bundleId: 'com.wordschool.mat.admin',
  );

  await FirebaseBootstrap.initialize(appConfig);
  await initializeAdminDependency();

  final auth = adminGetIt<AdminAuthService>();
  final isAdmin = await auth.isCurrentUserAdmin();
  final initialRoute =
      isAdmin ? AdminShellPage.routeName : AdminLoginPage.routeName;
  final router = adminRouter(initialRoute);

  runApp(AdminApp(router: router));
}
