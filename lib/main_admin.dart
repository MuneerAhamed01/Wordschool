import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/admin_theme.dart';
import 'package:wordshool/core/routes/admin_router.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/auth_service.dart';
import 'package:wordshool/firebase_options.dart';

/// Admin panel (Flutter web):
/// `fvm flutter run -t lib/main_admin.dart -d chrome`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeAdminDependency();

  // Restore the persisted session before the first redirect.
  final auth = adminGetIt<AdminAuthService>();
  await auth.ready;

  runApp(AdminApp(router: adminRouter(auth)));
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kerala PSC Admin',
      theme: adminTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
