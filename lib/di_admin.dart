import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:wordshool/features/admin/home/data/data_source/access_service.dart';
import 'package:wordshool/features/admin/reports/data/data_source/reports_service.dart';
import 'package:wordshool/features/admin/schedule/data/data_source/daily_entries_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/callable.dart';
import 'package:wordshool/features/admin/shared/data/data_source/auth_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/categories_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/puzzles_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/questions_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/schedule_service.dart';

/// Service locator for the admin panel (`main_admin.dart`). Separate from
/// `di.dart` so the web build doesn't pull in the player app's services.
final GetIt adminGetIt = GetIt.instance;

/// Functions are deployed to Mumbai (DEC-009).
const adminFunctionsRegion = 'asia-south1';

Future<void> initializeAdminDependency() async {
  _initializeAdminShared();
  _initializeAdminModules();
}

/// Auth and the callables two or more sections use.
void _initializeAdminShared() {
  final callable = AdminCallable(
      FirebaseFunctions.instanceFor(region: adminFunctionsRegion));
  adminGetIt
    ..registerSingleton<AdminAuthService>(
        AdminAuthService(FirebaseAuth.instance))
    ..registerSingleton(callable)
    ..registerSingleton(AdminCategoriesService(callable))
    ..registerSingleton(AdminQuestionsService(callable))
    ..registerSingleton(AdminPuzzlesService(callable))
    ..registerSingleton(AdminScheduleService(callable));
}

/// What only one section uses.
void _initializeAdminModules() {
  final callable = adminGetIt<AdminCallable>();
  adminGetIt
    ..registerSingleton(AdminAccessService(callable))
    ..registerSingleton(AdminReportsService(callable))
    ..registerSingleton(DailyEntriesService(FirebaseFirestore.instance));
}
