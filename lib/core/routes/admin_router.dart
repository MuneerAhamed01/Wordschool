import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/features/admin/shared/data/data_source/auth_service.dart';
import 'package:wordshool/features/admin/bulk_upload/presentation/pages/bulk_upload_page.dart';
import 'package:wordshool/features/admin/categories/presentation/pages/categories_page.dart';
import 'package:wordshool/features/admin/home/presentation/pages/home_page.dart';
import 'package:wordshool/features/admin/auth/presentation/pages/login_page.dart';
import 'package:wordshool/features/admin/puzzles/builder/presentation/pages/puzzle_builder_page.dart';
import 'package:wordshool/features/admin/puzzles/detail/presentation/pages/puzzle_detail_page.dart';
import 'package:wordshool/features/admin/puzzles/presentation/pages/puzzles_page.dart';
import 'package:wordshool/features/admin/questions/presentation/pages/questions_page.dart';
import 'package:wordshool/features/admin/reports/presentation/pages/reports_page.dart';
import 'package:wordshool/features/admin/schedule/presentation/pages/schedule_page.dart';
import 'package:wordshool/features/admin/shell/presentation/pages/shell_page.dart';

/// Only admins get past `/login`; admins never see it.
@visibleForTesting
String? adminRedirect({
  required String location,
  required AdminAuthStatus status,
}) {
  final atLogin = location == AdminRoutes.login;
  if (status == AdminAuthStatus.unknown) return null;
  if (status != AdminAuthStatus.admin) {
    return atLogin ? null : AdminRoutes.login;
  }
  return atLogin ? AdminRoutes.home : null;
}

GoRouter adminRouter(AdminAuthService auth) {
  return GoRouter(
    initialLocation: AdminRoutes.home,
    refreshListenable: auth,
    redirect: (context, state) => adminRedirect(
      location: state.matchedLocation,
      status: auth.status,
    ),
    routes: [
      GoRoute(
        path: AdminRoutes.login,
        builder: (context, state) => const AdminLoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShellPage(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AdminRoutes.home,
            builder: (context, state) => const AdminHomePage(),
          ),
          GoRoute(
            path: AdminRoutes.categories,
            builder: (context, state) => const AdminCategoriesPage(),
          ),
          GoRoute(
            path: AdminRoutes.questions,
            builder: (context, state) => const AdminQuestionsPage(),
          ),
          GoRoute(
            path: AdminRoutes.puzzles,
            builder: (context, state) => AdminPuzzlesPage(
              key: ValueKey(state.uri.queryParameters['category']),
              initialCategoryId: state.uri.queryParameters['category'],
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => AdminPuzzleBuilderPage(
                  initialCategoryId: state.uri.queryParameters['category'],
                ),
              ),
              GoRoute(
                path: ':puzzleId',
                builder: (context, state) => AdminPuzzleDetailPage(
                  key: ValueKey(state.uri.toString()),
                  puzzleId: state.pathParameters['puzzleId']!,
                  highlightWordId: state.uri.queryParameters['word'],
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => AdminPuzzleBuilderPage(
                      key: ValueKey('edit-${state.pathParameters['puzzleId']}'),
                      puzzleId: state.pathParameters['puzzleId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AdminRoutes.schedule,
            builder: (context, state) => const AdminSchedulePage(),
          ),
          GoRoute(
            path: AdminRoutes.reports,
            builder: (context, state) => const AdminReportsPage(),
          ),
          GoRoute(
            path: AdminRoutes.bulkUpload,
            builder: (context, state) => const AdminBulkUploadPage(),
          ),
        ],
      ),
    ],
  );
}
