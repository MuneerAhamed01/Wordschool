import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/admin_theme.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/callable.dart';
import 'package:wordshool/features/admin/shared/data/data_source/categories_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/puzzles_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/questions_service.dart';

/// Answers admin callables from canned JSON instead of Cloud Functions, so
/// the real services and pages can run in widget tests.
class FakeAdminCallable implements AdminCallable {
  FakeAdminCallable(this.responses);

  /// Callable name → response JSON (or a function of the request data).
  final Map<String, Object> responses;
  final List<String> calls = [];

  @override
  Future<DataState<Map<String, dynamic>>> call(String name,
      [Map<String, dynamic> data = const {}]) async {
    calls.add(name);
    final response = responses[name];
    if (response == null) {
      return DataError(
          error: AppError(error: name, code: 'not-found', message: name));
    }
    return DataSuccess(
      data: response is Map<String, dynamic> Function(Map<String, dynamic>)
          ? response(data)
          : response as Map<String, dynamic>,
    );
  }
}

/// Registers the shared admin services on top of [callable].
Future<FakeAdminCallable> registerAdminFakes(
    Map<String, Object> responses) async {
  await adminGetIt.reset();
  final callable = FakeAdminCallable(responses);
  adminGetIt
    ..registerSingleton<AdminCallable>(callable)
    ..registerSingleton(AdminCategoriesService(callable))
    ..registerSingleton(AdminQuestionsService(callable))
    ..registerSingleton(AdminPuzzlesService(callable));
  return callable;
}

Map<String, dynamic> categoryJson(String id, String name) => {
      'id': id,
      'name': {'en': name},
      'icon': 'history_edu',
      'color': '#538D4E',
      'order': 1,
      'isActive': true,
    };

Map<String, dynamic> questionJson(
  String answer, {
  String subject = 'kerala_history',
  String status = 'verified',
}) =>
    {
      'id': 'q-$answer',
      'answer': answer,
      'answerDisplay': {'en': answer},
      'clues': [
        {'en': 'Clue for $answer', 'level': 'easy'},
      ],
      'fact': {'en': 'Fact about $answer'},
      'subject': subject,
      'difficulty': 'medium',
      'source': {'type': 'book', 'ref': 'A book'},
      'status': status,
    };

Map<String, dynamic> questionsPage(List<Map<String, dynamic>> questions) =>
    {'questions': questions, 'nextStartAfterId': null};

/// A router over [routes] inside a plain scaffold (the real shell needs
/// Firebase), on a wide desktop-sized screen.
Future<GoRouter> pumpAdminRouter(
  WidgetTester tester, {
  required String initialLocation,
  required List<RouteBase> routes,
}) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => Scaffold(body: child),
        routes: routes,
      ),
    ],
  );
  await tester.pumpWidget(
      MaterialApp.router(theme: adminTheme(), routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

/// Shows the location it was opened at, for navigation tests.
GoRoute locationRoute(String path) => GoRoute(
      path: path,
      builder: (context, state) => Text('at ${state.uri}'),
    );
