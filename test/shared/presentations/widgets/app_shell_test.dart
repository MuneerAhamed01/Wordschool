import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/routes/app_router.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/crossword/home/presentation/pages/home_page.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:wordshool/features/crossword/revise/presentation/pages/revise_page.dart';
import 'package:wordshool/features/profile/presentation/pages/profile_page.dart';

import '../../../features/crossword/crossword_fakes.dart';

void main() {
  late GoRouter router;

  Future<void> pumpShell(WidgetTester tester) async {
    router = appRouter(isSignedIn: () => true);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.bySemanticsLabel(label));
    await tester.pumpAndSettle();
  }

  String location() => router.routerDelegate.currentConfiguration.uri.path;

  setUp(() => registerCrosswordFakes(getIt, FakeCrosswordRepository()));

  tearDown(() async {
    router.dispose();
    await getIt.reset();
  });

  testWidgets('starts on Play with four tabs', (tester) async {
    await pumpShell(tester);

    expect(location(), HomePage.routeName);
    expect(find.byType(HomePage), findsOneWidget);
    for (final label in ['Play', 'Revise', 'Ranks', 'Profile']) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('each tab opens its page', (tester) async {
    await pumpShell(tester);

    await tapTab(tester, 'Revise');
    expect(location(), RevisePage.routeName);
    expect(find.byType(RevisePage), findsOneWidget);

    await tapTab(tester, 'Ranks');
    expect(location(), LeaderboardPage.routeName);
    expect(find.byType(LeaderboardPage), findsOneWidget);

    await tapTab(tester, 'Profile');
    expect(location(), ProfilePage.routeName);
    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('tabs keep their state when switching', (tester) async {
    await pumpShell(tester);
    final homeElement = tester.element(find.byType(HomePage));

    await tapTab(tester, 'Revise');
    // Play stays mounted offstage instead of being disposed
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(HomePage, skipOffstage: false), findsOneWidget);

    await tapTab(tester, 'Play');
    expect(tester.element(find.byType(HomePage)), same(homeElement));
  });

  testWidgets('Android back on another tab returns to Play', (tester) async {
    await pumpShell(tester);
    await tapTab(tester, 'Ranks');

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(location(), HomePage.routeName);
    expect(find.byType(HomePage), findsOneWidget);
  });
}
