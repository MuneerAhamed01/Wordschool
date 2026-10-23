import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/admin/data/admin_auth_service.dart';
import 'package:wordshool/features/admin/presentation/admin_sections.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_categories_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_home_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_login_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_puzzle_builder_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_puzzle_detail_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_puzzles_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_questions_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_reports_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_schedule_page.dart';
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

const _unbuiltSections = [
  AdminSection.bulkUpload,
];

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
          GoRoute(
            path: AdminCategoriesPage.routeName,
            builder: (context, state) => const AdminCategoriesPage(),
          ),
          GoRoute(
            path: AdminQuestionsPage.routeName,
            builder: (context, state) => const AdminQuestionsPage(),
          ),
          GoRoute(
            path: AdminPuzzlesPage.routeName,
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
            path: AdminSchedulePage.routeName,
            builder: (context, state) => const AdminSchedulePage(),
          ),
          GoRoute(
            path: AdminReportsPage.routeName,
            builder: (context, state) => const AdminReportsPage(),
          ),
          for (final section in _unbuiltSections)
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
