import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:wordshool/features/admin/data/admin_api_service.dart';
import 'package:wordshool/features/admin/data/admin_auth_service.dart';

/// Service locator for the admin panel (`main_admin.dart`). Separate from
/// `di.dart` so the web build doesn't pull in the player app's services.
final GetIt adminGetIt = GetIt.instance;

/// Functions are deployed to Mumbai (DEC-009).
const adminFunctionsRegion = 'asia-south1';

Future<void> initializeAdminDependency() async {
  _initializeAdmin();
}

void _initializeAdmin() {
  adminGetIt.registerSingleton<AdminAuthService>(
    AdminAuthService(FirebaseAuth.instance),
  );
  adminGetIt.registerSingleton<AdminApiService>(
    AdminApiService(
      functions: FirebaseFunctions.instanceFor(region: adminFunctionsRegion),
    ),
  );
}
