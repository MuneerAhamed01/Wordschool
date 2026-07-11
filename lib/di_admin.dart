import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordshool/core/config/app_config.dart';
import 'package:wordshool/core/config/app_environment.dart';
import 'package:wordshool/features/admin/data/admin_api_service.dart';
import 'package:wordshool/features/admin/data/admin_auth_service.dart';
import 'package:wordshool/features/admin/data/admin_environment_store.dart';

final GetIt adminGetIt = GetIt.instance;

Future<void> initializeAdminDependency() async {
  if (!adminGetIt.isRegistered<SharedPreferences>()) {
    final sharedPref = await SharedPreferences.getInstance();
    adminGetIt.registerSingleton<SharedPreferences>(sharedPref);
  }

  if (!adminGetIt.isRegistered<AppConfig>()) {
    adminGetIt.registerSingleton<AppConfig>(
      AppConfig.forEnvironment(AppEnvironment.dev),
    );
  }

  if (!adminGetIt.isRegistered<AdminEnvironmentStore>()) {
    adminGetIt.registerSingleton<AdminEnvironmentStore>(
      AdminEnvironmentStore(adminGetIt<SharedPreferences>()),
    );
  }

  if (!adminGetIt.isRegistered<AdminAuthService>()) {
    adminGetIt.registerSingleton<AdminAuthService>(
      AdminAuthService(FirebaseAuth.instance),
    );
  }

  if (!adminGetIt.isRegistered<FirebaseFunctions>()) {
    adminGetIt.registerSingleton<FirebaseFunctions>(
      FirebaseFunctions.instance,
    );
  }

  if (!adminGetIt.isRegistered<AdminApiService>()) {
    adminGetIt.registerSingleton<AdminApiService>(
      AdminApiService(
        functions: adminGetIt<FirebaseFunctions>(),
        environmentStore: adminGetIt<AdminEnvironmentStore>(),
      ),
    );
  }
}
