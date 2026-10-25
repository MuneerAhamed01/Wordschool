import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/routes/admin_router.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/features/admin/puzzles/builder/presentation/widgets/auto_puzzle_card.dart';
import 'package:wordshool/features/admin/shared/data/data_source/auth_service.dart';

import '../../features/admin/admin_fakes.dart';

const exampleAnswers = [
  'MUZIRIS', 'MALABAR', 'VAIKOM', 'GAMA', 'ASAN', 'KAPPAD', 'EMS' //
];

Future<GoRouter> pumpBuilder(WidgetTester tester, String location,
    {List<String> answers = exampleAnswers}) async {
  await registerAdminFakes({
    'adminListCategories': {
      'categories': [categoryJson('kerala-history', 'Kerala History')],
    },
    'adminListQuestions': questionsPage([
      for (final a in answers) questionJson(a),
      questionJson('KOCHI', subject: 'geography'),
    ]),
  });
  return pumpAdminRouter(tester,
      initialLocation: location,
      routes: [adminPuzzlesRoute(), locationRoute(AdminRoutes.questions)]);
}

FilledButton saveButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.ancestor(
        of: find.byIcon(Icons.save_outlined),
        matching: find.byWidgetPredicate((w) => w is FilledButton)));

void main() {
  group('adminRedirect', () {
    test('signed-out and non-admin users are sent to /login', () {
      for (final status in [
        AdminAuthStatus.signedOut,
        AdminAuthStatus.notAdmin
      ]) {
        expect(adminRedirect(location: '/puzzles', status: status), '/login');
        expect(adminRedirect(location: '/login', status: status), isNull);
      }
    });

    test('admins skip /login and stay where they are', () {
      expect(adminRedirect(location: '/login', status: AdminAuthStatus.admin),
          '/');
      expect(adminRedirect(location: '/reports', status: AdminAuthStatus.admin),
          isNull);
    });

    test('no redirect before the session is known', () {
      expect(
          adminRedirect(
              location: '/questions', status: AdminAuthStatus.unknown),
          isNull);
    });
  });

  group('/puzzles/new?auto=1', () {
    testWidgets('opens the builder with a filled, saveable grid',
        (tester) async {
      await pumpBuilder(tester, AdminRoutes.autoPuzzle('kerala-history'));
      expect(find.byType(AutoPuzzleCard), findsOneWidget);
      expect(find.textContaining('Auto-created: '), findsOneWidget);
      expect(find.textContaining('from 7 checked questions'), findsOneWidget);
      expect(find.text('Kerala History mix'), findsOneWidget);
      expect(find.text('Save puzzle'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNotNull);
      expect(find.textContaining('KOCHI'), findsNothing);

      // The existing checks still apply: no title, no save.
      await tester.enterText(
          find.widgetWithText(TextField, 'Kerala History mix'), '');
      await tester.pump();
      expect(find.text('Fix 1 to save'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);
    });

    testWidgets('"Try another" rebuilds and can be undone', (tester) async {
      await pumpBuilder(tester, AdminRoutes.autoPuzzle('kerala-history'));
      await tester.tap(find.text('Try another'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Auto-created: '), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Save puzzle'), findsOneWidget);
    });

    testWidgets('without auto=1 the builder starts empty', (tester) async {
      await pumpBuilder(tester, AdminRoutes.newPuzzle('kerala-history'));
      expect(find.byType(AutoPuzzleCard), findsNothing);
      expect(find.text('Words (0)'), findsOneWidget);
    });

    testWidgets('too few questions explains why and links to Questions',
        (tester) async {
      final router = await pumpBuilder(
          tester, AdminRoutes.autoPuzzle('kerala-history', size: 5),
          answers: ['MALABAR', 'EMS']);
      expect(
          find.text(
              'Not enough checked questions in Kerala History to build a grid'),
          findsOneWidget);
      expect(find.textContaining('Have 1 that fit a 5×5 grid'), findsOneWidget);
      expect(find.text('Words (0)'), findsOneWidget);
      await tester.tap(find.text('Go to Questions'));
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), '/questions?subject=kerala_history');
    });
  });
}
