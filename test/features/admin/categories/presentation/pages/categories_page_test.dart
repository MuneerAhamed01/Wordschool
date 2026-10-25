import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/features/admin/categories/presentation/pages/categories_page.dart';

import '../../../admin_fakes.dart';

void main() {
  testWidgets('the ✨ row action opens the auto-created puzzle builder',
      (tester) async {
    await registerAdminFakes({
      'adminListCategories': {
        'categories': [
          categoryJson('kerala-history', 'Kerala History'),
          categoryJson('geography', 'Geography'),
        ],
      },
    });
    final router = await pumpAdminRouter(
      tester,
      initialLocation: AdminRoutes.categories,
      routes: [
        GoRoute(
          path: AdminRoutes.categories,
          builder: (context, state) => const AdminCategoriesPage(),
        ),
        locationRoute('/puzzles/new'),
      ],
    );
    expect(find.byTooltip('Auto-create puzzle'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Auto-create puzzle').last);
    await tester.pumpAndSettle();
    expect(
        router.state.uri.toString(), '/puzzles/new?category=geography&auto=1');
  });
}
