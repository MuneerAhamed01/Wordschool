import 'package:flutter/material.dart';

import 'analytics_service.dart';

/// Maps route paths to readable Firebase screen names.
String analyticsScreenNameForRoute(String? routePath) {
  if (routePath == null || routePath.isEmpty) return 'unknown';

  var path = routePath.split('?').first;
  if (!path.startsWith('/')) path = '/$path';

  return switch (path) {
    '/auth' => 'Auth',
    '/home' => 'Dashboard',
    '/game' => 'Game',
    '/archive' => 'Archive',
    '/story' => 'Story Mode',
    '/leaderboard' => 'Leaderboard',
    '/settings' => 'Settings',
    '/winning' => 'Winning',
    '/terms' => 'Terms',
    '/privacy' => 'Privacy',
    _ => path.replaceFirst('/', '').replaceAll('-', ' '),
  };
}

/// Tracks screen views and time-on-screen for engagement analysis.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AnalyticsService _analytics;
  final Map<Route<dynamic>, _ScreenSession> _sessions = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _startSession(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) _endSession(oldRoute);
    if (newRoute != null) _startSession(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _endSession(route);
  }

  void _startSession(Route<dynamic> route) {
    final screenName = _screenNameFromRoute(route);
    if (screenName == null) return;

    _sessions[route] = _ScreenSession(
      screenName: screenName,
      startedAt: DateTime.now(),
    );

    _analytics.logScreenView(screenName: screenName);
  }

  void _endSession(Route<dynamic> route) {
    final session = _sessions.remove(route);
    if (session == null) return;

    final seconds =
        DateTime.now().difference(session.startedAt).inSeconds.clamp(0, 86400);

    if (seconds > 0) {
      _analytics.logScreenEngagement(
        screenName: session.screenName,
        durationSeconds: seconds,
      );
    }
  }

  String? _screenNameFromRoute(Route<dynamic> route) {
    final settings = route.settings;
    final name = settings.name;
    if (name != null && name.isNotEmpty) {
      return analyticsScreenNameForRoute(name);
    }

    return null;
  }
}

class _ScreenSession {
  const _ScreenSession({
    required this.screenName,
    required this.startedAt,
  });

  final String screenName;
  final DateTime startedAt;
}
