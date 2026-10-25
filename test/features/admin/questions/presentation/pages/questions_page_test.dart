import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/features/admin/questions/presentation/pages/questions_page.dart';

import '../../../admin_fakes.dart';

Future<GoRouter> pumpQuestions(WidgetTester tester, String location) async {
  await registerAdminFakes({
    'adminListCategories': {
      'categories': [
        categoryJson('kerala-history', 'Kerala History'),
        categoryJson('geography', 'Geography'),
      ],
    },
    'adminListQuestions': (Map<String, dynamic> data) {
      final all = [
        questionJson('VAIKOM'),
        questionJson('GAMA'),
        questionJson('ASAN', status: 'draft'),
        questionJson('KOCHI', subject: 'geography'),
      ];
      return questionsPage([
        for (final q in all)
          if (data['subject'] == null || data['subject'] == q['subject']) q,
      ]);
    },
  });
  return pumpAdminRouter(
    tester,
    initialLocation: location,
    routes: [
      GoRoute(
        path: AdminRoutes.questions,
        builder: (context, state) => AdminQuestionsPage(
            initialSubject: state.uri.queryParameters['subject']),
      ),
      locationRoute('/puzzles/new'),
    ],
  );
}

void main() {
  testWidgets('the dialog preselects the filtered subject and navigates',
      (tester) async {
    final router = await pumpQuestions(
        tester, AdminRoutes.questionsOf(subject: 'kerala_history'));
    expect(find.text('KOCHI'), findsNothing);
    await tester.tap(find.text('Auto-create puzzle'));
    await tester.pumpAndSettle();
    expect(find.text('2 checked questions in this category'), findsOneWidget);
    await tester.tap(find.text('Build puzzle'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(),
        '/puzzles/new?category=kerala-history&auto=1&size=9&words=8');
  });

  testWidgets('chosen category and options go into the path', (tester) async {
    final router = await pumpQuestions(tester, AdminRoutes.questions);
    await tester.tap(find.text('Auto-create puzzle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kerala History').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Geography').last);
    await tester.pumpAndSettle();
    expect(find.text('1 checked question in this category'), findsOneWidget);
    await tester.tap(find.text('Any'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hard').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build puzzle'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(),
        '/puzzles/new?category=geography&auto=1&size=9&words=8&difficulty=hard');
  });

  testWidgets('cancel stays on Questions', (tester) async {
    final router = await pumpQuestions(tester, AdminRoutes.questions);
    await tester.tap(find.text('Auto-create puzzle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), AdminRoutes.questions);
  });
}
