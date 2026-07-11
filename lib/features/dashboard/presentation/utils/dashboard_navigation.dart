import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/features/dashboard/presentation/utils/dashboard_refresh_controller.dart';

/// Navigates to the dashboard and schedules a data refresh.
void navigateToDashboardHome(BuildContext context) {
  if (getIt.isRegistered<DashboardRefreshController>()) {
    getIt<DashboardRefreshController>().requestRefresh();
  }
  context.go(DashboardPage.routeName);
}
